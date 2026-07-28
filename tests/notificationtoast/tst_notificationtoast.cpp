/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include "backendconnection.h"
#include "veqitemmockproducer.h"

using namespace Victron::VenusOS;

int main(int argc, char **argv)
{
	QTEST_SET_MAIN_SOURCE_PATH
	BackendConnection::create()->setType(BackendConnection::MockSource);

	// Create the platform Notifications parent item (as venus-platform does at startup).
	// This ensures NotificationModel.init() succeeds on its first attempt.
	// Slot children are created dynamically by individual tests.
	auto *producer = qobject_cast<VeQItemMockProducer *>(BackendConnection::create()->producer());
	producer->setValue("com.victronenergy.platform/Notifications/NumberOfNotifications", 0);

	return quick_test_main(argc, argv, "tst_notificationtoast", "../tests/notificationtoast/");
}
