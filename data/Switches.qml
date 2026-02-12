/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	// A list of the IO channel groups on the system. A group may be:
	// - a custom named group created by the user, containing one or more IO channels
	// - a group for a particular switch device, containing all the channels on that device that do
	//   not belong to a custom named group.
	readonly property IOChannelGroupModel groups: IOChannelGroupModel {}

	Component.onCompleted: Global.switches = root
}
