/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "src/language.h"
#include "src/logging.h"
#include "src/backendconnection.h"
#include "src/allservicesmodel.h"
#include "src/mockmanager.h"
#include "src/frameratemodel.h"

#if VENUS_GX_BUILD
#include "src/urlinterceptor.h"
#endif

#if defined(VENUS_WEBASSEMBLY_BUILD)
#include <emscripten/html5.h>
#include <emscripten/val.h>
#include <emscripten.h>
#include <QUrl>
#include <QUrlQuery>
#endif

#include <QGuiApplication>
#include <QQuickView>
#include <QSurfaceFormat>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQuickWindow>
#include <QCommandLineParser>
#include <QQuickItem>
#include <QStyleHints>

#include <QtDebug>

#include "themeobjects.h"
#include "QZXing.h"
Q_LOGGING_CATEGORY(venusGui, "venus.gui")

namespace {

#if defined(VENUS_WEBASSEMBLY_BUILD)
EM_BOOL visibilitychange_callback(int /* eventType */, const EmscriptenVisibilityChangeEvent *e, void *userData)
{
	Victron::VenusOS::BackendConnection *backend = static_cast<Victron::VenusOS::BackendConnection*>(userData);
	backend->setApplicationVisible(!e->hidden);
	return 0;
}
#endif // VENUS_WEBASSEMBLY_BUILD

QString calculateMqttAddressFromShard(const QString &shard)
{
	return QStringLiteral("wss://webmqtt%1.victronenergy.com/mqtt").arg(shard);
}

QString calculateMqttAddressFromPortalId(const QString &portalId)
{
	int shard = 0;
	const QString lower = portalId.toLower().trimmed();
	for (const QChar &ch : lower) {
		shard += ch.toLatin1();
	}
	const QString shardStr = shard > 0 ? QStringLiteral("%1").arg(shard % 128) : QString();
	return calculateMqttAddressFromShard(shardStr);
}

void initBackend(bool *enableFpsCounter, bool *skipSplashScreen)
{
	Victron::VenusOS::BackendConnection *backend = Victron::VenusOS::BackendConnection::create();

	QString queryMqttAddress, queryMqttPortalId, queryMqttShard, queryMqttUser, queryMqttPass, queryMqttToken, queryFpsCounter, queryColorScheme, queryNodeRedUrl, querySignalKUrl;
#if defined(VENUS_WEBASSEMBLY_BUILD)
	emscripten_set_visibilitychange_callback(static_cast<void*>(backend), 1, visibilitychange_callback);
	emscripten::val webLocation = emscripten::val::global("location");
	const QUrl webLocationUrl = QUrl(QString::fromStdString(webLocation["href"].as<std::string>()));
	const QUrlQuery query(webLocationUrl);
	if (query.hasQueryItem("mqtt")) {
		queryMqttAddress = QString::fromUtf8(QByteArray::fromPercentEncoding(query.queryItemValue("mqtt").toUtf8())); // e.g.: "ws://192.168.5.96:9001/"
	}
	if (query.hasQueryItem("id")) {
		queryMqttPortalId = QString::fromUtf8(QByteArray::fromPercentEncoding(query.queryItemValue("id").toUtf8())); // e.g.: some cerbogx portal id.
	}
	if (query.hasQueryItem("shard")) {
		queryMqttShard = QString::fromUtf8(QByteArray::fromPercentEncoding(query.queryItemValue("shard").toUtf8())); // e.g.: "114" (or "vrm" for API)
	}
	if (query.hasQueryItem("user")) {
		queryMqttUser = QString::fromUtf8(QByteArray::fromPercentEncoding(query.queryItemValue("user").toUtf8())); // e.g.: vrmlogin_live_user.name@example.com
	}
	if (query.hasQueryItem("pass")) {
		queryMqttPass = QString::fromUtf8(QByteArray::fromPercentEncoding(query.queryItemValue("pass").toUtf8())); // e.g.: some password
	}
	if (query.hasQueryItem("token")) {
		queryMqttToken = QString::fromUtf8(QByteArray::fromPercentEncoding(query.queryItemValue("token").toUtf8())); // e.g.: some JWT token from VRM.
	}
	if (query.hasQueryItem("fpsCounter")) {
		queryFpsCounter = QString::fromUtf8(QByteArray::fromPercentEncoding(query.queryItemValue("fpsCounter").toUtf8())); // e.g.: enabled
	}
	if (query.hasQueryItem("nodeRedUrl")) {
		queryNodeRedUrl = QString::fromUtf8(QByteArray::fromPercentEncoding(query.queryItemValue("nodeRedUrl").toUtf8())); // e.g.: "https://192.168.1.132:1881/"
	}
	if (query.hasQueryItem("signalKUrl")) {
		querySignalKUrl = QString::fromUtf8(QByteArray::fromPercentEncoding(query.queryItemValue("signalKUrl").toUtf8())); // e.g.: "http://192.168.1.132:3000/"
	}
	if (query.hasQueryItem("colorScheme")) {
		// "dark" forces dark mode, "light" forces light mode, "auto" forces auto mode, "default" uses the user choice
		queryColorScheme = QString::fromUtf8(QByteArray::fromPercentEncoding(query.queryItemValue("colorScheme").toUtf8())); // e.g.: "dark", "light", "auto", "default"
	}
#endif

	QCommandLineParser parser;
	parser.setApplicationDescription("Venus GUI");
	parser.addHelpOption();
	parser.addVersionOption();

	QList<QCommandLineOption> optionList;

	QCommandLineOption dbusAddress({ "d", "dbus" },
		QGuiApplication::tr("Use D-Bus data source: connect to the specified D-Bus address."),
		QGuiApplication::tr("address", "D-Bus address"));
	parser.addOption(dbusAddress);
	optionList << dbusAddress;

	QCommandLineOption dbusDefault("dbus-default",
		QGuiApplication::tr("Use D-Bus data source: connect to the default D-Bus address"));
	parser.addOption(dbusDefault);
	optionList << dbusDefault;

	// If the MQTT Address is provided, then it's a local LAN MQTT broker (e.g. the CerboGX address).
	QCommandLineOption mqttAddress({ "m", "mqtt" },
		QGuiApplication::tr("Use MQTT data source: connect to the specified MQTT broker address."),
		QGuiApplication::tr("address", "MQTT broker address"));
	parser.addOption(mqttAddress);
	optionList << mqttAddress;

	// Otherwise, we need to calculate the VRM broker shard address from the portal id.
	QCommandLineOption mqttPortalId({ "i", "id" },
		QGuiApplication::tr("MQTT data source device portal id."),
		QGuiApplication::tr("portalId"));
	parser.addOption(mqttPortalId);
	optionList << mqttPortalId;

	QCommandLineOption mqttShard({ "s", "shard" },
		QGuiApplication::tr("MQTT VRM webhost shard"),
		QGuiApplication::tr("shard", "MQTT VRM webhost shard"));
	parser.addOption(mqttShard);
	optionList << mqttShard;

	QCommandLineOption mqttUser({ "u", "user" },
		QGuiApplication::tr("MQTT data source username"),
		QGuiApplication::tr("user", "MQTT broker username."));
	parser.addOption(mqttUser);
	optionList << mqttUser;

	QCommandLineOption mqttPass({ "p", "pass" },
		QGuiApplication::tr("MQTT data source password"),
		QGuiApplication::tr("pass", "MQTT broker password."));
	parser.addOption(mqttPass);
	optionList << mqttPass;

	QCommandLineOption mqttToken({ "t", "token" },
		QGuiApplication::tr("MQTT data source token"),
		QGuiApplication::tr("token", "MQTT broker auth token."));
	parser.addOption(mqttToken);
	optionList << mqttToken;

	QCommandLineOption fpsCounter({ "f", "fpsCounter" },
		QGuiApplication::tr("Enable FPS counter"));
	parser.addOption(fpsCounter);
	optionList << fpsCounter;

	QCommandLineOption skipSplash("skip-splash",
		QGuiApplication::tr("Skip splash screen"));
	parser.addOption(skipSplash);
	optionList << skipSplash;

	QCommandLineOption mockMode({ "k", "mock" },
		QGuiApplication::tr("Use mock data source for testing."));
	parser.addOption(mockMode);
	optionList << mockMode;

	QCommandLineOption mockConfig({ "mc", "mock-conf" },
		QGuiApplication::tr("Name of mock configuration"),
		QGuiApplication::tr("mockConfig", "Configuration name"));
	mockConfig.setDefaultValue("maximal");
	parser.addOption(mockConfig);
	optionList << mockConfig;

	QCommandLineOption noMockTimers("no-mock-timers",
		QGuiApplication::tr("Set to disable mock timers on startup"));
	parser.addOption(noMockTimers);
	optionList << noMockTimers;

	QCommandLineOption nodeRedUrl("nodeRedUrl",
		QGuiApplication::tr("Node-RED URL"),
		QGuiApplication::tr("url", "Node-RED URL"));
	parser.addOption(nodeRedUrl);
	optionList << nodeRedUrl;

	QCommandLineOption signalKUrl("signalKUrl",
		QGuiApplication::tr("Signal K URL"),
		QGuiApplication::tr("url", "Signal K URL"));
	parser.addOption(signalKUrl);
	optionList << signalKUrl;

	QCommandLineOption colorScheme("colorScheme",
		QGuiApplication::tr("Color scheme (dark, light, auto, default)"),
		QGuiApplication::tr("scheme", "Color scheme value"));
	parser.addOption(colorScheme);
	optionList << colorScheme;


	// parser.setUnknownOptionMode(QCommandLineParser::IgnoreUnknownOptions); did not work
	// in Qt 6.8.3, so we manually filter the arguments.
	// Build a set of all valid option names (including short and long forms)
	QSet<QString> validOptions;
	for (const QCommandLineOption &opt : optionList) {
		for (const QString &name : opt.names()) {
			// Options can be specified with either a single dash or double dash
			validOptions.insert("-" + name);
			validOptions.insert("--" + name);
		}
	}

	// Filter arguments: skip unknown options and all their values
	QStringList filteredArgs;
	const QStringList args = QCoreApplication::arguments();
	for (int i = 0; i < args.size(); ++i) {
		const QString &arg = args.at(i);
		if (arg.startsWith('-')) {
			QString optName = arg;
			int eq = optName.indexOf('=');
			if (eq > 0)
				optName = optName.left(eq);
			if (!validOptions.contains(optName)) {
				// Skip this unknown option and all following values until next option or end
				while (i + 1 < args.size() && !args.at(i + 1).startsWith('-'))
					++i;
				continue;
			}
		}
		filteredArgs << arg;
	}

	// If the original command line arguments and the filtered arguments differ,
	// print the original, filtered and removed arguments.
	if (filteredArgs.size() != args.size()) {
		qWarning() << "Unknown command line arguments were filtered out!";
		qInfo() << "|- Original:" << args.join(' ');
		qInfo() << "|- Filtered:" << filteredArgs.join(' ');

		QStringList removed, added;
		for (const QString &arg : args) {
			if (!filteredArgs.contains(arg)) {
				removed << arg;
			}
		}
		qInfo() << "|- Removed:" << removed.join(' ');
	}

	parser.process(filteredArgs);

	if (parser.isSet(mqttAddress) || parser.isSet(mqttPortalId)) {
		if (parser.isSet(mqttUser)) {
			backend->setUsername(parser.value(mqttUser));
		}
		if (parser.isSet(mqttPass)) {
			backend->setPassword(parser.value(mqttPass));
		}
		if (parser.isSet(mqttToken)) {
			backend->setToken(parser.value(mqttToken));
		}
		if (parser.isSet(mqttPortalId)) {
			backend->setPortalId(parser.value(mqttPortalId));
		}
		if (parser.isSet(mqttShard)) {
			backend->setShard(parser.value(mqttShard));
		}
	}
	if (parser.isSet(mqttAddress)) {
		backend->setType(Victron::VenusOS::BackendConnection::MqttSource, parser.value(mqttAddress));
	} else if (parser.isSet(mqttShard)) {
		const QString shard = parser.value(mqttShard);
		if (shard.compare(QStringLiteral("vrm"), Qt::CaseInsensitive) == 0) {
			// use the VRM API to determine the shard / address
			backend->loginVrmApi();
		} else {
			// append the provided string directly as the shard value
			backend->setType(Victron::VenusOS::BackendConnection::MqttSource, calculateMqttAddressFromShard(shard));
		}
	} else if (parser.isSet(mqttPortalId)) {
		backend->setType(Victron::VenusOS::BackendConnection::MqttSource, calculateMqttAddressFromPortalId(parser.value(mqttPortalId)));
	} else if (parser.isSet(mockMode)) {
		backend->setType(Victron::VenusOS::BackendConnection::MockSource);
		const QString configName = parser.value(mockConfig);
		Victron::VenusOS::MockManager::create()->setTimersActive(!parser.isSet(noMockTimers));
		Victron::VenusOS::MockManager::create()->loadConfiguration(QString(":/data/mock/conf/%1.json").arg(configName));
	} else {
#if defined(VENUS_WEBASSEMBLY_BUILD)
		backend->setUsername(queryMqttUser);
		backend->setPassword(queryMqttPass);
		backend->setToken(queryMqttToken);
		backend->setPortalId(queryMqttPortalId);
		backend->setShard(queryMqttShard);
		if (!queryMqttShard.isEmpty()) {
			if (queryMqttShard.compare(QStringLiteral("vrm"), Qt::CaseInsensitive) == 0) {
				// use the VRM API to determine the shard / address
				backend->loginVrmApi();
			} else {
				// append the provided string directly as the shard value
				backend->setType(Victron::VenusOS::BackendConnection::MqttSource, calculateMqttAddressFromShard(queryMqttShard));
			}
		} else if (!queryMqttPortalId.isEmpty()) {
			backend->setType(Victron::VenusOS::BackendConnection::MqttSource, calculateMqttAddressFromPortalId(queryMqttPortalId));
		} else {
			backend->setType(Victron::VenusOS::BackendConnection::MqttSource, queryMqttAddress);
		}
#else
		const QString address = parser.isSet(dbusDefault) ? QStringLiteral("tcp:host=localhost,port=3000") : parser.value(dbusAddress);
		backend->setType(Victron::VenusOS::BackendConnection::DBusSource, address);
#endif
	}

	if (parser.isSet(fpsCounter) || queryFpsCounter.contains(QStringLiteral("enable"))) {
		*enableFpsCounter = true;
	}
	if (parser.isSet(skipSplash)) {
		*skipSplashScreen = true;
	}
	if (parser.isSet(nodeRedUrl)) {
		backend->setNodeRedUrl(parser.value(nodeRedUrl));
	} else if (!queryNodeRedUrl.isEmpty()) {
		backend->setNodeRedUrl(queryNodeRedUrl);
	}
	if (parser.isSet(signalKUrl)) {
		backend->setSignalKUrl(parser.value(signalKUrl));
	} else if (!querySignalKUrl.isEmpty()) {
		backend->setSignalKUrl(querySignalKUrl);
	}

	QString colorSchemeValue = QString("default");
	if (parser.isSet(colorScheme)) {
		colorSchemeValue = parser.value(colorScheme).toLower();
	} else if (!queryColorScheme.isEmpty()) {
		colorSchemeValue = queryColorScheme.toLower();
	}

	Victron::VenusOS::Theme::ForcedColorScheme forcedScheme;
	if (colorSchemeValue == "dark") {
		forcedScheme = Victron::VenusOS::Theme::ForcedColorSchemeDark;
	} else if (colorSchemeValue == "light") {
		forcedScheme = Victron::VenusOS::Theme::ForcedColorSchemeLight;
	} else if (colorSchemeValue == "auto") {
		forcedScheme = Victron::VenusOS::Theme::ForcedColorSchemeAuto;
	} else { // default
		forcedScheme = Victron::VenusOS::Theme::ForcedColorSchemeDefault;
	}
	Victron::VenusOS::ThemeSingleton *theme = Victron::VenusOS::ThemeSingleton::create();
	theme->setForcedColorScheme(forcedScheme);

	// Initialize main models
	Victron::VenusOS::AllServicesModel::create();
}

} // namespace

