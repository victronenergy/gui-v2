/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "src/language.h"
#include "src/logging.h"
#include "src/theme.h"
#include "src/enums.h"
#include "src/notificationsmodel.h"
#include "src/basedevicemodel.h"
#include "src/aggregatedevicemodel.h"
#include "src/clocktime.h"
#include "src/uidhelper.h"
#include "src/backendconnection.h"
#include "src/frameratemodel.h"

#include "veutil/qt/ve_qitem.hpp"
#include "veutil/qt/ve_quick_item.hpp"
#include "veutil/qt/ve_qitems_mqtt.hpp"
#include "veutil/qt/ve_qitem_table_model.hpp"
#include "veutil/qt/ve_qitem_sort_table_model.hpp"
#include "veutil/qt/ve_qitem_child_model.hpp"
#include "veutil/qt/firmware_updater_data.hpp"

#if defined(VENUS_WEBASSEMBLY_BUILD)
#include "src/connman-api.h"
#else
#include "src/connman/cmtechnology.h"
#include "src/connman/cmservice.h"
#include "src/connman/cmagent.h"
#include "src/connman/cmmanager.h"
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
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQuickWindow>
#include <QCommandLineParser>

#include <QtDebug>

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

static QObject* connmanInstance(QQmlEngine *, QJSEngine *)
{
	return CmManager::instance();
}

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

void initBackend(bool *enableFpsCounter)
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
}

void registerQmlTypes()
{
	/* QML type registrations.  As we (currently) don't create an installed module,
	   we need to register them into the appropriate type namespace manually. */
/*	qmlRegisterSingletonType<Victron::VenusOS::Theme>(
		"Victron.VenusOS", 2, 0, "Theme",
		&Victron::VenusOS::Theme::instance);
	qmlRegisterSingletonType<Victron::VenusOS::BackendConnection>(
		"Victron.VenusOS", 2, 0, "BackendConnection",
		&Victron::VenusOS::BackendConnection::create);
	qmlRegisterSingletonType<Victron::VenusOS::Language>(
		"Victron.VenusOS", 2, 0, "Language",
		[](QQmlEngine *engine, QJSEngine *) -> QObject* {
			return new Victron::VenusOS::Language(engine);
		});
	qmlRegisterSingletonType<Victron::VenusOS::Enums>(
		"Victron.VenusOS", 2, 0, "VenusOS",
		&Victron::VenusOS::Enums::instance);

	qmlRegisterSingletonType<Victron::VenusOS::ActiveNotificationsModel>(
		"Victron.VenusOS", 2, 0, "ActiveNotificationsModel",
		[](QQmlEngine *, QJSEngine *) -> QObject * {
		return Victron::VenusOS::ActiveNotificationsModel::instance();
	});
	qmlRegisterSingletonType<Victron::VenusOS::HistoricalNotificationsModel>(
		"Victron.VenusOS", 2, 0, "HistoricalNotificationsModel",
		[](QQmlEngine *, QJSEngine *) -> QObject * {
		return Victron::VenusOS::HistoricalNotificationsModel::instance();
	});*/
	qmlRegisterSingletonType<Victron::VenusOS::ClockTime>(
		"Victron.VenusOS", 2, 0, "ClockTime",
		[](QQmlEngine *, QJSEngine *) -> QObject * {
		return Victron::VenusOS::ClockTime::instance();
	});
	qmlRegisterSingletonType<Victron::VenusOS::UidHelper>(
		"Victron.VenusOS", 2, 0, "UidHelper",
		&Victron::VenusOS::UidHelper::instance);
	qmlRegisterSingletonType<Victron::VenusOS::FrameRateModel>(
		"Victron.VenusOS", 2, 0, "FrameRateModel",
		&Victron::VenusOS::FrameRateModel::instance);
	qmlRegisterType<Victron::VenusOS::BaseDevice>("Victron.VenusOS", 2, 0, "BaseDevice");
	qmlRegisterType<Victron::VenusOS::BaseDeviceModel>("Victron.VenusOS", 2, 0, "BaseDeviceModel");
	qmlRegisterType<Victron::VenusOS::AggregateDeviceModel>("Victron.VenusOS", 2, 0, "AggregateDeviceModel");

	// These types do not use dbus, so are safe to import even in the Qt Wasm build.
	qmlRegisterType<VeQuickItem>("Victron.Veutil", 1, 0, "VeQuickItem");
	qmlRegisterType<VeQItem>("Victron.Veutil", 1, 0, "VeQItem");
	qmlRegisterType<VeQItemChildModel>("Victron.Veutil", 1, 0, "VeQItemChildModel");
	qmlRegisterType<VeQItemSortDelegate>("Victron.Veutil", 1, 0, "VeQItemSortDelegate");
	qmlRegisterType<VeQItemSortTableModel>("Victron.Veutil", 1, 0, "VeQItemSortTableModel");
	qmlRegisterType<VeQItemTableModel>("Victron.Veutil", 1, 0, "VeQItemTableModel");

	qmlRegisterUncreatableType<FirmwareUpdaterData>("Victron.Veutil", 1, 0, "FirmwareUpdater", "FirmwareUpdater cannot be created");

	qmlRegisterType<Victron::VenusOS::SingleUidHelper>("Victron.VenusOS", 2, 0, "SingleUidHelper");
	qmlRegisterType<Victron::VenusOS::LanguageModel>("Victron.VenusOS", 2, 0, "LanguageModel");

	qmlRegisterType<CmTechnology>("net.connman", 0, 1, "CmTechnology");
	qmlRegisterType<CmService>("net.connman", 0, 1, "CmService");
	qmlRegisterType<CmAgent>("net.connman", 0, 1, "CmAgent");
	qmlRegisterSingletonType<CmManager>("net.connman", 0, 1, "Connman", &connmanInstance);
}

} // namespace


