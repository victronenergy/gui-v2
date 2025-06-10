/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Mqtt

QtObject {
	id: root

	property var dcInputs: DcInputsImpl { }
	property var notifications: NotificationsImpl {}
	property var tanks: TanksImpl { }
}
