/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property bool _isGrid: acInput1.currentIndex === 1 || acInput2.currentIndex === 1
	property bool _isShore: acInput1.currentIndex === 3 || acInput2.currentIndex === 3

	property var _acInputsModel: [
		{ display: CommonWords.not_available, value: 0 },
		//% "Grid"
		{ display: qsTrId("settings_system_grid"), value: 1 },
		{ display: CommonWords.generator, value: 2 },
		//% "Shore power"
		{ display: qsTrId("settings_system_shore_power"), value: 3 },
	]

	VeQuickItem {
		id: hasAcOutLoadsItem

		uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasAcOutSystem"
	}

	VeQuickItem {
		id: hasAcInLoadsItem

		uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasAcInLoads"
	}

	GradientListView {
		model: AllowedItemModel {
			ListRadioButtonGroup {
				id: acInput1

				//% "AC input 1"
				text: qsTrId("settings_system_ac_input_1")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/AcInput1"
				optionModel: root._acInputsModel
			}

			ListRadioButtonGroup {
				id: acInput2

				//% "AC input 2"
				text: qsTrId("settings_system_ac_input_2")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/AcInput2"
				optionModel: root._acInputsModel
			}

			ListRadioButtonGroup {
				//% "Position of AC loads"
				text: qsTrId("settings_system_ac_position")
				currentIndex: (hasAcInLoadsItem.value === 1 ? 1 : 0) + (
					hasAcOutLoadsItem.value === 1 ? 2 : 0) - 1
				optionModel: [
					{
						//% "AC input only"
						display: qsTrId("settings_system_ac_input_only"),
						//% "The AC output of the Inverter/Charger is not used."
						caption: qsTrId("settings_system_ac_input_only_description"),
						readOnly: !Global.system.hasEss
					},
					{
						//% "AC output only"
						display: qsTrId("settings_system_ac_output_only"),
						//% "All AC loads are on the output of the Inverter/Charger."
						caption: qsTrId("settings_system_ac_output_only_description"),
					},
					{
						//% "AC input & output"
						display: qsTrId("settings_system_ac_input_and_output"),
						//% "The system will automatically display loads on the input of the Inverter/Charger if a grid meter is present. Loads on the output are always displayed."
						caption: qsTrId("settings_system_ac_input_and_output_description"),
					},
				]

				onOptionClicked: function(index) {
					index += 1
					hasAcInLoadsItem.setValue(index & 1)
					hasAcOutLoadsItem.setValue((index & 2) >> 1)
				}
			}

			ListRadioButtonGroup {
				text: root._isGrid
					  //% "Monitor for grid failure"
					? qsTrId("settings_system_monitor_for_grid_failure")
					  //% "Monitor for shore disconnect"
					: qsTrId("settings_system_monitor_for_shore_disconnect")
				allowed: root._isGrid || root._isShore
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Alarm/System/GridLost"
				optionModel: [
					{ display: CommonWords.disabled, value: 0 },
					{ display: CommonWords.enabled, value: 1 },
				]
			}
		}
	}
}
