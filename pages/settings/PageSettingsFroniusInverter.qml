/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

Page {
	id: root

	property string bindPrefix
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
			PvInverterPositionRadioButtonGroup {
				dataSource: bindPrefix + "/Position"
			}

			ListTextItem {
				text: CommonWords.phase
				//% "Multiphase"
				secondaryText: qsTrId("page_settings_fronius_inverter_multiphase")
				visible: phaseCount > 1
			}

			ListRadioButtonGroup {
				text: CommonWords.phase
				dataSource: bindPrefix + "/Phase"
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
				dataSource: bindPrefix + "/IsActive"
				optionModel: [
					{ display: CommonWords.no, value: 0 },
					{ display: CommonWords.yes, value: 1 }
				]
			}
		}
	}
}
