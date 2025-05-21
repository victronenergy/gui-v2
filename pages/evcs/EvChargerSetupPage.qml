/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	required property string bindPrefix

	GradientListView {
		model: VisibleItemModel {
			ListAcInPositionRadioButtonGroup {
				bindPrefix: root.bindPrefix
			}

			ListSwitch {
				//% "Autostart"
				text: qsTrId("evcs_autostart")
				dataItem.uid: root.bindPrefix + "/AutoStart"
			}

			ListSwitch {
				//% "Lock charger display"
				text: qsTrId("evcs_lock_charger_display")
				dataItem.uid: root.bindPrefix + "/EnableDisplay"
				invertSourceValue: true
				preferredVisible: dataItem.valid
			}
		}
	}
}