#if defined(VENUS_WEBASSEMBLY_BUILD)

EM_JS(const char *, getLocationHrefUtf8, (), {
	let locationString = location.href;
	let length = lengthBytesUTF8(locationString) + 1;
	let locationUtf8 = _malloc(length);
	stringToUTF8(locationString, locationUtf8, length);
	return locationUtf8;
});

EM_JS(int, getWindowInnerWidth, (), {
	return window.innerWidth;
});

EM_JS(int, getWindowInnerHeight, (), {
	return window.innerHeight;
});

EM_JS(void, setContentEditable, (bool editable), {
	// Work-around Qt Android issue where keyboard constantly pops up (see QTBUG-88803)
	const android = /Android/i.test(navigator.userAgent);
	if (android) {
		const inputs = document.querySelectorAll('input[type="text"]');
		for (let i = 0; i < inputs.length; i++) {
			const input = inputs[i];
			const rect = input.getBoundingClientRect();

			// Qt <input> has no identifier so identify using off-screen co-ordinates.
			if (rect.x === -1000 && rect.y === -1000) {
				input.style.visibility = editable ? "visible" : "hidden";
				if (editable) {
					input.focus();
				}
			}
		}
	}
});

EM_JS(bool, hasNativeVirtualKeyboard, (), {
	// Not the best way to test for whether gui-v2 is running in a mobile browser that has its own
	// VKB, but once QTBUG-128406 is fixed, the wasm keyboard handler can be removed.
	return /Android|iPad|iPhone/i.test(navigator.userAgent)
		   // Newer iPads use a Macintosh user agent, so need a hacky test here.
		|| (/Macintosh/i.test(navigator.userAgent) && navigator.maxTouchPoints && navigator.maxTouchPoints > 1);
});

