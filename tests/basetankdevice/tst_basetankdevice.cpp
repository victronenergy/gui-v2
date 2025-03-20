/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QtQml/QQmlEngine>
#include "basetankdevice.h"

int main(int argc, char **argv) \
{
    qmlRegisterType<Victron::VenusOS::BaseTankDevice>("Victron.VenusOS", 2, 0, "BaseTankDevice");

    QTEST_SET_MAIN_SOURCE_PATH
    return quick_test_main(argc, argv, "tst_basetankdevice", nullptr);
}
