/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

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

	SettingsListView {
		model: ObjectModel {
			SettingsListRadioButtonGroup {
				//% "Role"
				text: qsTrId("settings_cgwacs_role")
				updateOnClick: false
				optionModel: [
					{ display: Utils.qsTrIdServiceType("grid"), value: "grid" },
					{ display: Utils.qsTrIdServiceType("pvinverter"), value: "pvinverter" },
					{ display: Utils.qsTrIdServiceType("genset"), value: "genset" },
					//% "AC meter"
					{ display: qsTrId("settings_ac_meter"), value: "acload" } // TODO - in the old gui, a service type of 'acload' is translated differently here compared to PageSettingsCGwacsOverview. Confirm with victron that this is what they want.
				]
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

			SettingsListRadioButtonGroup {
				id: positions
				//% "Position"
				text: qsTrId("settings_position")
				source: root.devicePath + "/Position"
				visible: root.serviceType === "pvinverter"
				optionModel: [
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
				enabled: userHasWriteAccess && multiPhaseSupport.value !== undefined
				optionModel: [
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
				visible: multiPhaseSupport.value
						 && isMultiPhaseItem.value !== undefined
						 && !isMultiPhaseItem.value
						 && root.serviceType === "grid"
			}

			SettingsListRadioButtonGroup {
				//% "PV inverter on phase 2 Position"
				text: qsTrId("settings_cgwacs_pv_inverter_l2_position")
				source: root.devicePath + "_S/Position"
				visible: pvOnL2.checked
				optionModel: positions.optionModel
			}
		}
	}
}
