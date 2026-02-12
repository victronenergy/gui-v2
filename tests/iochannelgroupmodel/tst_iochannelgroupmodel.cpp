/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QtQml/QQmlEngine>
#include "switchableoutput.h"
#include "iochannelgroupmodel.h"
#include "backendconnection.h"
#include "mockmanager.h"

int main(int argc, char **argv) \
{
    qmlRegisterType<Victron::VenusOS::SwitchableOutput>("Victron.VenusOS", 2, 0, "SwitchableOutput");
    qmlRegisterUncreatableType<Victron::VenusOS::IOChannelGroup>("Victron.VenusOS", 2, 0, "IOChannelGroup", "");
    qmlRegisterType<Victron::VenusOS::IOChannelGroupModel>("Victron.VenusOS", 2, 0, "IOChannelGroupModel");
    qmlRegisterType<Victron::VenusOS::MockManager>("Victron.VenusOS", 2, 0, "MockManager");

    QTEST_SET_MAIN_SOURCE_PATH
    Victron::VenusOS::BackendConnection::create()->setType(Victron::VenusOS::BackendConnection::MockSource);
    return quick_test_main(argc, argv, "tst_iochannelgroupmodel", nullptr);
}
