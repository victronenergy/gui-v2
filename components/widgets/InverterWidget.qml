/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	property int systemState

	//% "Inverter / Charger"
	title: qsTrId("overview_widget_inverter_title")
	icon.source: "qrc:/images/inverter_charger.svg"
	type: VenusOS.OverviewWidget_Type_Inverter

	sideGaugeVisible: true
	sideGaugeValue: 0.7 // TODO: data model
	quantityLabel.visible: false

	extraContent.children: [
		Label {
			id: statusLabel
			anchors {
				left: parent.left
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
			}
			font.pixelSize: Theme.geometry.overviewPage.widget.value.maximumFontSize

			text: {
				switch (root.systemState) {
				case VenusOS.System_State_Off:
					//: System state = 'Off'
					//% "Off"
					return qsTrId("overview_widget_state_off")
				case VenusOS.System_State_LowPower:
					//: System state = 'Low power'
					//% "Low power"
					return qsTrId("overview_widget_state_lowpower")
				case VenusOS.System_State_FaultCondition:
					//: System state = 'Fault condition'
					//% "Fault"
					return qsTrId("overview_widget_state_faultcondition")
				case VenusOS.System_State_BulkCharging:
					//: System state = 'Bulk charging'
					//% "Bulk"
					return qsTrId("overview_widget_state_bulkcharging")
				case VenusOS.System_State_AbsorptionCharging:
					//: System state = 'Absorption charging'
					//% "Absorption"
					return qsTrId("overview_widget_state_absorptioncharging")
				case VenusOS.System_State_FloatCharging:
					//: System state = 'Float charging'
					//% "Float"
					return qsTrId("overview_widget_state_floatcharging")
				case VenusOS.System_State_StorageMode:
					//: System state = 'Storage mode'
					//% "Storage"
					return qsTrId("overview_widget_state_storagemode")
				case VenusOS.System_State_EqualizationCharging:
					//: System state = 'Equalization charging'
					//% "Equalize"
					return qsTrId("overview_widget_state_equalisationcharging")
				case VenusOS.System_State_PassThrough:
					//: System state = 'Pass-thru'
					//% "Pass-thru"
					return qsTrId("overview_widget_state_passthru")
				case VenusOS.System_State_Inverting:
					//: System state = 'Inverting'
					//% "Inverting"
					return qsTrId("overview_widget_state_inverting")
				case VenusOS.System_State_Assisting:
					//: System state = 'Assisting'
					//% "Assisting"
					return qsTrId("overview_widget_state_assisting")
				case VenusOS.System_State_Discharging:
					//: System state = 'Discharging'
					//% "Discharging"
					return qsTrId("overview_widget_state_discharging")
				}
				return ""
			}
		}
	]
}
