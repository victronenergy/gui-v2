/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	property int fuseNumber
	property string bindPrefix

	readonly property string fuseName: _nameDataItem.value || ""
	readonly property int fuseStatus: _statusDataItem.value === undefined ? -1 : _statusDataItem.value
	readonly property bool blown: _statusDataItem.value === 3

	property VeQuickItem _nameDataItem: VeQuickItem {
		uid: root.bindPrefix+ "/Fuse/" + root.fuseNumber + "/Name"
	}

	property VeQuickItem _statusDataItem: VeQuickItem {
		uid: root.bindPrefix+ "/Fuse/" + root.fuseNumber + "/Status"
	}
}
