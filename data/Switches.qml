/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	// A list of the switchable output groups on the system. A group may be:
	// - a custom named group created by the user, containing one or more switchable outputs
	// - a group for a particular switch device, containing all the switchable outputs on that
	// device that do not belong to a custom named group.
	readonly property SwitchableOutputGroupModel groups: SwitchableOutputGroupModel {}

	Component.onCompleted: Global.switches = root
}
