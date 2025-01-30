/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QtQml/QQmlEngine>
#include "quantityobject.h"
#include "quantityobjectmodel.h"

int main(int argc, char **argv) \
{
    qmlRegisterType<Victron::VenusOS::QuantityObject>("Victron.VenusOS", 2, 0, "QuantityObject");
    qmlRegisterType<Victron::VenusOS::QuantityObjectModel>("Victron.VenusOS", 2, 0, "QuantityObjectModel");

    QTEST_SET_MAIN_SOURCE_PATH
    return quick_test_main(argc, argv, "tst_quantityobjectmodel", nullptr);
}
