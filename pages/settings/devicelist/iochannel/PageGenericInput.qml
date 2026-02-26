/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property GenericInput genericInput

	GradientListView {
		model: VisibleItemModel {
			ListIOChannelNameField {
				dataItem.uid: root.genericInput.uid + "/Settings/CustomName"
			}

			ListIOChannelGroupField {
				dataItem.uid: root.genericInput.uid + "/Settings/Group"
			}

			ListIOChannelTypeRadioButtonGroup {
				ioChannel: root.genericInput
			}

			ListIOChannelShowRadioButtonGroup {
				dataItem.uid: root.genericInput.uid + "/Settings/ShowUIInput"
			}

			ListRadioButtonGroup {
				//% "Invert"
				text: qsTrId("page_generic_input_invert")
				writeAccessLevel: VenusOS.User_AccessType_User
				preferredVisible: dataItem.valid
				dataItem.uid: root.genericInput.uid + "/Settings/Invert"
				optionModel: [
					//% "Normal"
					{ display: qsTrId("iochannel_invert_normal"), value: 0 },
					//% "Inverted"
					{ display: qsTrId("iochannel_invert_inverted"), value: 1 },
				]
			}

			ListRadioButtonGroup {
				//% "Digital input mode"
				text: qsTrId("iochannel_digital_input_mode")
				writeAccessLevel: VenusOS.User_AccessType_User
				preferredVisible: dataItem.valid
				dataItem.uid: root.genericInput.uid + "/Settings/DigitalInputMode"
				optionModel: [
					{ display: CommonWords.disabled, value: 0 },
					//% "Digital input"
					{ display: qsTrId("iochannel_digital_input_mode_input"), value: 1 },
					//% "Toggle switch"
					{ display: qsTrId("iochannel_digital_input_mode_toggle"), value: 2 },
					//% "Press button"
					{ display: qsTrId("iochannel_digital_input_mode_press"), value: 3 },
					//% "Press and hold button"
					{ display: qsTrId("iochannel_digital_input_mode_press_and_hold"), value: 4 },
				]
			}
		}
	}
}
