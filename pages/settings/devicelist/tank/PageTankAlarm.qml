/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Units

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListSwitch {
				//% "Enable alarm"
				text: qsTrId("devicelist_tankalarm_enable_alarm")
				dataItem.uid: root.bindPrefix + "/Enable"
			}

			ListSpinBox {
				//% "Active level"
				text: qsTrId("devicelist_tankalarm_active_level")
				dataItem.uid: root.bindPrefix + "/Active"
				from: 0
				to: 100
				suffix: "%"
			}

			ListSpinBox {
				//% "Restore level"
				text: qsTrId("devicelist_tankalarm_restore_level")
				dataItem.uid: root.bindPrefix + "/Restore"
				from: 0
				to: 100
				suffix: "%"
			}

			ListSpinBox {
				//% "Delay"
				text: qsTrId("devicelist_tankalarm_delay")
				dataItem.uid: root.bindPrefix + "/Delay"
				from: 0
				to: 100
				suffix: "s"
			}
		}
	}
}
