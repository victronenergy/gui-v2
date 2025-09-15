/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string bindPrefix

	//% "Microgrid"
	title: qsTrId("microgrid")

	component MicrogridVisibleItemModel : VisibleItemModel {
		ListText {
			//% "Active mode"
			text: qsTrId("page_microgrid_active_mode")
			secondaryText: VenusOS.microgridModeToText(mode.value)
		}
	}

	component VfDirectDriveSettingsListHeader : SettingsListHeader {
		//% "V-f direct drive settings"
		text: qsTrId("page_microgrid_v_f_direct_drive_settings")
	}

	component FromAToBListText: ListText {
		property int unitType: VenusOS.Units_None
		property alias dataItemFrom: dataItemFrom
		property alias dataItemTo: dataItemTo
		property alias quantityInfoFrom: from
		property alias quantityInfoTo: to

		//% "%1 %2 to %3 %4"
		secondaryText: qsTrId("page_microgrid_from_p1_to_p2").arg(from.number).arg(Units.defaultUnitString(unitType)).arg(to.number).arg(Units.defaultUnitString(unitType))

		QuantityInfo {
			id: from
			unitType: parent && parent.unitType ? parent.unitType : VenusOS.Units_None
			value: dataItemFrom.valid ? dataItemFrom.value : NaN
		}

		QuantityInfo {
			id: to
			unitType: parent && parent.unitType ? parent.unitType : VenusOS.Units_None
			value: dataItemTo.valid ? dataItemTo.value : NaN
		}

		VeQuickItem {
			id: dataItemFrom
		}

		VeQuickItem {
			id: dataItemTo
		}
	}

	GradientListView {
		model: {
			if (! mode.valid) {
				return null
			}

			switch (mode.value) {
			case VenusOS.MicrogridMode_GridForming:
				return gridFormingModel
			case VenusOS.MicrogridMode_GridFollowing:
				return gridFollowingModel
			case VenusOS.MicrogridMode_HybridDroop:
				return hybridDroopModel
			default:
				return null
			}
		}

		MicrogridVisibleItemModel {
			id: hybridDroopModel

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
				//% "Reference Voltage (U<sub>0</sub>)"
				text: qsTrId("page_microgrid_reference_voltage")
				unit: VenusOS.Units_Volt_AC
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

			FromAToBListText {
				//% "Allowed active power range"
				text: qsTrId("page_microgrid_allowed_active_power_range")
				unitType: VenusOS.Units_Watt
				dataItemFrom.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Pmin/Value"
				dataItemTo.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/Pmax/Value"
			}

			FromAToBListText {
				//% "Allowed reactive power range"
				text: qsTrId("page_microgrid_allowed_reactive_power_range")
				unitType: VenusOS.Units_VoltAmpereReactive
				dataItemFrom.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/QMin/Value"
				dataItemTo.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/QMax/Value"
			}
		}

		MicrogridVisibleItemModel {
			id: gridFollowingModel

			VfDirectDriveSettingsListHeader {}

			ListText {
				//% "Active power setpoint (P)"
				text: qsTrId("page_microgrid_active_power_setpoint_p")
				// TODO: secondaryText:
			}

			ListText {
				//% "Reactive power setpoint (Q)"
				text: qsTrId("page_microgrid_reactive_power_setpoint_q")
				// TODO: secondaryText:
			}

			ListText {
				//% "Allowed fequency range"
				text: qsTrId("page_microgrid_allowed frequency range")
				// TODO: secondaryText:
			}

			ListText {
				//% "Allowed voltage range"
				text: qsTrId("page_microgrid_allowed voltage range")
				// TODO: secondaryText:
			}
		}

		MicrogridVisibleItemModel {
			id: gridFormingModel

			VfDirectDriveSettingsListHeader {}

			ListText {
				//% "Voltage setpoint (U)"
				text: qsTrId("page_microgrid_voltage_setpoint")
				// TODO: secondaryText:
			}

			ListText {
				//% "Frequency setpoint (f)"
				text: qsTrId("page_microgrid_frequency_setpoint")
				// TODO: secondaryText:
			}
		}

		VeQuickItem {
			id: mode
			uid: root.bindPrefix + "/Mode"
		}
	}
}
