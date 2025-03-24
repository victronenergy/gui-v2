/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QtQml/QQmlEngine>
#include "basedevicemodel.h"
#include "aggregatedevicemodel.h"

int main(int argc, char **argv) \
{
    qmlRegisterType<Victron::VenusOS::BaseDevice>("Victron.VenusOS", 2, 0, "BaseDevice");
    qmlRegisterType<Victron::VenusOS::BaseDeviceModel>("Victron.VenusOS", 2, 0, "BaseDeviceModel");
    qmlRegisterType<Victron::VenusOS::AggregateDeviceModel>("Victron.VenusOS", 2, 0, "AggregateDeviceModel");

    QTEST_SET_MAIN_SOURCE_PATH
    return quick_test_main(argc, argv, "tst_aggregatedevicemodel", nullptr);
}