int main(int argc, char *argv[])
{
	qInfo("Victron gui version: v%d.%d.%d", PROJECT_VERSION_MAJOR, PROJECT_VERSION_MINOR, PROJECT_VERSION_PATCH);

#if !defined(VENUS_WEBASSEMBLY_BUILD)
	// The qt vkb behaves in an annoying manner in qt6.5.2 wasm builds (but not other versions).
	// It pops up every time you tap the screen, making landscape mode unusable.
	// The native vkb gets used instead, so a keyboard is still available when required.
	qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
#endif

	registerQmlTypes();

	QGuiApplication app(argc, argv);
	QGuiApplication::setApplicationName("Venus");
	QGuiApplication::setApplicationVersion("2.0");

	bool enableFpsCounter = false;

	QQmlEngine engine;
	initBackend(&enableFpsCounter);
	engine.setProperty("colorScheme", Victron::VenusOS::Theme::Dark);
	QObject::connect(&engine, &QQmlEngine::quit, &app, &QGuiApplication::quit);

	/* Force construction of translator */
	/*
	int languageSingletonId = qmlTypeId("Victron.VenusOS", 2, 0, "Language");
	Q_ASSERT(languageSingletonId);
	(void)engine.singletonInstance<Victron::VenusOS::Language*>(languageSingletonId);
	*/

	/* Force construction of fps counter */
	int fpsCounterSingletonId = qmlTypeId("Victron.VenusOS", 2, 0, "FrameRateModel");
	Q_ASSERT(fpsCounterSingletonId);
	Victron::VenusOS::FrameRateModel* fpsCounter = engine.singletonInstance<Victron::VenusOS::FrameRateModel*>(fpsCounterSingletonId);

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

#if defined(VENUS_DESKTOP_BUILD)
	const bool desktop(true);
#else
	const bool desktop(QGuiApplication::primaryScreen()->availableSize().height() > 600);
#endif
	if (desktop) {
		window->show();
	} else {
		window->showFullScreen();
	}

	return app.exec();
}
