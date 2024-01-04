/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListTextItem {
				//% "System Switch"
				text: qsTrId("lynxionio_system_switch")
				dataItem.uid: root.bindPrefix + "/SystemSwitch"
				secondaryText: CommonWords.enabledOrDisabled(dataItem.value)
			}

			ListTextItem {
				text: CommonWords.allow_to_charge
				dataItem.uid: root.bindPrefix + "/Io/AllowToCharge"
				secondaryText: CommonWords.yesOrNo(dataItem.value)
			}

			ListTextItem {
				text: CommonWords.allow_to_discharge
				dataItem.uid: root.bindPrefix + "/Io/AllowToDischarge"
				secondaryText: CommonWords.yesOrNo(dataItem.value)
			}

			ListTextItem {
				//% "External relay"
				text: qsTrId("lynxionio_external_relay")
				dataItem.uid: root.bindPrefix + "/Io/ExternalRelay"
				visible: defaultVisible && dataItem.isValid
				secondaryText: CommonWords.activeOrInactive(dataItem.value)
			}

			ListTextItem {
				//% "Programmable Contact"
				text: qsTrId("lynxionio_programmable_contact")
				dataItem.uid: root.bindPrefix + "/Io/ProgrammableContact"
				visible: defaultVisible && dataItem.isValid
				secondaryText: CommonWords.activeOrInactive(dataItem.value)
			}
		}
	}
}
