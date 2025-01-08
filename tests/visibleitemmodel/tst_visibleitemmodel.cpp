/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QtQml/QQmlEngine>
#include "visibleitemmodel.h"

int main(int argc, char **argv) \
{
    qmlRegisterType<Victron::VenusOS::VisibleItemModel>("Victron.VenusOS", 2, 0, "VisibleItemModel");

    QTEST_SET_MAIN_SOURCE_PATH
    return quick_test_main(argc, argv, "tst_visibleitemmodel", nullptr);
}
