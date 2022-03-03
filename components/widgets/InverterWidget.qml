/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	//% "Inverter / Charger"
	title.text: qsTrId("overview_widget_inverter_title")
	icon.source: "qrc:/images/inverter_charger.svg"

	sideGaugeVisible: true
	sideGaugeValue: 0.7 // TODO: data model
	physicalQuantity: -1

	extraContent.children: [
		Label {
			id: statusLabel
			anchors {
				left: parent.left
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
			}
			font.pixelSize: Theme.font.size.xl

			text: {
				if (!system) {
					return ""
				}
				switch (system.state) {
				case System.State.Off:
					//: System state = 'Off'
					//% "Off"
					return qsTrId("overview_widget_state_off")
				case System.State.LowPower:
					//: System state = 'Low power'
					//% "Low power"
					return qsTrId("overview_widget_state_lowpower")
				case System.State.FaultCondition:
					//: System state = 'Fault condition'
					//% "Fault"
					return qsTrId("overview_widget_state_faultcondition")
				case System.State.BulkCharging:
					//: System state = 'Bulk charging'
					//% "Bulk"
					return qsTrId("overview_widget_state_bulkcharging")
				case System.State.AbsorptionCharging:
					//: System state = 'Absorption charging'
					//% "Absorption"
					return qsTrId("overview_widget_state_absorptioncharging")
				case System.State.FloatCharging:
					//: System state = 'Float charging'
					//% "Float"
					return qsTrId("overview_widget_state_floatcharging")
				case System.State.StorageMode:
					//: System state = 'Storage mode'
					//% "Storage"
					return qsTrId("overview_widget_state_storagemode")
				case System.State.EqualisationCharging:
					//: System state = 'Equalization charging'
					//% "Equalize"
					return qsTrId("overview_widget_state_equalisationcharging")
				case System.State.PassThrough:
					//: System state = 'Pass-thru'
					//% "Pass-through"
					return qsTrId("overview_widget_state_passthrough")
				case System.State.Inverting:
					//: System state = 'Inverting'
					//% "Inverting"
					return qsTrId("overview_widget_state_inverting")
				case System.State.Assisting:
					//: System state = 'Assisting'
					//% "Assisting"
					return qsTrId("overview_widget_state_assisting")
				case System.State.Discharging:
					//: System state = 'Discharging'
					//% "Discharging"
					return qsTrId("overview_widget_state_discharging")
				}
				return ""
			}
		}
	]
}
