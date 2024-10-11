/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	readonly property int phaseCount: phaseCountItem.isValid ? phaseCountItem.value : 1

	VeQuickItem {
		id: phaseCountItem

		uid: bindPrefix + "/PhaseCount"
	}

	VeQuickItem {
		id: limiterSupportedItem

		uid: bindPrefix + "/LimiterSupported"
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
				allowed: phaseCount > 1
			}

			ListRadioButtonGroup {
				text: CommonWords.phase
				dataItem.uid: bindPrefix + "/Phase"
				allowed: phaseCount === 1
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

			ListRadioButtonGroup {
				//% "Power limiting"
				text: qsTrId("page_settings_fronius_inverter_power_limiting")
				dataItem.uid: bindPrefix + "/EnableLimiter"
				allowed: limiterSupportedItem.value === 1
				optionModel: [
					{ display: CommonWords.disabled, value: 0 },
					{ display: CommonWords.enabled, value: 1 }
				]
			}
		}
	}
}
