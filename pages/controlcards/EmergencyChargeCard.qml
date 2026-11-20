/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

/*
	Provides access to the emergency reverse charging feature for OrionXS devices.

	Reverse charging moves energy from the output to the input, instead of the other way around. It
	allows the main or auxiliary battery to charge the starter battery, when the starter battery is
	depleted. Reverse charging is possible when an OrionXS is configured to charge the main battery
	(as a com.victronenergy.alternator service) or when configured as a charger for an aux battery
	(as a com.victronenergy.dcdc service).

	This card shows the current charge status and a control button at the bottom:

	- When the charger /EmergencyCharge/Control = 2 (available), click the button ("Emergency
	  charge") to start the charge.
	- When charging starts, the starter battery is charged for 15 minutes. During this time, click
	  the button (now "Stop") to stop the charging.
	- After the 15 minutes, the charger is blocked/disabled for 5 minutes to prevent the charger
	  from drawing energy from the starter battery or alternator/dcdc, and to allow the starter
	  battery to recover. During this time, click the button (now "Skip") to skip the wait time.

	If /EmergencyCharge/Control = 0 (not available), the button is disabled.
*/
ControlCard {
	id: root

	required property Device device

	implicitHeight: mainContentLayout.y + mainContentLayout.implicitHeight
			+ controlButton.implicitHeight + (2 * Theme.geometry_controlCard_contentMargins)
	icon.source: VenusOS.dcMeter_iconForType(VenusOS.dcMeter_type(device.serviceType, monitorMode.value))
	title.text: device.name
	status.text: chargeControl.value === VenusOS.EmergencyCharge_Control_Charging
			? (blockedCountdown.value > 0
			  //% "Battery ready"
			  ? qsTrId("emergency_charge_battery_ready")
			  : CommonWords.emergency_charge)
			: CommonWords.off
	statusQuantity.value: chargeControl.value === VenusOS.EmergencyCharge_Control_Charging ? dcInputCurrent.value : NaN
	statusQuantity.unit: VenusOS.Units_Amp

	VeQuickItem {
		id: dcInputCurrent
		uid: root.device.serviceUid + "/Dc/In/I"
	}

	VeQuickItem {
		id: monitorMode
		uid: root.device.serviceUid + "/Settings/MonitorMode"
	}

	VeQuickItem {
		id: chargeControl
		uid: root.device.serviceUid + "/EmergencyCharge/Control"
	}

	Column {
		id: mainContentLayout

		anchors {
			top: root.status.bottom
			topMargin: Theme.geometry_controlCard_status_bottomMargin
			left: parent.left
			leftMargin: Theme.geometry_controlCard_contentMargins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_contentMargins
		}
		spacing: Theme.geometry_controlCard_status_bottomMargin

		Item {
			anchors.horizontalCenter: parent.horizontalCenter
			implicitWidth: auxBatteryIcon.implicitWidth * 3
			implicitHeight: auxBatteryIcon.implicitHeight

			// Animated connector line between the two batteries.
			Rectangle {
				anchors {
					left: auxBatteryIcon.right
					right: starterBatteryIcon.left
					verticalCenter: auxBatteryIcon.verticalCenter
					verticalCenterOffset: Theme.geometry_icon_battery_terminal_height / 2
				}
				height: Theme.geometry_overviewPage_connector_line_width
				color: Theme.color_overviewPage_widget_border
				clip: true

				CP.ColorImage {
					id: electron1
					x: -width
					y: parent.height/2 - height/2
					source: "qrc:/images/electron.svg"
					visible: chargeControl.value === VenusOS.EmergencyCharge_Control_Charging

					NumberAnimation on x {
						from: -electron1.width
						to: electron1.width
						running: electron1.visible && Global.animationEnabled
						duration: 1000
						loops: Animation.Infinite
					}
				}

				CP.ColorImage {
					x: electron1.width
					y: parent.height/2 - height/2
					source: "qrc:/images/electron.svg"
					visible: chargeControl.value === VenusOS.EmergencyCharge_Control_Charging

					NumberAnimation on x {
						from: electron1.width
						to: electron1.width * 3
						running: electron1.visible && Global.animationEnabled
						duration: 1000
						loops: Animation.Infinite
					}
				}

				CP.ColorImage {
					x: width * 3
					y: parent.height/2 - height/2
					source: "qrc:/images/electron.svg"
					visible: chargeControl.value === VenusOS.EmergencyCharge_Control_Charging

					NumberAnimation on x {
						from: electron1.width * 3
						to: electron1.width * 5
						running: electron1.visible && Global.animationEnabled
						duration: 1000
						loops: Animation.Infinite
					}
				}
			}

			Image {
				id: auxBatteryIcon
				source: "qrc:/images/battery_outline.svg"

				Label {
					anchors {
						centerIn: parent
						verticalCenterOffset: Theme.geometry_icon_battery_terminal_height / 2
					}
					//% "AUX"
					text: qsTrId("emergency_charge_card_aux")
				}

				CP.ColorImage {
					anchors {
						left: parent.right
						verticalCenter: parent.verticalCenter
						verticalCenterOffset: Theme.geometry_icon_battery_terminal_height / 2
					}
					source: "qrc:/images/widget_connector_nub_horizontal.svg"
					color: Theme.color_overviewPage_widget_border
				}
			}

			Image {
				id: starterBatteryIcon
				anchors.right: parent.right
				source: "qrc:/images/battery_outline.svg"

				Label {
					anchors {
						horizontalCenter: parent.horizontalCenter
						verticalCenter: parent.verticalCenter
						verticalCenterOffset: Theme.geometry_icon_battery_terminal_height / 2
					}
					width: parent.width - Theme.geometry_icon_battery_terminal_height
					fontSizeMode: Text.Fit
					minimumPixelSize: Theme.font_size_tiny
					horizontalAlignment: Text.AlignHCenter
					elide: Text.ElideRight
					text: CommonWords.starter_battery_short_name
				}

				CP.ColorImage {
					anchors {
						right: parent.left
						verticalCenter: parent.verticalCenter
						verticalCenterOffset: Theme.geometry_icon_battery_terminal_height / 2
					}
					source: "qrc:/images/widget_connector_nub_horizontal.svg"
					color: Theme.color_overviewPage_widget_border
					rotation: 180
				}
			}
		}

		Column {
			width: parent.width
			opacity: chargeControl.value === VenusOS.EmergencyCharge_Control_Charging ? 1 : 0

			Label {
				width: Math.min(implicitWidth, parent.width)
				horizontalAlignment: Text.AlignHCenter
				bottomPadding: Theme.geometry_controlCard_status_bottomMargin
				wrapMode: Text.Wrap
				//% "Charging starter battery from auxiliary."
				text: chargingCountdown.value > 0 ? qsTrId("emergency_charge_card_charging_detail")
					//% "Battery ready to start engine. Device will resume operation soon."
					: blockedCountdown.value > 0 ? qsTrId("emergency_charge_card_blocked_detail")
					: ""
				color: Theme.color_font_secondary
			}

			FixedWidthLabel {
				id: countdownLabel

				anchors.horizontalCenter: parent.horizontalCenter
				text: visible && blockedCountdown.value > 0 ? Utils.secondsToString(blockedCountdown.value)
						: visible && chargingCountdown.value > 0 ? Utils.secondsToString(chargingCountdown.value)
						: " " // non-empty string, to preserve label height in portrait
				font.pixelSize: Theme.font_size_body2

				VeQuickItem {
					id: chargingCountdown
					uid: root.device.serviceUid + "/EmergencyCharge/ChargingCountdown"
				}
				VeQuickItem {
					id: blockedCountdown
					uid: root.device.serviceUid + "/EmergencyCharge/BlockedCountdown"
				}
			}

			CaptionLabel {
				anchors.horizontalCenter: parent.horizontalCenter
				//% "remaining"
				text: qsTrId("emergency_charge_card_remaining")
				opacity: chargingCountdown.value > 0 || blockedCountdown.value > 0 ? 1 : 0
			}
		}
	}

	CardButton {
		id: controlButton
		anchors {
			margins: Theme.geometry_controlCard_button_margins
			top: Theme.screenSize === Theme.Portrait ? mainContentLayout.bottom : undefined
			bottom: Theme.screenSize === Theme.Portrait ? undefined : parent.bottom
			left: parent.left
			right: parent.right
		}
		focus: true
		enabled: chargeControl.value === VenusOS.EmergencyCharge_Control_Available
				|| chargeControl.value === VenusOS.EmergencyCharge_Control_Charging
		text: chargeControl.value === VenusOS.EmergencyCharge_Control_Charging
				? (blockedCountdown.value > 0 ? CommonWords.skip_action : CommonWords.stop_action)
				: CommonWords.emergency_charge
		backgroundColor: enabled
				? chargeControl.value === VenusOS.EmergencyCharge_Control_Charging
					? (blockedCountdown.value > 0 ? Theme.color_brand : Theme.color_dimCritical)
					: Theme.color_dimSuccess
				: Theme.color_background_disabled
		color: enabled
				? chargeControl.value === VenusOS.EmergencyCharge_Control_Charging
					? (blockedCountdown.value > 0 ? Theme.color_button_down_text : Theme.color_dimCritical_text)
					: Theme.color_dimSuccess_text
				: Theme.color_button_off_text_disabled
		onClicked: {
			if (chargeControl.value === VenusOS.EmergencyCharge_Control_Charging) {
				if (blockedCountdown.value > 0) {
					Global.dialogLayer.open(chargeSkipDialogComponent)
				} else {
					Global.dialogLayer.open(chargeStopDialogComponent)
				}
			} else {
				Global.dialogLayer.open(chargeStartDialogComponent)
			}
		}
	}

	Component {
		id: chargeStartDialogComponent
		EmergencyChargeStartDialog {
			secondaryTitle: root.device.name
			onAccepted: chargeControl.setValue(VenusOS.EmergencyCharge_Control_Charging)
		}
	}

	Component {
		id: chargeStopDialogComponent
		EmergencyChargeStopDialog {
			secondaryTitle: root.device.name
			acceptText: CommonWords.stop_action
			onAccepted: chargeControl.setValue(VenusOS.EmergencyCharge_Control_Available)
		}
	}

	Component {
		id: chargeSkipDialogComponent
		EmergencyChargeSkipDialog {
			secondaryTitle: root.device.name
			onAccepted: chargeControl.setValue(VenusOS.EmergencyCharge_Control_Available)
		}
	}
}
