/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: programmableContactItem
		uid: root.bindPrefix + "/Io/ProgrammableContact"
	}
	VeQuickItem {
		id: externalRelayItem
		uid: root.bindPrefix + "/Io/ExternalRelay"
	}
	VeQuickItem {
		id: systemSwitchItem
		uid: root.bindPrefix + "/SystemSwitch"
	}

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				preferredVisible: systemSwitchItem.valid
				ListText {
					//% "System Switch"
					text: qsTrId("lynxionio_system_switch")
					dataItem.uid: root.bindPrefix + "/SystemSwitch"
					secondaryText: CommonWords.enabledOrDisabled(dataItem.value)
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.allow_to_charge
					dataItem.uid: root.bindPrefix + "/Io/AllowToCharge"
					secondaryText: CommonWords.yesOrNo(dataItem.value)
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.allow_to_discharge
					dataItem.uid: root.bindPrefix + "/Io/AllowToDischarge"
					secondaryText: CommonWords.yesOrNo(dataItem.value)
				}
			}

			DelegateComponent {
				preferredVisible: externalRelayItem.valid
				ListText {
					//% "External relay"
					text: qsTrId("lynxionio_external_relay")
					dataItem.uid: root.bindPrefix + "/Io/ExternalRelay"
					secondaryText: CommonWords.activeOrInactive(dataItem.value)
				}
			}

			DelegateComponent {
				preferredVisible: programmableContactItem.valid
				ListText {
					//% "Programmable Contact"
					text: qsTrId("lynxionio_programmable_contact")
					dataItem.uid: root.bindPrefix + "/Io/ProgrammableContact"
					secondaryText: CommonWords.activeOrInactive(dataItem.value)
				}
			}
		}
	}
}
