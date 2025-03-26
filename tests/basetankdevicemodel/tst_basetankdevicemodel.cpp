/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QtQml/QQmlEngine>
#include "enums.h"
#include "basetankdevice.h"
#include "basetankdevicemodel.h"
#include "basedevicemodel.h"

int main(int argc, char **argv) \
{
    qmlRegisterType<Victron::VenusOS::Enums>("Victron.VenusOS", 2, 0, "VenusOS");
    qmlRegisterType<Victron::VenusOS::BaseTankDevice>("Victron.VenusOS", 2, 0, "BaseTankDevice");
    qmlRegisterType<Victron::VenusOS::BaseTankDeviceModel>("Victron.VenusOS", 2, 0, "BaseTankDeviceModel");
    qmlRegisterType<Victron::VenusOS::BaseDeviceModel>("Victron.VenusOS", 2, 0, "BaseDeviceModel");

    QTEST_SET_MAIN_SOURCE_PATH
    return quick_test_main(argc, argv, "tst_basetankdevicemodel", nullptr);
}
