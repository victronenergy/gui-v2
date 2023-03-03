/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property string uniqueId
	readonly property string bindPrefix: "com.victronenergy.settings/Settings/Fronius/Inverters/" + uniqueId
	readonly property int phaseCount: phaseCountItem.valid ? phaseCountItem.value : 1

	DataPoint {
		id: phaseCountItem

		source: bindPrefix + "/PhaseCount"
	}

	DataPoint {
		id: phaseItem

		source: bindPrefix + "/Phase"
	}

	GradientListView {
		model: ObjectModel {
			ListRadioButtonGroup {
				text: CommonWords.position
				source: bindPrefix + "/Position"
				optionModel: [
					{ display: CommonWords.ac_input_1, value: 0 },
					{ display: CommonWords.ac_input_2, value: 2 },
					{ display: CommonWords.ac_output, value: 1 },
				]
			}

			ListTextItem {
				text: CommonWords.phase
				//% "Multiphase"
				secondaryText: qsTrId("page_settings_fronius_inverter_multiphase")
				visible: phaseCount > 1
			}

			ListRadioButtonGroup {
				text: CommonWords.phase
				source: bindPrefix + "/Phase"
				visible: phaseCount === 1
				optionModel: [
					//% "L1"
					{ display: qsTrId("page_settings_fronius_inverter_l1"), value: 1 },
					//% "L2"
					{ display: qsTrId("page_settings_fronius_inverter_l2"), value: 2 },
					//% "L3"
					{ display: qsTrId("page_settings_fronius_inverter_l3"), value: 3 },
					//% "Split-phase (L1+L2)"
					{ display: qsTrId("page_settings_fronius_inverter_split_phase"), value: 0 }
				]
			}

			ListRadioButtonGroup {
				//% "Show"
				text: qsTrId("page_settings_fronius_inverter_show")
				source: bindPrefix + "/IsActive"
				optionModel: [
					{ display: CommonWords.no, value: 0 },
					{ display: CommonWords.yes, value: 1 }
				]
			}
		}
	}
}
