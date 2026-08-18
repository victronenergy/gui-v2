/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>

int main(int argc, char **argv)
{
	QTEST_SET_MAIN_SOURCE_PATH
	return quick_test_main(argc, argv, "tst_delegatecomponentmodel", "../tests/delegatecomponentmodel/");
}
