/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	onClicked: {
		// If com.victronenergy.system/Batteries has only one battery, then show the device
		// settings for that battery; otherwise, show the full battery list using BatteryListPage.
		if (batteries.value.length === 1) {
			const batteryUids = batteries.value.map((info) => BackendConnection.serviceUidFromName(info.id, info.instance))

			// Show the vebus page if the battery is from a vebus service.
			if (BackendConnection.serviceTypeFromUid(batteryUids[0]) === "vebus") {
				const deviceIndex = Global.inverterChargers.veBusDevices.indexOf(batteryUids[0])
				if (deviceIndex >= 0) {
					const veBusDevice = Global.inverterChargers.veBusDevices.deviceAt(deviceIndex)
					Global.pageManager.pushPage( "/pages/vebusdevice/PageVeBus.qml", {
						"title": veBusDevice.name,
						"veBusDevice": veBusDevice
					})
					return
				}
			}

			// Assume this is a battery service
			const batteryIndex = Global.batteries.model.indexOf(batteryUids[0])
			if (batteryIndex >= 0) {
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBattery.qml",
						{ "battery": Global.batteries.model.deviceAt(batteryIndex) })
				return
			}
		}

		Global.pageManager.pushPage("/pages/battery/BatteryListPage.qml")
	}

	readonly property var batteryData: Global.batteries.system

	readonly property int _normalizedStateOfCharge: Math.round(batteryData.stateOfCharge || 0)
	readonly property bool _animationReady: animationEnabled && !isNaN(batteryData.stateOfCharge)

	// Calculate whether voltage, current and power quantities fit on the footer together, if not use smaller font.
	// Discharging battery has negative amperes and its not unusual for the watts to be in the 1k+ range.
	readonly property bool _useSmallFont: !quantityLabelFits(batteryVoltageDisplay) || !quantityLabelFits(batteryPowerDisplay)

	function quantityLabelFits(label) {
		return root.width/2 - 2*Theme.geometry_overviewPage_widget_content_horizontalMargin
			> quantityLabelWidth(batteryCurrentDisplay.valueText, batteryCurrentDisplay.unitText)/2
			+ quantityLabelWidth(label.valueText, label.unitText)
	}

	function quantityLabelWidth(valueText, unitText){
		const valueTextRect = quantityLabelFont.tightBoundingRect(valueText)
		return quantityLabelFont.font, (valueTextRect.x + valueTextRect.width
										+ Theme.geometry_quantityLabel_spacing
										+ quantityLabelFont.advanceWidth(unitText))
	}

	FontMetrics {
		id: quantityLabelFont
		font.pixelSize: Theme.font_size_body2
		font.family: Global.quantityFontFamily
	}

	VeQuickItem {
		id: batteries
		uid: Global.system.serviceUid + "/Batteries"
	}

	title: CommonWords.battery
	icon.source: batteryData.icon
	type: VenusOS.OverviewWidget_Type_Battery
	enabled: batteries.isValid

	quantityLabel.value: batteryData.stateOfCharge
	quantityLabel.unit: VenusOS.Units_Percentage

	color: "transparent"

	BarGauge {
		id: animationRect
		z: -1

		anchors {
			fill: parent
			margins: root.border.width
		}

		animationEnabled: root.animationEnabled // Note: don't use _animationReady here.
		value: _normalizedStateOfCharge/100
		backgroundColor: Theme.color_overviewPage_widget_background
		foregroundColor: Theme.color_overviewPage_widget_battery_background
		radius: Theme.geometry_overviewPage_widget_battery_background_radius

		Item {
			id: animationClip

			width: parent.width
			height: parent.height * (animationRect.value)
			anchors.bottom: parent.bottom
			visible: batteryData.mode === VenusOS.Battery_Mode_Charging && root._animationReady
			clip: true
			z: 6 // greater than the explicit z-order specified in BarGauge.

			SequentialAnimation {
				property bool startAnimation: root._animationReady
				onStartAnimationChanged: if (startAnimation) start()
				onStopped: if (startAnimation) start()

				YAnimator {
					target: gradient
					from: animationClip.height
					to: -gradient.height
					duration: Theme.animation_overviewPage_widget_battery_animation_duration
					easing.type: Easing.OutQuad
				}

				PauseAnimation {
					duration: Theme.animation_overviewPage_widget_battery_animation_pause_duration
				}
			}

			Rectangle {
				id: gradient
				width: parent.width
				height: Theme.geometry_overviewPage_widget_battery_gradient_height
				gradient: Gradient {
					GradientStop {
						position: 0.0
						color: Qt.rgba(1,1,1,0.3)
					}
					GradientStop {
						position: 0.3
						color: Qt.rgba(1,1,1,0.15)
					}
					GradientStop {
						position: 1.0
						color: Qt.rgba(1,1,1,0.0)
					}
				}
			}
		}
	}

	QuantityLabel {
		id: batteryTempDisplay

		anchors {
			top: parent.top
			topMargin: root.verticalMargin
			right: parent.right
			rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
		}

		value: Global.systemSettings.convertFromCelsius(batteryData.temperature)
		unit: Global.systemSettings.temperatureUnit
		font.pixelSize: Theme.font_size_body2
		alignment: Qt.AlignRight
		visible: !isNaN(batteryData.temperature)
	}

	extraContentChildren: [
		Column {
			anchors {
				top: parent.top
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
			}
			Label {
				text: Global.batteries.modeToText(batteryData.mode)
				font.pixelSize: Theme.font_size_body1
				width: parent.width
				elide: Text.ElideRight
				color: Theme.color_font_secondary
			}
			Label {
				text: Global.batteries.timeToGoText(Global.batteries.system.timeToGo, VenusOS.Battery_TimeToGo_ShortFormat)
				color: Theme.color_font_primary
				width: parent.width
				elide: Text.ElideRight
				font.pixelSize: Theme.font_overviewPage_battery_timeToGo_pixelSize
			}
		},

		QuantityLabel {
			id: batteryVoltageDisplay

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry_overviewPage_widget_battery_bottomRow_bottomMargin
			}

			value: batteryData.voltage
			unit: VenusOS.Units_Volt_DC
			font.pixelSize: root._useSmallFont ? Theme.font_size_body1 : Theme.font_size_body2
			alignment: Qt.AlignLeft
		},

		QuantityLabel {
			id: batteryCurrentDisplay

			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: Theme.geometry_overviewPage_widget_battery_bottomRow_bottomMargin
			}
			value: batteryData.current
			unit: VenusOS.Units_Amp
			font.pixelSize: root._useSmallFont ? Theme.font_size_body1 : Theme.font_size_body2
		},

		QuantityLabel {
			id: batteryPowerDisplay

			anchors {
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry_overviewPage_widget_battery_bottomRow_bottomMargin
			}
			value: batteryData.power
			unit: VenusOS.Units_Watt
			font.pixelSize: root._useSmallFont ? Theme.font_size_body1 : Theme.font_size_body2
			alignment: Qt.AlignRight
		}
	]
}
