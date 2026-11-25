/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QGuiApplication>
#include <QQmlApplicationEngine>

#if defined(VENUS_WEBASSEMBLY_BUILD)
#include <emscripten/val.h>
#endif

#include "camperbackend.h"
#include "camperlanguage.h"

namespace {

using Victron::VenusOS::CamperBackend;

CamperBackend::Configuration configuration(const QGuiApplication &app)
{
	// Command line first: the VRM remote console passes the connection that way.
	const CamperBackend::Configuration fromArguments = CamperBackend::configurationFromArguments(app.arguments());
#if defined(VENUS_WEBASSEMBLY_BUILD)
	// Otherwise use the page URL query, for a page that loads the app with its own index.html.
	if (fromArguments.address.isEmpty()) {
		const emscripten::val location = emscripten::val::global("location");
		QString query = QString::fromStdString(location["search"].as<std::string>());
		if (query.startsWith(QLatin1Char('?'))) {
			query.remove(0, 1);
		}
		return CamperBackend::configurationFromUrlQuery(query);
	}
#endif
	return fromArguments;
}

}

int main(int argc, char *argv[])
{
	QGuiApplication app(argc, argv);
	app.setApplicationName(QStringLiteral("camperview"));
	app.setOrganizationName(QStringLiteral("VictronEnergy"));

	CamperBackend backend(configuration(app));

	QQmlApplicationEngine engine;
	Victron::VenusOS::CamperLanguage language(&engine);
	engine.setInitialProperties({
		{ QStringLiteral("backend"), QVariant::fromValue(&backend) },
		{ QStringLiteral("language"), QVariant::fromValue(&language) },
	});

	QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app,
			[]() { QCoreApplication::exit(-1); },
			Qt::QueuedConnection);

	engine.loadFromModule(QStringLiteral("CamperView"), QStringLiteral("Main"));
	return app.exec();
}
