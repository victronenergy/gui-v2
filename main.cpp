/*
** Copyright (C) 2021 Victron Energy B.V.
*/

#include "language.h"
#include "logging.h"
#include "theme.h"

#include <velib/qt/v_busitems.h>
#include <velib/qt/ve_qitems_dbus.hpp>

#include <QTranslator>
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
		[](QQmlEngine *, QJSEngine *) -> QObject* {
			return new Victron::VenusOS::Theme;
		});

	/* components */
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/Arc.qml")),
		"Victron.VenusOS", 2, 0, "Arc");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ArcGauge.qml")),
		"Victron.VenusOS", 2, 0, "ArcGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ActionButton.qml")),
		"Victron.VenusOS", 2, 0, "ActionButton");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/Button.qml")),
		"Victron.VenusOS", 2, 0, "Button");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/CircularMultiGauge.qml")),
		"Victron.VenusOS", 2, 0, "CircularMultiGauge");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ComboBox.qml")),
		"Victron.VenusOS", 2, 0, "ComboBox");
	qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/components/Gauges.qml")),
		"Victron.VenusOS", 2, 0, "Gauges");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/Label.qml")),
		"Victron.VenusOS", 2, 0, "Label");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/NavBar.qml")),
		"Victron.VenusOS", 2, 0, "NavBar");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/NavButton.qml")),
		"Victron.VenusOS", 2, 0, "NavButton");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/ProgressArc.qml")),
		"Victron.VenusOS", 2, 0, "ProgressArc");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/RadioButton.qml")),
		"Victron.VenusOS", 2, 0, "RadioButton");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/SegmentedButtonRow.qml")),
		"Victron.VenusOS", 2, 0, "SegmentedButtonRow");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/Slider.qml")),
		"Victron.VenusOS", 2, 0, "Slider");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/SpinBox.qml")),
		"Victron.VenusOS", 2, 0, "SpinBox");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/Switch.qml")),
		"Victron.VenusOS", 2, 0, "Switch");
	qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/components/VenusFont.qml")),
		"Victron.VenusOS", 2, 0, "VenusFont");
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/WeatherDetails.qml")),
		"Victron.VenusOS", 2, 0, "WeatherDetails");

	qmlRegisterType<VeQuickItem>("Victron.Velib", 1, 0, "VeQuickItem");

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

	/* Load appropriate translations, e.g. :/i18n/venus-gui-v2_fr.qm */
	QTranslator translator;
	if (translator.load(
		QLocale(),
		QLatin1String("venus-gui-v2"),
		QLatin1String("_"),
		QLatin1String(":/i18n"))) {
		QCoreApplication::installTranslator(&translator);
		qCDebug(venusGui) << "Successfully loaded translations for locale" << QLocale().name();
	} else {
		qCWarning(venusGui) << "Unable to load translations for locale" << QLocale().name();
	}

	QQmlEngine engine;
	qmlRegisterSingletonType<Victron::VenusOS::Language>(
		"Victron.VenusOS", 2, 0, "Language",
		[](QQmlEngine *engine, QJSEngine *) -> QObject* {
			return new Victron::VenusOS::Language(engine);
		});

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
