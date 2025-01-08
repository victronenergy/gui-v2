/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QtQml/QQmlEngine>
#include "alloweditemmodel.h"

int main(int argc, char **argv) \
{
    qmlRegisterType<Victron::VenusOS::AllowedItemModel>("Victron.VenusOS", 2, 0, "AllowedItemModel");

    QTEST_SET_MAIN_SOURCE_PATH
    return quick_test_main(argc, argv, "tst_visibleitemmodel", nullptr);
}
