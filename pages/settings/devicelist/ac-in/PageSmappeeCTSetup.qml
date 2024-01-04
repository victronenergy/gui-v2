/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

Page {
	id: root

	property string bindPrefix
	property int ctIndex
	readonly property string ctPrefix: bindPrefix + "/CT/" + ctIndex

	//: %1 = CT device number
	//% "CT %1"
	title: qsTrId("smappeect_title").arg(ctIndex + 1)

	onIsCurrentPageChanged: {
		if (isCurrentPage) {
			blink.setValue(isCurrentPage)
		}
	}

	VeQuickItem {
		id: blink
		uid: root.ctPrefix + "/Identify"
	}

	GradientListView {
		model: ObjectModel {
			ListRadioButtonGroup {
				id: type

				text: CommonWords.type
				dataItem.uid: root.ctPrefix + "/Type"

				VeQuickItem {
					uid: root.bindPrefix + "/CTTypes"
					onValueChanged: {
						type.optionModel = Utils.jsonSettingsToModel(value, true)
					}
				}
			}

			ListRadioButtonGroup {
				text: CommonWords.phase
				dataItem.uid: root.ctPrefix + "/Phase"
				optionModel: [
					//: Indicates no phase
					//% "None"
					{ display: qsTrId("smappeect_phase_none"), value: -1 },
					{ display: "L1", value: 0 },
					{ display: "L2", value: 1 },
					{ display: "L3", value: 2 },
				]
			}

			ListLabel {
				//% "Flashing LED indicates this CT"
				text: qsTrId("smappeect_flashing_led_indicates_this_ct")
				horizontalAlignment: Text.AlignHCenter
			}
		}
	}
}
