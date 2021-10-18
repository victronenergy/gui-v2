/*
** Copyright (C) 2021 Victron Energy B.V.
*/

#include "logging.h"
#include "theme.h"

#include <QTranslator>
#include <QGuiApplication>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQuickWindow>

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
	qmlRegisterType(QUrl(QStringLiteral("qrc:/components/CircularMultiGauge.qml")),
		"Victron.VenusOS", 2, 0, "CircularMultiGauge");

	QGuiApplication app(argc, argv);

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
	window->show();
#else
	window->showFullScreen();
#endif
	return app.exec();
}
