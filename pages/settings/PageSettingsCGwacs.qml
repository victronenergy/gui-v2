/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

Page {
	id: root

	property string devicePath
	readonly property string serviceType: classAndVrmInstanceItem.value !== undefined ? classAndVrmInstanceItem.value.split(":")[0] : ""
	readonly property int deviceInstance: classAndVrmInstanceItem.value !== undefined ? classAndVrmInstanceItem.value.split(":")[1] : 0

	DataPoint {
		id: classAndVrmInstanceItem
		source: devicePath + "/ClassAndVrmInstance"
	}

	DataPoint {
		id: isMultiPhaseItem
		source: devicePath + "/IsMultiphase"
	}

	DataPoint {
		id: multiPhaseSupport
		source: devicePath + "/SupportMultiphase"
	}

	GradientListView {
		model: ObjectModel {
			ListRadioButtonGroup {
				text: CommonWords.ac_input_role
				updateOnClick: false
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

			PvInverterPositionRadioButtonGroup {
				id: positions
				dataSource: root.devicePath + "/Position"
				visible: root.serviceType === "pvinverter"
			}

			ListRadioButtonGroup {
				//% "Phase type"
				text: qsTrId("settings_cgwacs_phase_type")
				dataSource: root.devicePath + "/IsMultiphase"
				enabled: userHasWriteAccess && multiPhaseSupport.value !== undefined
				optionModel: [
					//% "Single phase"
					{ display: qsTrId("settings_single_phase"), value: 0},
					//% "Multi phase"
					{ display: qsTrId("settings_multi_phase"), value: 1},
				]
			}

			ListSwitch {
				id: pvOnL2
				//% "PV inverter on phase 2"
				text: qsTrId("settings_pv_inverter_on_phase_2")
				dataSource: root.devicePath + "_S/Enabled"
				visible: multiPhaseSupport.value
						 && isMultiPhaseItem.value !== undefined
						 && !isMultiPhaseItem.value
						 && root.serviceType === "grid"
			}

			ListRadioButtonGroup {
				//% "PV inverter on phase 2 Position"
				text: qsTrId("settings_cgwacs_pv_inverter_l2_position")
				dataSource: root.devicePath + "_S/Position"
				visible: pvOnL2.checked
				optionModel: positions.optionModel
			}
		}
	}
}
