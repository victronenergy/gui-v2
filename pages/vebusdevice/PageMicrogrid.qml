/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix // mqtt/vebus/274

	//% "Microgrid"
	title: qsTrId("microgrid")

	objectName: "PageMicrogrid"
	onBindPrefixChanged: console.log(objectName, "bindPrefix:", bindPrefix)


	GradientListView {
		model: VisibleItemModel {
			ListText {
				//% "Active mode"
				text: qsTrId("page_microgrid_active_mode")
				secondaryText: VenusOS.microgridModeToText(mode.value)
			}

			SettingsListHeader {
				//% "Hybrid droop parameters"
				text: qsTrId("page_microgrid_hybrid_droop_parameters")
			}

			ListQuantity {
				dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/P0/Value"
				textFormat: Text.RichText
				//% "Reference active power (P<sub>0</sub>)"
				text: qsTrId("page_microgrid_reference_active_power_p0")
				value: dataItem.value * 100
				unit: VenusOS.Units_Percentage
				precision: 1
			}

			ListQuantity {
				dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/F0/Value"
				textFormat: Text.RichText
				//% "Reference frequency (f<sub>0</sub>)"
				text: qsTrId("page_microgrid_reference_frequency_f0")
				unit: VenusOS.Units_Hertz
				precision: 1
			}

			ListQuantity {
				dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/FPDroop/Value"
				textFormat: Text.RichText
				//% "Frequency droop slope (droop<sub>fP</sub>)"
				text: qsTrId("page_microgrid_frequency_droop_slope")
				unit: VenusOS.Units_Percentage
				precision: 1
			}

			ListQuantity {
				dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Q0/Value"
				textFormat: Text.RichText
				//% "Reference reactive power (Q<sub>0</sub>)"
				text: qsTrId("page_microgrid_reference_reactive_power")
				unit: VenusOS.Units_Percentage
				precision: 1
			}

			ListQuantity {
				dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/U0/Value"
				textFormat: Text.RichText
				//% "Reference voltage (U<sub>0</sub>)"
				text: qsTrId("page_microgrid_reference_voltage")
				unit: VenusOS.Units_Volt_DC
				precision: 1
			}

			ListQuantity {
				dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/UQDroop/Value"
				textFormat: Text.RichText
				//% "Voltage droop slope (droop<sub>UQ</sub>)"
				text: qsTrId("page_microgrid_voltage_droop_slope")
				unit: VenusOS.Units_Percentage
				precision: 1
			}

			SettingsListHeader {
				//% "Minimum and maximum parameters"
				text: qsTrId("page_microgrid_minimum_and_maximum_parameters")
			}


			ListText {
				//% "Allowed active power range"
				text: qsTrId("page_microgrid_allowed_active_power_range")

				//% "%1 %2 to %3 %4"
				secondaryText: qsTrId("page_microgrid_from_p1_to_p2").arg(from.number).arg(from.unit).arg(to.number).arg(to.unit)

				QuantityInfo {
					id: from
					unitType: VenusOS.Units_Watt
					value: dataItemFrom.valid ? dataItemFrom.value : NaN
				}
				QuantityInfo {
					id: to
					unitType: VenusOS.Units_Watt
					value: dataItemTo.valid ? dataItemTo.value : NaN

				}
				VeQuickItem {
					id: dataItemFrom
					unit: VenusOS.Units_VoltAmpere
					uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Pmin/Value"
				}
				VeQuickItem {
					id: dataItemTo
					unit: VenusOS.Units_VoltAmpere
					uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Pmax/Value"
				}
			}

			ListText {
				//% "Allowed reactive power range"
				text: qsTrId("page_microgrid_allowed_reactive_power_range")

				secondaryText: qsTrId("page_microgrid_from_p1_to_p2").arg(from2.number).arg(from2.unit).arg(to2.number).arg(to2.unit)

				QuantityInfo {
					id: from2
					unitType: VenusOS.Units_VoltAmpere
					value: dataItemFrom2.valid ? dataItemFrom2.value : NaN
				}
				QuantityInfo {
					id: to2
					unitType: VenusOS.Units_VoltAmpere
					value: dataItemTo2.valid ? dataItemTo2.value : NaN

				}
				VeQuickItem {
					id: dataItemFrom2
					unit: VenusOS.Units_VoltAmpere
					uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/QMin/Value"
				}
				VeQuickItem {
					id: dataItemTo2
					unit: VenusOS.Units_VoltAmpere
					uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/QMax/Value"
				}
			}
		}

		//loader.status == loader.Ready && mode.valid ? loader.item : null

		VeQuickItem {
			id: mode
			uid: root.bindPrefix + "/Mode"
			onValueChanged: console.log("*********************************************** ", uid, value)
			Component.onCompleted: console.log("*********************************************** ", uid, value)
		}


		/*
		VisibleItemModel {
			id: droopModel

			ListText {
				//% "Active mode"
				text: qsTrId("page_microgrid_active_mode")
				secondaryText: VenusOS.microgridModeToText(mode.value)
			}

			SettingsListHeader {
				//% "Hybrid droop parameters"
				text: qsTrId("page_microgrid_hybrid_droop_parameters")
			}
		}

		VisibleItemModel {
			id: gridFollowingModel

			ListText {
				//% "Active mode"
				text: qsTrId("page_microgrid_active_mode")
				secondaryText: VenusOS.microgridModeToText(mode.value)
			}

			SettingsListHeader {
				//% "V-f direct drive settings"
				text: qsTrId("page_microgrid_v_f_direct_drive_settings")
			}
		}

		VisibleItemModel {
			id: gridFormingModel

			ListText {
				//% "Active mode"
				text: qsTrId("page_microgrid_active_mode")
				secondaryText: VenusOS.microgridModeToText(mode.value)
			}

			SettingsListHeader {
				text: qsTrId("page_microgrid_v_f_direct_drive_settings")
			}
		}
		*/
	}

	/*
	component MicrogridVisibleItemModel : VisibleItemModel {
		ListText {
			//% "Active mode"
			text: qsTrId("page_microgrid_active_mode")
			secondaryText: VenusOS.microgridModeToText(mode.value)
		}
	}

	component VfDirectDriveSettingsSettingsListHeader : SettingsListHeader {
		//% "V-f direct drive settings"
		text: qsTrId("page_microgrid_v_f_direct_drive_settings")
	}

	Component {
		id: droopModel

		VisibleItemModel {
			ListText {
				//% "Active mode"
				text: qsTrId("page_microgrid_active_mode")
				secondaryText: VenusOS.microgridModeToText(mode.value)
			}

			SettingsListHeader {
				//% "Hybrid droop parameters"
				text: qsTrId("page_microgrid_hybrid_droop_parameters")
			}

			ListText {
				//% "Reference power active (%1)"
				text: qsTrId("page_microgrid_reference_power_active_p0").arg("(P<sub>0</sub>)")
			}
		}
	}

	Component {
		id: gridFollowingModel

		VisibleItemModel {

			ListText {
				//% "Active mode"
				text: qsTrId("page_microgrid_active_mode")
				secondaryText: VenusOS.microgridModeToText(mode.value)
			}

			VfDirectDriveSettingsSettingsListHeader {}
		}
	}


	Component {
		id: gridFormingModel
		VisibleItemModel {

			ListText {
				//% "Active mode"
				text: qsTrId("page_microgrid_active_mode")
				secondaryText: VenusOS.microgridModeToText(mode.value)
			}

			VfDirectDriveSettingsSettingsListHeader {}
		}
	}
		Loader {
			id: loader

			sourceComponent: droopModel {
				switch (mode.value)
				{
				case VenusOS.MicrogridMode_HybridDroop:
					return droopModel
				case VenusOS.MicrogridMode_GridFollowing:
					return gridFollowingModel
				case VenusOS.MicroMicrogridMode_GridForming:
					return gridFormingModel
				default:
					return []
				}
			}
		}
	*/
}
