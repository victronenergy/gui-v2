/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QtQml/QQmlEngine>
#include "allservicesmodel.h"
#include "mockmanager.h"
#include "backendconnection.h"

int main(int argc, char **argv) \
{
    qmlRegisterType<Victron::VenusOS::AllServicesModel>("Victron.VenusOS", 2, 0, "AllServicesModel");
    qmlRegisterType<Victron::VenusOS::MockManager>("Victron.VenusOS", 2, 0, "MockManager");

    QTEST_SET_MAIN_SOURCE_PATH
    Victron::VenusOS::BackendConnection::create()->setType(Victron::VenusOS::BackendConnection::MockSource);
    return quick_test_main(argc, argv, "tst_allservicesmodel", nullptr);
}
