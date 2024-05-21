/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include "units.h"
#include "logging.h"
#include "quantityinfo.h"

// Since this is declared in logging.h, we must define it in the tests
Q_LOGGING_CATEGORY(venusGui, "venus.gui")

template <typename T> static QObject *singletonFactory(QQmlEngine *, QJSEngine *)
{
	return new T;
}

int main(int argc, char **argv) \
{
	qmlRegisterType<Victron::VenusOS::Enums>("Victron.VenusOS", 2, 0, "VenusOS");
	qmlRegisterType<Victron::Units::QuantityInfo>("Victron.VenusOS", 2, 0, "QuantityInfo");
	qmlRegisterSingletonType<Victron::Units::Units>("Victron.VenusOS", 2, 0, "Units", singletonFactory<Victron::Units::Units>);

	QTEST_SET_MAIN_SOURCE_PATH
	return quick_test_main(argc, argv, "tst_units", nullptr);
}
