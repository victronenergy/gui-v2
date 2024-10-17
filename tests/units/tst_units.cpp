/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include "units.h"
#include "quantityinfo.h"
#include "backendconnection.h"

template <typename T> static QObject *singletonFactory(QQmlEngine *, QJSEngine *)
{
	return new T;
}

int main(int argc, char **argv) \
{
	qmlRegisterType<Victron::VenusOS::Enums>("Victron.VenusOS", 2, 0, "VenusOS");
	qmlRegisterType<Victron::Units::QuantityInfo>("Victron.VenusOS", 2, 0, "QuantityInfo");
	qmlRegisterSingletonType<Victron::Units::Units>("Victron.VenusOS", 2, 0, "Units", singletonFactory<Victron::Units::Units>);

	Victron::VenusOS::BackendConnectionTester backendConnectionTester;

	QTEST_SET_MAIN_SOURCE_PATH
	return quick_test_main_with_setup(argc, argv, "tst_units", nullptr, &backendConnectionTester);
}

#include "tst_units.moc"
