/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "camperdataprovider.h"

int main(int argc, char *argv[])
{
	qputenv("QT_QUICK_CONTROLS_STYLE", QByteArray("Basic"));

	QGuiApplication app(argc, argv);
	app.setApplicationName(QStringLiteral("camperview"));
	app.setOrganizationName(QStringLiteral("VictronEnergy"));

	QQmlApplicationEngine engine;
	CamperDataProvider provider;
	engine.rootContext()->setContextProperty(QStringLiteral("camperDataProvider"), &provider);

	QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app,
			[]() { QCoreApplication::exit(-1); },
			Qt::QueuedConnection);

	engine.loadFromModule(QStringLiteral("CamperView"), QStringLiteral("Main"));
	return app.exec();
}
