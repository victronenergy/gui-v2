/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_TESTUTILS_H
#define VICTRON_GUIV2_TESTUTILS_H

#include <QtQuickTest/quicktest.h>

#include <QDir>
#include <QFileInfo>
#include <QString>

// Resolve the directory containing the test QML file.
// Tries the build-tree path first (../tests/<dir>/), then the install-tree
// path (tests/<dir>/ next to the executable).  The caller can override at
// runtime with the QUICK_TEST_SOURCE_DIR environment variable or the
// -input <dir> command-line flag.
inline QString resolveTestSourceDir(const char *dirName, const char *argv0)
{
	// 1. Build-tree: use the path embedded at compile time by CMake, which is
	//    correct regardless of multi-config subdirs or macOS bundle nesting.
#ifdef VENUS_TEST_BUILD_SOURCE_DIR
	const QString buildPath = QStringLiteral(VENUS_TEST_BUILD_SOURCE_DIR);
	if (QDir(buildPath).exists()) {
		return buildPath;
	}
#endif

	// 2. Install-tree layout: QML is in tests/<dir>/ next to the executable.
	const QString exeDir = QFileInfo(QString::fromLocal8Bit(argv0)).absolutePath();
	return exeDir + QStringLiteral("/tests/%1").arg(dirName);
}

// Convenience macro for a basic unit test with no backend setup.
// Usage: #include "testutils.h"
//        VENUS_QUICK_TEST_MAIN(units)
#define VENUS_QUICK_TEST_MAIN(name) \
	int main(int argc, char **argv) \
	{ \
		QTEST_SET_MAIN_SOURCE_PATH \
		const QByteArray srcDir = resolveTestSourceDir(#name, argv[0]).toLocal8Bit(); \
		return quick_test_main(argc, argv, "tst_" #name, srcDir.constData()); \
	}

// Convenience macro for a unit test that initialises a mock backend.
// Usage: #include "backendconnection.h"
//        #include "testutils.h"
//        VENUS_MOCK_TEST_MAIN(device)
#define VENUS_MOCK_TEST_MAIN(name) \
	int main(int argc, char **argv) \
	{ \
		QTEST_SET_MAIN_SOURCE_PATH \
		Victron::VenusOS::BackendConnection::create()->setType( \
				Victron::VenusOS::BackendConnection::MockSource); \
		const QByteArray srcDir = resolveTestSourceDir(#name, argv[0]).toLocal8Bit(); \
		return quick_test_main(argc, argv, "tst_" #name, srcDir.constData()); \
	}

#endif // VICTRON_GUIV2_TESTUTILS_H
