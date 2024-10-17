/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include "backendconnection.h"

int main(int argc, char **argv) \
{
	Victron::VenusOS::BackendConnectionTester backendConnectionTester;

	QTEST_SET_MAIN_SOURCE_PATH
	return quick_test_main_with_setup(argc, argv, "tst_backendconnection", nullptr, &backendConnectionTester);
}
