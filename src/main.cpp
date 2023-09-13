/*
** Copyright (C) 2021 Victron Energy B.V.
*/

#include "src/language.h"
#include "src/logging.h"
#include "src/theme.h"
#include "src/enums.h"
#include "src/notificationsmodel.h"
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
#include <QScreen>
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
	Victron::VenusOS::BackendConnection *backend = Victron::VenusOS::BackendConnection::instance();

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
	qmlRegisterSingletonType<Victron::VenusOS::Theme>(
		"Victron.VenusOS", 2, 0, "Theme",
		&Victron::VenusOS::Theme::instance);
	qmlRegisterSingletonType<Victron::VenusOS::BackendConnection>(
		"Victron.VenusOS", 2, 0, "BackendConnection",
		&Victron::VenusOS::BackendConnection::instance);
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
	});
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

	/* data sources */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/data/DataManager.qml")),
		"Victron.VenusOS", 2, 0, "DataManager");

	/* list items */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListLabel.qml")),
		"Victron.VenusOS", 2, 0, "ListLabel");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListButton.qml")),
		"Victron.VenusOS", 2, 0, "ListButton");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListDateSelector.qml")),
		"Victron.VenusOS", 2, 0, "ListDateSelector");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListItem.qml")),
		"Victron.VenusOS", 2, 0, "ListItem");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListItemBackground.qml")),
		"Victron.VenusOS", 2, 0, "ListItemBackground");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListTextItem.qml")),
		"Victron.VenusOS", 2, 0, "ListTextItem");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListNavigationItem.qml")),
		"Victron.VenusOS", 2, 0, "ListNavigationItem");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListPortField.qml")),
		"Victron.VenusOS", 2, 0, "ListPortField");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListRadioButton.qml")),
		"Victron.VenusOS", 2, 0, "ListRadioButton");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListRadioButtonGroup.qml")),
		"Victron.VenusOS", 2, 0, "ListRadioButtonGroup");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListQuantityGroup.qml")),
		"Victron.VenusOS", 2, 0, "ListQuantityGroup");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListSlider.qml")),
		"Victron.VenusOS", 2, 0, "ListSlider");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListSpinBox.qml")),
		"Victron.VenusOS", 2, 0, "ListSpinBox");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListSwitch.qml")),
		"Victron.VenusOS", 2, 0, "ListSwitch");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListTextField.qml")),
		"Victron.VenusOS", 2, 0, "ListTextField");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListIpAddressField.qml")),
		"Victron.VenusOS", 2, 0, "ListIpAddressField");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListTextGroup.qml")),
		"Victron.VenusOS", 2, 0, "ListTextGroup");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/listitems/ListTimeSelector.qml")),
		"Victron.VenusOS", 2, 0, "ListTimeSelector");

	/* settings */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/settings/CGwacsBatteryScheduleNavigationItem.qml")),
		"Victron.VenusOS", 2, 0, "CGwacsBatteryScheduleNavigationItem");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/settings/FirmwareCheckListButton.qml")),
		"Victron.VenusOS", 2, 0, "FirmwareCheckListButton");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/settings/ListDvccSwitch.qml")),
		"Victron.VenusOS", 2, 0, "ListDvccSwitch");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/settings/MountStateListButton.qml")),
		"Victron.VenusOS", 2, 0, "MountStateListButton");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/settings/SettingsSlider.qml")),
		"Victron.VenusOS", 2, 0, "SettingsSlider");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/settings/TemperatureRelayNavigationItem.qml")),
		"Victron.VenusOS", 2, 0, "TemperatureRelayNavigationItem");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/settings/TemperatureRelaySettings.qml")),
		"Victron.VenusOS", 2, 0, "TemperatureRelaySettings");

	/* widgets */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/OverviewWidget.qml")),
		"Victron.VenusOS", 2, 0, "OverviewWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/AlternatorWidget.qml")),
		"Victron.VenusOS", 2, 0, "AlternatorWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/AcGeneratorWidget.qml")),
		"Victron.VenusOS", 2, 0, "AcGeneratorWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/DcGeneratorWidget.qml")),
		"Victron.VenusOS", 2, 0, "DcGeneratorWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/GridWidget.qml")),
		"Victron.VenusOS", 2, 0, "GridWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/ShoreWidget.qml")),
		"Victron.VenusOS", 2, 0, "ShoreWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/SolarYieldWidget.qml")),
		"Victron.VenusOS", 2, 0, "SolarYieldWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/WindWidget.qml")),
		"Victron.VenusOS", 2, 0, "WindWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/InverterWidget.qml")),
		"Victron.VenusOS", 2, 0, "InverterWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/BatteryWidget.qml")),
		"Victron.VenusOS", 2, 0, "BatteryWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/AcLoadsWidget.qml")),
		"Victron.VenusOS", 2, 0, "AcLoadsWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/DcLoadsWidget.qml")),
		"Victron.VenusOS", 2, 0, "DcLoadsWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/WidgetConnector.qml")),
		"Victron.VenusOS", 2, 0, "WidgetConnector");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/WidgetConnectorAnchor.qml")),
		"Victron.VenusOS", 2, 0, "WidgetConnectorAnchor");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/WidgetConnectorPath.qml")),
		"Victron.VenusOS", 2, 0, "WidgetConnectorPath");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/WidgetHeader.qml")),
		"Victron.VenusOS", 2, 0, "WidgetHeader");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/EvcsWidget.qml")),
		"Victron.VenusOS", 2, 0, "EvcsWidget");

	/* control cards */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/controlcards/ESSCard.qml")),
		"Victron.VenusOS", 2, 0, "ESSCard");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/controlcards/GeneratorCard.qml")),
		"Victron.VenusOS", 2, 0, "GeneratorCard");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/controlcards/InverterCard.qml")),
		"Victron.VenusOS", 2, 0, "InverterCard");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/controlcards/SwitchesCard.qml")),
		"Victron.VenusOS", 2, 0, "SwitchesCard");

	/* dialogs */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/dialogs/DateSelectorDialog.qml")),
		"Victron.VenusOS", 2, 0, "DateSelectorDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/dialogs/DialogShadow.qml")),
		"Victron.VenusOS", 2, 0, "DialogShadow");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/dialogs/DeviceInstanceSwapDialog.qml")),
		"Victron.VenusOS", 2, 0, "DeviceInstanceSwapDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/dialogs/ESSMinimumSOCDialog.qml")),
		"Victron.VenusOS", 2, 0, "ESSMinimumSOCDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/dialogs/GeneratorDisableAutostartDialog.qml")),
		"Victron.VenusOS", 2, 0, "GeneratorDisableAutostartDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/dialogs/GeneratorDurationSelectorDialog.qml")),
		"Victron.VenusOS", 2, 0, "GeneratorDurationSelectorDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/dialogs/InverterChargerModeDialog.qml")),
		"Victron.VenusOS", 2, 0, "InverterChargerModeDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/dialogs/ModalDialog.qml")),
		"Victron.VenusOS", 2, 0, "ModalDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/dialogs/ModalWarningDialog.qml")),
		"Victron.VenusOS", 2, 0, "ModalWarningDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/dialogs/NumberSelectorDialog.qml")),
		"Victron.VenusOS", 2, 0, "NumberSelectorDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/dialogs/SolarDailyHistoryDialog.qml")),
		"Victron.VenusOS", 2, 0, "SolarDailyHistoryDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/dialogs/TimeSelectorDialog.qml")),
		"Victron.VenusOS", 2, 0, "TimeSelectorDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/dialogs/VrmInstanceSwapDialog.qml")),
		"Victron.VenusOS", 2, 0, "VrmInstanceSwapDialog");

	/* pages */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/NotificationLayer.qml")),
		"Victron.VenusOS", 2, 0, "NotificationLayer");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/MainView.qml")),
		"Victron.VenusOS", 2, 0, "MainView");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/PageManager.qml")),
		"Victron.VenusOS", 2, 0, "PageManager");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/BriefMonitorPanel.qml")),
		"Victron.VenusOS", 2, 0, "BriefMonitorPanel");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/ControlCardsPage.qml")),
		"Victron.VenusOS", 2, 0, "ControlCardsPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/EnvironmentTab.qml")),
		"Victron.VenusOS", 2, 0, "EnvironmentTab");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/LevelsPage.qml")),
		"Victron.VenusOS", 2, 0, "LevelsPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/OverviewPage.qml")),
		"Victron.VenusOS", 2, 0, "OverviewPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/SettingsPage.qml")),
		"Victron.VenusOS", 2, 0, "SettingsPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/TanksTab.qml")),
		"Victron.VenusOS", 2, 0, "TanksTab");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/BriefPage.qml")),
		"Victron.VenusOS", 2, 0, "BriefPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/NotificationsPage.qml")),
		"Victron.VenusOS", 2, 0, "NotificationsPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/settings/tz/TzAfricaData.qml")),
		"Victron.VenusOS", 2, 0, "TzAfricaData");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/settings/tz/TzAmericaData.qml")),
		"Victron.VenusOS", 2, 0, "TzAmericaData");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/settings/tz/TzAntarcticaData.qml")),
		"Victron.VenusOS", 2, 0, "TzAntarcticaData");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/settings/tz/TzArcticData.qml")),
		"Victron.VenusOS", 2, 0, "TzArcticData");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/settings/tz/TzAsiaData.qml")),
		"Victron.VenusOS", 2, 0, "TzAsiaData");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/settings/tz/TzAtlanticData.qml")),
		"Victron.VenusOS", 2, 0, "TzAtlanticData");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/settings/tz/TzAustraliaData.qml")),
		"Victron.VenusOS", 2, 0, "TzAustraliaData");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/settings/tz/TzEtcData.qml")),
		"Victron.VenusOS", 2, 0, "TzEtcData");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/settings/tz/TzEuropeData.qml")),
		"Victron.VenusOS", 2, 0, "TzEuropeData");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/settings/tz/TzIndianData.qml")),
		"Victron.VenusOS", 2, 0, "TzIndianData");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/settings/tz/TzPacificData.qml")),
		"Victron.VenusOS", 2, 0, "TzPacificData");

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
	initBackend(&enableFpsCounter);

	QQmlEngine engine;
	engine.setProperty("colorScheme", Victron::VenusOS::Theme::Dark);

	/* Force construction of translator */
	int languageSingletonId = qmlTypeId("Victron.VenusOS", 2, 0, "Language");
	Q_ASSERT(languageSingletonId);
	(void)engine.singletonInstance<Victron::VenusOS::Language*>(languageSingletonId);

	/* Force construction of fps counter */
	int fpsCounterSingletonId = qmlTypeId("Victron.VenusOS", 2, 0, "FrameRateModel");
	Q_ASSERT(fpsCounterSingletonId);
	Victron::VenusOS::FrameRateModel* fpsCounter = engine.singletonInstance<Victron::VenusOS::FrameRateModel*>(fpsCounterSingletonId);

#if !defined(VENUS_WEBASSEMBLY_BUILD)
	const QSizeF physicalScreenSize = QGuiApplication::primaryScreen()->physicalSize();
	const int screenDiagonalMm = static_cast<int>(sqrt((physicalScreenSize.width() * physicalScreenSize.width())
			+ (physicalScreenSize.height() * physicalScreenSize.height())));
	engine.setProperty("screenSize", (round(screenDiagonalMm / 10 / 2.5) == 7)
			? Victron::VenusOS::Theme::SevenInch
			: Victron::VenusOS::Theme::FiveInch);
#else
	engine.setProperty("screenSize", Victron::VenusOS::Theme::SevenInch);
#endif

	QQmlComponent component(&engine, QUrl(QStringLiteral("qrc:/main.qml")));
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
