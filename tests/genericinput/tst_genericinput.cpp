/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QtQml/QQmlEngine>
#include "enums.h"
#include "genericinput.h"
#include "backendconnection.h"
#include "mockmanager.h"

int main(int argc, char **argv) \
{
    qmlRegisterType<Victron::VenusOS::GenericInput>("Victron.VenusOS", 2, 0, "GenericInput");
    qmlRegisterType<Victron::VenusOS::MockManager>("Victron.VenusOS", 2, 0, "MockManager");
    qmlRegisterType<Victron::VenusOS::Enums>("Victron.VenusOS", 2, 0, "VenusOS");

    QTEST_SET_MAIN_SOURCE_PATH
    Victron::VenusOS::BackendConnection::create()->setType(Victron::VenusOS::BackendConnection::MockSource);
    return quick_test_main(argc, argv, "tst_genericinput", nullptr);
}
