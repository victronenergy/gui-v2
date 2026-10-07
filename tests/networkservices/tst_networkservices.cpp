/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>

#include "backendconnection.h"
#include "testutils.h"

int main(int argc, char **argv)
{
	QTEST_SET_MAIN_SOURCE_PATH
	Victron::VenusOS::BackendConnection::create()->setType(Victron::VenusOS::BackendConnection::MockSource);
	const QByteArray srcDir = resolveTestSourceDir("networkservices", argv[0]).toLocal8Bit();
	return quick_test_main(argc, argv, "tst_networkservices", srcDir.constData());
}
