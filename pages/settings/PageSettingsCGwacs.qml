/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property string devicePath
	readonly property string serviceType: typeof(classAndVrmInstanceItem.value) !== undefined ? classAndVrmInstanceItem.value.split(":")[0] : ""
	readonly property int deviceInstance: typeof(classAndVrmInstanceItem.value) !== undefined ? classAndVrmInstanceItem.value.split(":")[1] : 0

	function updateRole(role) {
		classAndVrmInstanceItem.setValue(role + ":" + deviceInstance)
	}

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

	SettingsListView {
		model: 	ObjectModel {
			SettingsListRadioButtonGroup {
				id: settingsListRadioButtonGroup

				//% "Role"
				text: qsTrId("settings_cgwacs_role")
				updateOnClick: false
				model: [
					{ display: qsTrId("settings_grid_meter"), value: "grid" },
					{ display: qsTrId("settings_pv_inverter"), value: "pvinverter" },
					{ display: qsTrId("settings_generator"), value: "genset" },
					//% "AC meter"
					{ display: qsTrId("settings_ac_meter"), value: "acload" }
				]
				dataPoint.value: root.serviceType
				currentIndex: {
					if (!model || model.length === undefined) {
						return defaultIndex
					}
					for (let i = 0; i < model.length; ++i) {
						if (dataPoint.value.split(":")[0] === model[i].value) {
							return i
						}
					}
					return defaultIndex
				}
				onOptionClicked: function(index) {
					settingsListRadioButtonGroup.currentIndex = index
					updateRole(root.serviceType)
				}
			}

			SettingsListRadioButtonGroup {
				//% "Position"
				text: qsTrId("settings_position")
				source: root.devicePath + "/Position"
				visible: root.serviceType === "pvinverter"
				model: [
					//% "AC Input 1"
					{ display: qsTrId("settings_ac_input_1"), value: 0 },
					//% "AC Input 2"
					{ display: qsTrId("settings_ac_input_2"), value: 2 },
					//% "AC Output"
					{ display: qsTrId("settings_ac_output"), value: 1 },
				]
			}

			SettingsListRadioButtonGroup {
				//% "Phase type"
				text: qsTrId("settings_cgwacs_phase_type")
				source: root.devicePath + "/IsMultiphase"
				enabled: userHasWriteAccess && dataPoint.value !== undefined
				model: [
					//% "Single phase"
					{ display: qsTrId("settings_single_phase"), value: 0},
					//% "Multi phase"
					{ display: qsTrId("settings_multi_phase"), value: 1},
				]
			}

			SettingsListSwitch {
				id: pvOnL2
				//% "PV inverter on phase 2"
				text: qsTrId("settings_pv_inverter_on_phase_2")
				source: root.devicePath + "_S/Enabled"
				visible: (typeof multiPhaseSupport.value !== undefined) &&
						 multiPhaseSupport.value &&
						 (typeof isMultiPhaseItem.value !== undefined) &&
						 !isMultiPhaseItem.value &&
						 root.serviceType === "grid"
			}

			SettingsListRadioButtonGroup {
				//% "PV inverter on phase 2 Position"
				text: qsTrId("settings_cgwacs_pv_inverter_l2_position")
				source: root.devicePath + "_S/Position"
				visible: pvOnL2.checked
				model: [
					{ display: qsTrId("settings_ac_input_1"), value: 0 },
					{ display: qsTrId("settings_ac_input_2"), value: 2 },
					{ display: qsTrId("settings_ac_output"), value: 1 },
				]
			}
		}
	}
}
