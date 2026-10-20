/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QQmlEngine>
#include <QQmlContext>
#include <QJsonDocument>
#include <QJsonObject>

#include "testutils.h"
#include "guiplugins.h"

using Victron::VenusOS::GuiPluginIntegration;
using Victron::VenusOS::GuiPluginLoader;

// Runs the plugin loader's checks on a plugin entry, as the loader reads it from a compiled
// plugin's JSON file.
class GuiPluginLoaderTestHelper : public QObject
{
	Q_OBJECT

public:
	// The Victron.GuiPlugins module version, as "major.minor". CMakeLists.txt sets it.
	Q_INVOKABLE QString guiPluginsModuleVersion() const
	{
		return QStringLiteral("%1.%2").arg(VICTRON_GUIPLUGINS_VERSION_MAJOR).arg(VICTRON_GUIPLUGINS_VERSION_MINOR);
	}

	// Runs the loader's requiredGuiPluginsVersion check on the plugin entry in pluginJson.
	Q_INVOKABLE QString checkRequiredGuiPluginsVersion(const QString &pluginJson) const
	{
		const QJsonObject plugin = QJsonDocument::fromJson(pluginJson.toUtf8()).object();
		return GuiPluginLoader::checkRequiredGuiPluginsVersion(
				plugin.value(QStringLiteral("requiredGuiPluginsVersion")));
	}

	// The types of the integrations that the loader keeps from the plugin entry in pluginJson.
	Q_INVOKABLE QVariantList integrationTypes(const QString &pluginJson) const
	{
		const QJsonObject plugin = QJsonDocument::fromJson(pluginJson.toUtf8()).object();
		QVariantList types;
		for (const GuiPluginIntegration &integration
				: GuiPluginLoader::parseIntegrations(plugin, QStringLiteral("TestPlugin"))) {
			types.append(static_cast<int>(integration.type()));
		}
		return types;
	}

public slots:
	void qmlEngineAvailable(QQmlEngine *engine)
	{
		engine->rootContext()->setContextProperty(QStringLiteral("GuiPluginLoaderTestHelper"), this);
	}
};

int main(int argc, char **argv)
{
	GuiPluginLoaderTestHelper helper;

	QTEST_SET_MAIN_SOURCE_PATH
	return quick_test_main_with_setup(argc, argv, "tst_guipluginloader",
			resolveTestSourceDir("guipluginloader", argv[0]).toLocal8Bit().constData(), &helper);
}

#include "tst_guipluginloader.moc"