#endif

int main(int argc, char *argv[])
{
	qInfo().nospace() << "Victron gui version: v" << PROJECT_VERSION_MAJOR << "." << PROJECT_VERSION_MINOR << "." << PROJECT_VERSION_PATCH;

	// Must set the default QSurfaceFormat before creating the app object.
	QSurfaceFormat surfaceFormat;
	surfaceFormat.setDepthBufferSize(24);
	surfaceFormat.setStencilBufferSize(8);
#if defined(VENUS_GX_BUILD_ARM) || defined(VENUS_WEBASSEMBLY_BUILD)
	// CerboGX and WASM don't support multisample render buffers; other platforms do.
	surfaceFormat.setSamples(-1);
	Victron::VenusOS::BackendConnection::create()->setMsaaEnabled(false);
#else
	surfaceFormat.setSamples(4);
#endif
	QSurfaceFormat::setDefaultFormat(surfaceFormat);
#if defined(VENUS_GX_BUILD_AARCH64)
	// Shader disk cache doesn't work properly on new hardware.
	QCoreApplication::setAttribute(Qt::AA_DisableShaderDiskCache);
#endif

#if !defined(VENUS_WEBASSEMBLY_BUILD) && !defined(VENUS_DESKTOP_BUILD)
	// The qt vkb behaves in an annoying manner in qt6.5.2 wasm builds (but not other versions).
	// It pops up every time you tap the screen, making landscape mode unusable.
	// The native vkb gets used instead, so a keyboard is still available when required.
	qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
#endif

	qreal scaleFactor = 1.0;

#if defined(VENUS_WEBASSEMBLY_BUILD)
	// Take both portrait and landscape into account since the
	// user can rotate the screen while the app is running
	qreal width = qMax(getWindowInnerWidth(), getWindowInnerHeight());
	qreal height = qMin(getWindowInnerWidth(), getWindowInnerHeight());

	if (width > 0 && height > 0) {
		Victron::VenusOS::ThemeSingleton *theme = Victron::VenusOS::ThemeSingleton::create();
		scaleFactor = qMax(1.0, qMin(width/theme->geometry_screen_width(), height/theme->geometry_screen_height()));
	}

	Victron::VenusOS::BackendConnection::create()->setNeedsWasmKeyboardHandler(hasNativeVirtualKeyboard());
#endif

	std::string scaleAsString = std::to_string(scaleFactor);
	QByteArray scaleAsQByteArray(scaleAsString.c_str(), scaleAsString.length());
	qputenv("QT_SCALE_FACTOR", scaleAsQByteArray);

	QGuiApplication app(argc, argv);
	QGuiApplication::setApplicationName("Venus");
	QGuiApplication::setApplicationVersion("2.0");

	QGuiApplication::styleHints()->setWheelScrollLines(5);

	bool enableFpsCounter = false;
	bool skipSplashScreen = false;

	QQmlEngine engine;
#if VENUS_GX_BUILD
	engine.addUrlInterceptor(new Victron::VenusOS::UrlInterceptor());
#endif
	QZXing::registerQMLTypes();
	QZXing::registerQMLImageProvider(engine);

	initBackend(&enableFpsCounter, &skipSplashScreen);
	QObject::connect(&engine, &QQmlEngine::quit, &app, &QGuiApplication::quit);

	/* Force construction of translator */
	Victron::VenusOS::Language *languageLoader = Victron::VenusOS::Language::create(&engine);
	QObject::connect(languageLoader, &Victron::VenusOS::Language::currentLanguageChanged,
		&engine, &QQmlEngine::retranslate);
#if defined(VENUS_WEBASSEMBLY_BUILD)
	const QUrl currentLocation(QString::fromUtf8(getLocationHrefUtf8()));
	const QString fontUrlPrefix = currentLocation.host().contains(QStringLiteral("vrm.victronenergy.com"))
		? QStringLiteral("https://updates.victronenergy.com/fonts/") // VRM specific fonts location
		: QStringLiteral("%1://%2%3/fonts/")
			.arg(currentLocation.scheme(),
				currentLocation.host(),
				currentLocation.port() >= 0 ? QStringLiteral(":%1").arg(currentLocation.port()) : QString());
	languageLoader->setFontUrlPrefix(fontUrlPrefix);
#endif
	languageLoader->init(); // load the translation catalogue.

	/* Force construction of fps counter */
	Victron::VenusOS::FrameRateModel* fpsCounter = Victron::VenusOS::FrameRateModel::create();

	QQmlComponent component(&engine, QUrl(QStringLiteral("qrc:/venus-gui-v2/Main.qml")));
	if (component.isError()) {
		qWarning() << component.errorString();
		return EXIT_FAILURE;
	}

	QScopedPointer<QObject> object(component.beginCreate(engine.rootContext()));
	const auto window = qobject_cast<QQuickWindow *>(object.data());

#if defined(VENUS_WEBASSEMBLY_BUILD)
	QObject::connect(window, &QQuickWindow::activeFocusItemChanged, [window] {
		const bool editable = window->activeFocusItem() != nullptr && (window->activeFocusItem()->flags() & QQuickItem::ItemAcceptsInputMethod);
		setContentEditable(editable);
	});
#endif

	if (!window) {
		component.completeCreate();
		qWarning() << "The scene root item is not a window." << object.data();
		return EXIT_FAILURE;
	}

	fpsCounter->setWindow(window);
	fpsCounter->setEnabled(enableFpsCounter);

	engine.setIncubationController(window->incubationController());

	/* Write to window properties here to perform any additional initialization
	   before initial binding evaluation. */
	component.completeCreate();

	if (skipSplashScreen) {
		QMetaObject::invokeMethod(window, "skipSplashScreen");
	}

#if defined(VENUS_DESKTOP_BUILD)
	const bool desktop(true);
#else
	const bool desktop(QGuiApplication::primaryScreen()->availableSize().height() > 600);
#endif

	window->setProperty("scaleFactor", scaleFactor);
	if (desktop) {
		window->setProperty("isDesktop", true);
		window->show();
	} else {
		window->showFullScreen();
	}

	return app.exec();
}
