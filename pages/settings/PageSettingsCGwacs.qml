/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string devicePath
	readonly property string serviceType: classAndVrmInstanceItem.value !== undefined ? classAndVrmInstanceItem.value.split(":")[0] : ""
	readonly property int deviceInstance: classAndVrmInstanceItem.value !== undefined ? classAndVrmInstanceItem.value.split(":")[1] : 0

	// PhaseCount (1 = single, 2 = split, 3 = three phase) supersedes IsMultiphase. While it is 0 (not
	// yet migrated by localsettings), dbus-cgwacs derives the phase count from IsMultiphase instead.
	readonly property bool usePhaseCount: phaseCountItem.valid && phaseCountItem.value > 0
	readonly property int phaseCount: usePhaseCount ? phaseCountItem.value : (isMultiPhaseItem.value ? 3 : 1)

	VeQuickItem {
		id: classAndVrmInstanceItem
		uid: devicePath + "/ClassAndVrmInstance"
	}

	VeQuickItem {
		id: isMultiPhaseItem
		uid: devicePath + "/IsMultiphase"
	}

	VeQuickItem {
		id: phaseCountItem
		uid: devicePath + "/PhaseCount"
	}

	VeQuickItem {
		id: multiPhaseSupport
		uid: devicePath + "/SupportMultiphase"
	}

	GradientListView {
		model: VisibleItemModel {
			ListRadioButtonGroup {
				text: CommonWords.ac_input_role
				optionModel: Services.acInputs.roles.map(function(role) {
					return { display: role.name, value: role.role }
				})
				currentIndex: {
					if (!optionModel || optionModel.length === undefined) {
						return defaultIndex
					}
					for (let i = 0; i < optionModel.length; ++i) {
						if (root.serviceType.split(":")[0] === optionModel[i].value) {
							return i
						}
					}
					return defaultIndex
				}
				onOptionClicked: function(index) {
					currentIndex = index
					classAndVrmInstanceItem.setValue(optionModel[index].value + ":" + deviceInstance)
				}
			}

			ListPvInverterPositionRadioButtonGroup {
				id: positions
				dataItem.uid: root.devicePath + "/Position"
				preferredVisible: root.serviceType === "pvinverter"
			}

			ListRadioButtonGroup {
				//% "Phase type"
				text: qsTrId("settings_cgwacs_phase_type")
				dataItem.uid: root.devicePath + "/IsMultiphase"
				interactive: dataItem.valid && !!multiPhaseSupport.value
				preferredVisible: !root.usePhaseCount
				optionModel: [
					//% "Single phase"
					{ display: qsTrId("settings_single_phase"), value: 0},
					//% "Multi phase"
					{ display: qsTrId("settings_multi_phase"), value: 1},
				]
			}

			ListRadioButtonGroup {
				text: qsTrId("settings_cgwacs_phase_type")
				dataItem.uid: root.devicePath + "/PhaseCount"
				interactive: dataItem.valid && !!multiPhaseSupport.value
				preferredVisible: root.usePhaseCount
				optionModel: [
					{ display: qsTrId("settings_single_phase"), value: 1 },
					//% "Split-phase"
					{ display: qsTrId("settings_split_phase"), value: 2 },
					//% "Three phase"
					{ display: qsTrId("settings_three_phase"), value: 3 },
				]
			}

			ListSwitch {
				id: pvOnL2
				//% "PV inverter on phase 2"
				text: qsTrId("settings_pv_inverter_on_phase_2")
				dataItem.uid: root.devicePath + "_S/Enabled"
				preferredVisible: multiPhaseSupport.value
						 && isMultiPhaseItem.valid
						 && root.phaseCount === 1
						 && root.serviceType === "grid"
			}

			ListRadioButtonGroup {
				//% "PV inverter on phase 2 position"
				text: qsTrId("settings_cgwacs_pv_inverter_l2_position")
				dataItem.uid: root.devicePath + "_S/Position"
				preferredVisible: pvOnL2.checked
				optionModel: positions.optionModel
			}
		}
	}
}
