/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QCommandLineParser>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#if defined(VENUS_WEBASSEMBLY_BUILD)
#include <emscripten/val.h>
#endif

#include "camperbackend.h"

namespace {

CamperBackend::Configuration configuration(const QGuiApplication &app)
{
#if defined(VENUS_WEBASSEMBLY_BUILD)
	Q_UNUSED(app)
	const emscripten::val location = emscripten::val::global("location");
	QString query = QString::fromStdString(location["search"].as<std::string>());
	if (query.startsWith(QLatin1Char('?'))) {
		query.remove(0, 1);
	}
	return CamperBackend::configurationFromUrlQuery(query);
#else
	QCommandLineParser parser;
	parser.setApplicationDescription(QStringLiteral("Standalone RV illustration (development build)"));
	parser.addHelpOption();
	const QCommandLineOption mqtt({ "m", "mqtt" }, QStringLiteral("MQTT broker, as host[:port]."), QStringLiteral("address"));
	const QCommandLineOption id({ "i", "id" }, QStringLiteral("Portal id of the device."), QStringLiteral("portalId"));
	const QCommandLineOption user({ "u", "user" }, QStringLiteral("MQTT user name."), QStringLiteral("user"));
	const QCommandLineOption pass({ "p", "pass" }, QStringLiteral("MQTT password."), QStringLiteral("password"));
	const QCommandLineOption colorScheme("colorScheme", QStringLiteral("light or dark."), QStringLiteral("scheme"));
	parser.addOptions({ mqtt, id, user, pass, colorScheme });
	parser.process(app);

	CamperBackend::Configuration configuration;
	configuration.address = parser.value(mqtt);
	configuration.portalId = parser.value(id);
	configuration.username = parser.value(user);
	configuration.password = parser.value(pass);
	configuration.colorScheme = parser.value(colorScheme);
	return configuration;
#endif
}

}

int main(int argc, char *argv[])
{
	QGuiApplication app(argc, argv);
	app.setApplicationName(QStringLiteral("camperview"));
	app.setOrganizationName(QStringLiteral("VictronEnergy"));

	CamperBackend backend(configuration(app));

	QQmlApplicationEngine engine;
	engine.rootContext()->setContextProperty(QStringLiteral("camperBackend"), &backend);

	QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app,
			[]() { QCoreApplication::exit(-1); },
			Qt::QueuedConnection);

	engine.loadFromModule(QStringLiteral("CamperView"), QStringLiteral("Main"));
	return app.exec();
}
