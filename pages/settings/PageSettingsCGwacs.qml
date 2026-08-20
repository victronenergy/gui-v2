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
	readonly property var _pvInverterPositionOptionModel: [
		{ display: CommonWords.acInputFromNumber(1), value: VenusOS.PvInverter_Position_ACInput },
		{ display: CommonWords.acInputFromNumber(2), value: VenusOS.PvInverter_Position_ACInput2 },
		{ display: CommonWords.ac_output, value: VenusOS.PvInverter_Position_ACOutput },
	]

	VeQuickItem {
		id: classAndVrmInstanceItem
		uid: devicePath + "/ClassAndVrmInstance"
	}
	VeQuickItem {
		id: isMultiPhaseItem
		uid: devicePath + "/IsMultiphase"
	}
	VeQuickItem {
		id: multiPhaseSupport
		uid: devicePath + "/SupportMultiphase"
	}

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				ListRadioButtonGroup {
					text: CommonWords.ac_input_role
					optionModel: Global.acInputs.roles.map(function(role) {
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
			}

			DelegateComponent {
				preferredVisible: root.serviceType === "pvinverter"
				ListPvInverterPositionRadioButtonGroup {
					id: positions
					dataItem.uid: root.devicePath + "/Position"
				}
			}

			DelegateComponent {
				ListRadioButtonGroup {
					//% "Phase type"
					text: qsTrId("settings_cgwacs_phase_type")
					dataItem.uid: root.devicePath + "/IsMultiphase"
					interactive: dataItem.valid && multiPhaseSupport.value !== undefined
					optionModel: [
						//% "Single phase"
						{ display: qsTrId("settings_single_phase"), value: 0},
						//% "Multi phase"
						{ display: qsTrId("settings_multi_phase"), value: 1},
					]
				}
			}

			DelegateComponent {
				id: pvOnL2DC
				dataItem: VeQuickItem { uid: root.devicePath + "_S/Enabled" }
				property bool checked: dataItem.value === 1
				preferredVisible: multiPhaseSupport.value
						 && isMultiPhaseItem.value !== undefined
						 && !isMultiPhaseItem.value
						 && root.serviceType === "grid"
				ListSwitch {
					id: pvOnL2
					//% "PV inverter on phase 2"
					text: qsTrId("settings_pv_inverter_on_phase_2")
					dataItem.uid: root.devicePath + "_S/Enabled"
				}
			}

			DelegateComponent {
				preferredVisible: pvOnL2DC.checked
				ListRadioButtonGroup {
					//% "PV inverter on phase 2 Position"
					text: qsTrId("settings_cgwacs_pv_inverter_l2_position")
					dataItem.uid: root.devicePath + "_S/Position"
					optionModel: root._pvInverterPositionOptionModel
				}
			}
		}
	}
}
