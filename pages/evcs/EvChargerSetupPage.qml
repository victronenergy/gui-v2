/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string bindPrefix

	VeQuickItem {
		id: enableDisplayItem
		uid: root.bindPrefix + "/EnableDisplay"
	}

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				ListAcInPositionRadioButtonGroup {
					bindPrefix: root.bindPrefix
				}
			}

			DelegateComponent {
				ListSwitch {
					//% "Autostart"
					text: qsTrId("evcs_autostart")
					dataItem.uid: root.bindPrefix + "/AutoStart"
				}
			}

			DelegateComponent {
				preferredVisible: enableDisplayItem.valid
				ListSwitch {
					//% "Lock charger display"
					text: qsTrId("evcs_lock_charger_display")
					dataItem.uid: root.bindPrefix + "/EnableDisplay"
					invertSourceValue: true
				}
			}
		}
	}
}
