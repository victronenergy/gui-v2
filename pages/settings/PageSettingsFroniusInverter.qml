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
	readonly property int phaseCount: phaseCountItem.isValid ? phaseCountItem.value : 1

	VeQuickItem {
		id: phaseCountItem

		uid: bindPrefix + "/PhaseCount"
	}

	VeQuickItem {
		id: phaseItem

		uid: bindPrefix + "/Phase"
	}

	GradientListView {
		model: ObjectModel {
			PvInverterPositionRadioButtonGroup {
				dataItem.uid: bindPrefix + "/Position"
			}

			ListTextItem {
				text: CommonWords.phase
				//% "Multiphase"
				secondaryText: qsTrId("page_settings_fronius_inverter_multiphase")
				visible: phaseCount > 1
			}

			ListRadioButtonGroup {
				text: CommonWords.phase
				dataItem.uid: bindPrefix + "/Phase"
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

			ListRadioButtonGroupNoYes {
				//% "Show"
				text: qsTrId("page_settings_fronius_inverter_show")
				dataItem.uid: bindPrefix + "/IsActive"
			}
		}
	}
}
