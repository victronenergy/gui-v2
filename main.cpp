/*
** Copyright (C) 2021 Victron Energy B.V.
*/

#include "language.h"
#include "logging.h"
#include "theme.h"

#include <math.h>

#include <velib/qt/v_busitems.h>
#include <velib/qt/ve_qitems_dbus.hpp>
#include <velib/qt/ve_qitem.hpp>

#include <QGuiApplication>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickWindow>
#include <QScreen>

#include <QtDebug>

Q_LOGGING_CATEGORY(venusGui, "venus.gui")

int main(int argc, char *argv[])
{
	/* QML type registrations.  As we (currently) don't create an installed module,
	   we need to register them into the appropriate type namespace manually. */
	qmlRegisterSingletonType<Victron::VenusOS::Theme>(
		"Victron.VenusOS", 2, 0, "Theme",
		&Victron::VenusOS::Theme::instance);
	const int languageSingletonId = qmlRegisterSingletonType<Victron::VenusOS::Language>(
		"Victron.VenusOS", 2, 0, "Language",
		[](QQmlEngine *engine, QJSEngine *) -> QObject* {
			return new Victron::VenusOS::Language(engine);
		});

	/* data sources */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/data/Battery.qml")),
		"Victron.VenusOS", 2, 0, "Battery");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/data/AcInputs.qml")),
		"Victron.VenusOS", 2, 0, "AcInputs");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/data/DcInputs.qml")),
		"Victron.VenusOS", 2, 0, "DcInputs");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/data/Ess.qml")),
		"Victron.VenusOS", 2, 0, "Ess");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/data/Generators.qml")),
		"Victron.VenusOS", 2, 0, "Generators");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/data/Inverters.qml")),
		"Victron.VenusOS", 2, 0, "Inverters");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/data/Relays.qml")),
		"Victron.VenusOS", 2, 0, "Relays");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/data/System.qml")),
		"Victron.VenusOS", 2, 0, "System");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/data/Tanks.qml")),
		"Victron.VenusOS", 2, 0, "Tanks");

	/* controls */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/Button.qml")),
		"Victron.VenusOS", 2, 0, "Button");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/ComboBox.qml")),
		"Victron.VenusOS", 2, 0, "ComboBox");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/Label.qml")),
		"Victron.VenusOS", 2, 0, "Label");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/ProgressBar.qml")),
		"Victron.VenusOS", 2, 0, "ProgressBar");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/RadioButton.qml")),
		"Victron.VenusOS", 2, 0, "RadioButton");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/Slider.qml")),
		"Victron.VenusOS", 2, 0, "Slider");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/SpinBox.qml")),
		"Victron.VenusOS", 2, 0, "SpinBox");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/controls/Switch.qml")),
		"Victron.VenusOS", 2, 0, "Switch");

	/* components */
	qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/components/Gauges.qml")),
		"Victron.VenusOS", 2, 0, "Gauges");
	qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/components/Preferences.qml")),
		"Victron.VenusOS", 2, 0, "Preferences");
	qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/components/Units.qml")),
		"Victron.VenusOS", 2, 0, "Units");
	qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/components/VenusFont.qml")),
		"Victron.VenusOS", 2, 0, "VenusFont");

	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ActionButton.qml")),
		"Victron.VenusOS", 2, 0, "ActionButton");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/Arc.qml")),
		"Victron.VenusOS", 2, 0, "Arc");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ArcGauge.qml")),
		"Victron.VenusOS", 2, 0, "ArcGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ArcGaugeValueDisplay.qml")),
		"Victron.VenusOS", 2, 0, "ArcGaugeValueDisplay");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/AsymmetricRoundedRectangle.qml")),
		"Victron.VenusOS", 2, 0, "AsymmetricRoundedRectangle");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/BarChart.qml")),
		"Victron.VenusOS", 2, 0, "BarChart");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ButtonControlValue.qml")),
		"Victron.VenusOS", 2, 0, "ButtonControlValue");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/CircularMultiGauge.qml")),
		"Victron.VenusOS", 2, 0, "CircularMultiGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/CircularSingleGauge.qml")),
		"Victron.VenusOS", 2, 0, "CircularSingleGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ControlCard.qml")),
		"Victron.VenusOS", 2, 0, "ControlCard");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ControlValue.qml")),
		"Victron.VenusOS", 2, 0, "ControlValue");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/EnvironmentGauge.qml")),
		"Victron.VenusOS", 2, 0, "EnvironmentGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/EnvironmentGaugePanel.qml")),
		"Victron.VenusOS", 2, 0, "EnvironmentGaugePanel");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ExpandedTanksView.qml")),
		"Victron.VenusOS", 2, 0, "ExpandedTanksView");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/GeneratorIconLabel.qml")),
		"Victron.VenusOS", 2, 0, "GeneratorIconLabel");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/LevelsPageGaugeDelegate.qml")),
		"Victron.VenusOS", 2, 0, "LevelsPageGaugeDelegate");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/LoadGraph.qml")),
		"Victron.VenusOS", 2, 0, "LoadGraph");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/LoadGraphShapePath.qml")),
		"Victron.VenusOS", 2, 0, "LoadGraphShapePath");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/MainView.qml")),
		"Victron.VenusOS", 2, 0, "MainView");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ModalDialog.qml")),
		"Victron.VenusOS", 2, 0, "ModalDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/NavBar.qml")),
		"Victron.VenusOS", 2, 0, "NavBar");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/NavButton.qml")),
		"Victron.VenusOS", 2, 0, "NavButton");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/Page.qml")),
		"Victron.VenusOS", 2, 0, "Page");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/PageStack.qml")),
		"Victron.VenusOS", 2, 0, "PageStack");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ProgressArc.qml")),
		"Victron.VenusOS", 2, 0, "ProgressArc");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/RadioButtonControlValue.qml")),
		"Victron.VenusOS", 2, 0, "RadioButtonControlValue");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ScaledArc.qml")),
		"Victron.VenusOS", 2, 0, "ScaledArc");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ScaledArcGauge.qml")),
		"Victron.VenusOS", 2, 0, "ScaledArcGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/SegmentedButtonRow.qml")),
		"Victron.VenusOS", 2, 0, "SegmentedButtonRow");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/SeparatorBar.qml")),
		"Victron.VenusOS", 2, 0, "SeparatorBar");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/SideGauge.qml")),
		"Victron.VenusOS", 2, 0, "SideGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/SolarYieldGauge.qml")),
		"Victron.VenusOS", 2, 0, "SolarYieldGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/SolarYieldGraph.qml")),
		"Victron.VenusOS", 2, 0, "SolarYieldGraph");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/SplashView.qml")),
		"Victron.VenusOS", 2, 0, "SplashView");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/StatusBar.qml")),
		"Victron.VenusOS", 2, 0, "StatusBar");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/SwitchControlValue.qml")),
		"Victron.VenusOS", 2, 0, "SwitchControlValue");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/TabBar.qml")),
		"Victron.VenusOS", 2, 0, "TabBar");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/TankGauge.qml")),
		"Victron.VenusOS", 2, 0, "TankGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ThreePhaseDisplay.qml")),
		"Victron.VenusOS", 2, 0, "ThreePhaseDisplay");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ToastNotification.qml")),
		"Victron.VenusOS", 2, 0, "ToastNotification");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ValueDisplay.qml")),
		"Victron.VenusOS", 2, 0, "ValueDisplay");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ValueQuantityDisplay.qml")),
		"Victron.VenusOS", 2, 0, "ValueQuantityDisplay");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/WeatherDetails.qml")),
		"Victron.VenusOS", 2, 0, "WeatherDetails");

	/* widgets */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/OverviewWidget.qml")),
		"Victron.VenusOS", 2, 0, "OverviewWidget");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/SegmentedWidgetBackground.qml")),
		"Victron.VenusOS", 2, 0, "SegmentedWidgetBackground");
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
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/VerticalGauge.qml")),
		"Victron.VenusOS", 2, 0, "VerticalGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/WidgetConnector.qml")),
		"Victron.VenusOS", 2, 0, "WidgetConnector");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/widgets/WidgetConnectorPath.qml")),
		"Victron.VenusOS", 2, 0, "WidgetConnectorPath");

	/* control cards */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/controlcards/ESSCard.qml")),
		"Victron.VenusOS", 2, 0, "ESSCard");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/controlcards/GeneratorCard.qml")),
		"Victron.VenusOS", 2, 0, "GeneratorCard");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/controlcards/InverterCard.qml")),
		"Victron.VenusOS", 2, 0, "InverterCard");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/controlcards/SwitchesCard.qml")),
		"Victron.VenusOS", 2, 0, "SwitchesCard");

	/* dialogs */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/dialogs/DialogManager.qml")),
		"Victron.VenusOS", 2, 0, "DialogManager");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/dialogs/ModalDialog.qml")),
		"Victron.VenusOS", 2, 0, "ModalDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/dialogs/ModalWarningDialog.qml")),
		"Victron.VenusOS", 2, 0, "ModalWarningDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/dialogs/InputCurrentLimitDialog.qml")),
		"Victron.VenusOS", 2, 0, "InputCurrentLimitDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/dialogs/InverterChargerModeDialog.qml")),
		"Victron.VenusOS", 2, 0, "InverterChargerModeDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/dialogs/GeneratorDisableAutostartDialog.qml")),
		"Victron.VenusOS", 2, 0, "GeneratorDisableAutostartDialog");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/dialogs/GeneratorDurationSelectorDialog.qml")),
		"Victron.VenusOS", 2, 0, "GeneratorDurationSelectorDialog");

	/* pages */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/BriefMonitorPanel.qml")),
		"Victron.VenusOS", 2, 0, "BriefMonitorPanel");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/ControlCardsPage.qml")),
		"Victron.VenusOS", 2, 0, "ControlCardsPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/EnvironmentTab.qml")),
		"Victron.VenusOS", 2, 0, "EnvironmentTab");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/LevelsPage.qml")),
		"Victron.VenusOS", 2, 0, "LevelsPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/MainPage.qml")),
		"Victron.VenusOS", 2, 0, "MainPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/OverviewPage.qml")),
		"Victron.VenusOS", 2, 0, "OverviewPage");
	qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/pages/PageManager.qml")),
		"Victron.VenusOS", 2, 0, "PageManager");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/SettingsPage.qml")),
		"Victron.VenusOS", 2, 0, "SettingsPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/TanksTab.qml")),
		"Victron.VenusOS", 2, 0, "TanksTab");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/BriefPage.qml")),
		"Victron.VenusOS", 2, 0, "BriefPage");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/pages/NotificationsPage.qml")),
		"Victron.VenusOS", 2, 0, "NotificationsPage");

	qmlRegisterType<VeQuickItem>("Victron.Velib", 1, 0, "VeQuickItem");
	qmlRegisterType<VeQItem>("Victron.Velib", 1, 0, "VeQItem");

	QGuiApplication app(argc, argv);
	QGuiApplication::setApplicationName("Venus");
	QGuiApplication::setApplicationVersion("2.0");

	QCommandLineParser parser;
	parser.setApplicationDescription("Venus GUI");
	parser.addHelpOption();
	parser.addVersionOption();

	QCommandLineOption dbusAddress({ "d",  "dbus" },
		QGuiApplication::tr("main", "Specify the D-Bus address to connect to"),
		QGuiApplication::tr("main", "dbus"));
	parser.addOption(dbusAddress);

	QCommandLineOption dbusDefault(QString("dbus-default"),
		QGuiApplication::tr("main", "Use the default D-Bus address to connect to"),
		QString(),
		QString("tcp:host=localhost,port=3000"));
	parser.addOption(dbusDefault);

	parser.process(app);

	QScopedPointer<VeQItemDbusProducer> producer(new VeQItemDbusProducer(VeQItems::getRoot(), "dbus"));
	QScopedPointer<VeQItemSettings> settings;

	if (parser.isSet(dbusAddress) || parser.isSet(dbusDefault)) {
		// Default to the session bus on the pc
		VBusItems::setConnectionType(QDBusConnection::SessionBus);
		VBusItems::setDBusAddress(parser.value(parser.isSet(dbusAddress) ? dbusAddress : dbusDefault));

		QDBusConnection dbus = VBusItems::getConnection();
		if (dbus.isConnected()) {
			producer->open(dbus);
			settings.reset(new VeQItemDbusSettings(producer->services(), QString("com.victronenergy.settings")));
		} else {
			qCritical() << "DBus connection failed.";
			exit(EXIT_FAILURE);
		}
	} else {
		producer->open(VBusItems::getConnection());
	}

	QQmlEngine engine;
	engine.setProperty("colorScheme", Victron::VenusOS::Theme::Dark);

	/* Force construction of translator */
	(void)engine.singletonInstance<Victron::VenusOS::Language*>(languageSingletonId);

	const QSizeF physicalScreenSize = QGuiApplication::primaryScreen()->physicalSize();
	const int screenDiagonalMm = sqrt((physicalScreenSize.width() * physicalScreenSize.width())
			+ (physicalScreenSize.height() * physicalScreenSize.height()));
	engine.setProperty("screenSize", (round(screenDiagonalMm / 10 / 2.5) == 7)
			? Victron::VenusOS::Theme::SevenInch
			: Victron::VenusOS::Theme::FiveInch);

	engine.rootContext()->setContextProperty("dbusConnected", VBusItems::getConnection().isConnected());

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
