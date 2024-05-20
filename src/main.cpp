/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "src/language.h"
#include "src/logging.h"
#include "src/backendconnection.h"
#include "src/frameratemodel.h"

#if defined(VENUS_WEBASSEMBLY_BUILD)
#include <emscripten/html5.h>
#include <emscripten/val.h>
#include <emscripten.h>
#include <QUrl>
#include <QUrlQuery>
#endif

#include <QGuiApplication>
#include <QQuickView>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQuickWindow>
#include <QCommandLineParser>
#include <QStyleHints>

#include <QtDebug>

#include "themeobjects.h"

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

	QString queryMqttAddress, queryMqttPortalId, queryMqttShard, queryMqttUser, queryMqttPass, queryMqttToken, queryFpsCounter;
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
#endif

	QCommandLineParser parser;
	parser.setApplicationDescription("Venus GUI");
	parser.addHelpOption();
	parser.addVersionOption();

	QCommandLineOption dbusAddress({ "d", "dbus" },
		QGuiApplication::tr("Use D-Bus data source: connect to the specified D-Bus address."),
		QGuiApplication::tr("address", "D-Bus address"));
	parser.addOption(dbusAddress);

	QCommandLineOption dbusDefault("dbus-default",
		QGuiApplication::tr("Use D-Bus data source: connect to the default D-Bus address"));
	parser.addOption(dbusDefault);

	// If the MQTT Address is provided, then it's a local LAN MQTT broker (e.g. the CerboGX address).
	QCommandLineOption mqttAddress({ "m", "mqtt" },
		QGuiApplication::tr("Use MQTT data source: connect to the specified MQTT broker address."),
		QGuiApplication::tr("address", "MQTT broker address"));
	parser.addOption(mqttAddress);

	// Otherwise, we need to calculate the VRM broker shard address from the portal id.
	QCommandLineOption mqttPortalId({ "i", "id" },
		QGuiApplication::tr("MQTT data source device portal id."),
		QGuiApplication::tr("portalId"));
	parser.addOption(mqttPortalId);

	QCommandLineOption mqttShard({ "s", "shard" },
		QGuiApplication::tr("MQTT VRM webhost shard"),
		QGuiApplication::tr("shard", "MQTT VRM webhost shard"));
	parser.addOption(mqttShard);

	QCommandLineOption mqttUser({ "u", "user" },
		QGuiApplication::tr("MQTT data source username"),
		QGuiApplication::tr("user", "MQTT broker username."));
	parser.addOption(mqttUser);

	QCommandLineOption mqttPass({ "p", "pass" },
		QGuiApplication::tr("MQTT data source password"),
		QGuiApplication::tr("pass", "MQTT broker password."));
	parser.addOption(mqttPass);

	QCommandLineOption mqttToken({ "t", "token" },
		QGuiApplication::tr("MQTT data source token"),
		QGuiApplication::tr("token", "MQTT broker auth token."));
	parser.addOption(mqttToken);

	QCommandLineOption fpsCounter({ "f", "fpsCounter" },
		QGuiApplication::tr("Enable FPS counter"));
	parser.addOption(fpsCounter);

	QCommandLineOption skipSplash("skip-splash",
		QGuiApplication::tr("Skip splash screen"));
	parser.addOption(skipSplash);

	QCommandLineOption mockMode({ "k", "mock" },
		QGuiApplication::tr("Use mock data source for testing."));
	parser.addOption(mockMode);

	parser.process(*QCoreApplication::instance());

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
}

} // namespace

#if defined(VENUS_WEBASSEMBLY_BUILD)

EM_JS(int, getWindowInnerWidth, (), {
  return window.innerWidth;
});

EM_JS(int, getWindowInnerHeight, (), {
  return window.innerHeight;
});

#endif

int main(int argc, char *argv[])
{
	qInfo().nospace() << "Victron gui version: v" << PROJECT_VERSION_MAJOR << "." << PROJECT_VERSION_MINOR << "." << PROJECT_VERSION_PATCH;

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
		Victron::VenusOS::ThemeSingleton theme;
		scaleFactor = qMax(1.0, qMin(width/theme.geometry_screen_width(), height/theme.geometry_screen_height()));
	}
#endif

	std::string scaleAsString = std::to_string(scaleFactor);
	QByteArray scaleAsQByteArray(scaleAsString.c_str(), scaleAsString.length());
	qputenv("QT_SCALE_FACTOR", scaleAsQByteArray);

	QGuiApplication app(argc, argv);
	QGuiApplication::setApplicationName("Venus");
	QGuiApplication::setApplicationVersion("2.0");

	QGuiApplication::styleHints()->setWheelScrollLines(5);

#if defined(VENUS_WEBASSEMBLY_BUILD)
	QObject::connect(&app, &QGuiApplication::aboutToQuit,
		&app, [] { emscripten_run_script("location.reload()"); }, Qt::QueuedConnection);
#endif

	bool enableFpsCounter = false;
	bool skipSplashScreen = false;

	QQmlEngine engine;
	initBackend(&enableFpsCounter, &skipSplashScreen);
	QObject::connect(&engine, &QQmlEngine::quit, &app, &QGuiApplication::quit);

	/* Force construction of translator */
	Victron::VenusOS::Language::create();

	/* Force construction of fps counter */
	Victron::VenusOS::FrameRateModel* fpsCounter = Victron::VenusOS::FrameRateModel::create();

	QQmlComponent component(&engine, QUrl(QStringLiteral("qrc:/venus-gui-v2/Main.qml")));
	if (component.isError()) {
		qWarning() << component.errorString();
		return EXIT_FAILURE;
	}

	QScopedPointer<QObject> object(component.beginCreate(engine.rootContext()));
	const auto window = qobject_cast<QQuickWindow *>(object.data());
	if (!window) {
		component.completeCreate();
		qWarning() << "The scene root item is not a window." << object.data();
		return EXIT_FAILURE;
	}

	fpsCounter->setWindow(window);
	fpsCounter->setEnabled(enableFpsCounter);

#if defined(VENUS_DESKTOP_BUILD)
	QSurfaceFormat format = window->format();
	format.setSamples(4); // enable MSAA
	window->setFormat(format);
#endif
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
