/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include "screenblanker.h"

template <typename T> static QObject *singletonFactory(QQmlEngine *, QJSEngine *)
{
	return new T;
}

int main(int argc, char **argv) \
{
	qmlRegisterType<Victron::VenusOS::ScreenBlanker>("Victron.VenusOS", 2, 0, "ScreenBlanker");

	QTEST_SET_MAIN_SOURCE_PATH
	return quick_test_main(argc, argv, "tst_units", nullptr);
}
