/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "backendconnection.h"

#include "testutils.h"

#include <QCoreApplication>
#include <QDir>

namespace {
// Load the plugins that tests/plugins compiles, instead of the plugins next to the executable. An
// installed test can run without the build tree, so it has its own copy of them, in
// tests/test-plugins next to the executable. The executable's folder is only known once the
// application exists, so this runs then, which is before the plugins are loaded.
void useTestPlugins()
{
	const QString buildDir = QStringLiteral(VENUS_TEST_PLUGINS_DIR);
	const QString pluginsDir = QDir(buildDir).exists()
			? buildDir
			: QCoreApplication::applicationDirPath() + QStringLiteral("/tests/test-plugins");
	qputenv("VENUS_GUI_PLUGINS_DIR", pluginsDir.toLocal8Bit());
}
}

Q_COREAPP_STARTUP_FUNCTION(useTestPlugins)

VENUS_MOCK_TEST_MAIN(quickaccesspanecards)
