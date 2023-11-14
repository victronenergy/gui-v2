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
				dataSource: root.bindPrefix + "/SystemSwitch"
				secondaryText: CommonWords.enabledOrDisabled(dataValue)
			}

			ListTextItem {
				//% "Allow to charge"
				text: qsTrId("lynxionio_allow_to_charge")
				dataSource: root.bindPrefix + "/Io/AllowToCharge"
				secondaryText: CommonWords.yesOrNo(dataValue)
			}

			ListTextItem {
				//% "Allow to discharge"
				text: qsTrId("lynxionio_allow_to_discharge")
				dataSource: root.bindPrefix + "/Io/AllowToDischarge"
				secondaryText: CommonWords.yesOrNo(dataValue)
			}

			ListTextItem {
				//% "External relay"
				text: qsTrId("lynxionio_external_relay")
				dataSource: root.bindPrefix + "/Io/ExternalRelay"
				visible: defaultVisible && dataValid
				secondaryText: CommonWords.activeOrInactive(dataValue)
			}

			ListTextItem {
				//% "Programmable Contact"
				text: qsTrId("lynxionio_programmable_contact")
				dataSource: root.bindPrefix + "/Io/ProgrammableContact"
				visible: defaultVisible && dataValid
				secondaryText: CommonWords.activeOrInactive(dataValue)
			}
		}
	}
}
