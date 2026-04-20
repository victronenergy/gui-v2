/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS
import QtQuick.Controls.impl as CP

OverviewWidget {
	id: root

	readonly property bool preferRenewable: preferRenewableEnergy.valid
	readonly property bool preferRenewableOverride: preferRenewableEnergy.value === 0 || preferRenewableEnergy.value === 2
	readonly property bool preferRenewableOverrideGenset: remoteGeneratorSelected.value === 1 || Global.acInputs.activeInSource === VenusOS.AcInputs_InputSource_Generator

	onClicked: {
		// If com.victronenergy.system/Batteries has only one battery, then show the device
		// settings for that battery; otherwise, show the full battery list using BatteryListPage.
		if (batteries.value.length === 1) {
			const batteryUids = batteries.value.map((info) => BackendConnection.serviceUidFromName(info.id, info.instance))

			// Show the vebus page if the battery is from a vebus service.
			if (BackendConnection.serviceTypeFromUid(batteryUids[0]) === "vebus") {
				Global.pageManager.pushPage("/pages/vebusdevice/PageVeBus.qml", {
					"bindPrefix": batteryUids[0],
				})
			} else {
				// Assume this is a battery service
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBattery.qml", {
					"bindPrefix": batteryUids[0]
				})
			}
		} else {
			Global.pageManager.pushPage("/pages/battery/BatteryListPage.qml")
		}
	}

	readonly property int _normalizedStateOfCharge: Math.round(Global.system.battery.stateOfCharge || 0)
	readonly property bool _animationReady: animationEnabled && !isNaN(Global.system.battery.stateOfCharge)

	VeQuickItem {
		id: batteries
		uid: Global.system.serviceUid + "/Batteries"
	}

	VeQuickItem {
		id: preferRenewableEnergy

		uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Dc/0/PreferRenewableEnergy" : ""
	}

	VeQuickItem {
		id: remoteGeneratorSelected

		uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Ac/State/RemoteGeneratorSelected" : ""
	}

	title: CommonWords.battery
	type: VenusOS.OverviewWidget_Type_Battery
	enabled: batteries.valid

	background: Rectangle {
		implicitWidth: Theme.geometry_overviewPage_widget_centerWidgetWidth
		implicitHeight: Theme.geometry_overviewPage_widget_compact_l_height
		border.width: enabled ? Theme.geometry_overviewPage_widget_border_width : 0
		border.color: Theme.color_overviewPage_widget_border
		color: Theme.color_overviewPage_widget_background
		radius: Theme.geometry_overviewPage_widget_radius

		PressArea {
			radius: parent.radius
			anchors.fill: parent
			onClicked: root.clicked()
		}

		BarGauge {
			id: animationRect

			anchors {
				fill: parent
				margins: parent.border.width
			}

			animationEnabled: root.animationEnabled // Note: don't use _animationReady here.
			value: _normalizedStateOfCharge/100
			backgroundColor: Theme.color_overviewPage_widget_background
			foregroundColor: Theme.color_overviewPage_widget_battery_background
			radius: parent.radius - parent.border.width

			Item {
				id: animationClip

				width: parent.width
				height: parent.height * (animationRect.value)
				anchors.bottom: parent.bottom
				visible: Global.system.battery.mode === VenusOS.Battery_Mode_Charging && root._animationReady
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
			anchors {
				top: parent.top
				topMargin: Theme.geometry_overviewPage_widget_content_topMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
			}
			value: Global.system.battery.temperature
			unit: Global.systemSettings.temperatureUnit
			unitColor: Theme.color_overviewPage_widget_battery_font_secondary
			font.pixelSize: Theme.font_overviewPage_battery_secondary
			alignment: Qt.AlignRight
			visible: !isNaN(Global.system.battery.temperature)
		}

		CP.ColorImage {
			anchors {
				bottom: parent.bottom
				bottomMargin: Theme.geometry_overviewPage_batterywidget_renewable_icon_bottom_margin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
			}
			fillMode: Image.PreserveAspectFit
			color: Theme.color_font_primary
			visible: root.preferRenewable
			source: "qrc:/images/icon_charging_renewables.svg"
		}
	}

	contentItem: ColumnLayout {
		spacing: 0

		WidgetHeader {
			text: root.title
			icon.source: Global.system.battery.icon
			Layout.fillWidth: true
		}

		ElectricalQuantityLabel {
			font.pixelSize: Theme.font_overviewPage_widget_quantityLabel_maximumSize
			alignment: Qt.AlignLeft
			value: Global.system.battery.stateOfCharge
			unit: VenusOS.Units_Percentage
			unitColor: Theme.color_overviewPage_widget_battery_font_secondary
			Layout.fillWidth: true
		}

		Label {
			text: VenusOS.battery_modeToText(Global.system.battery.mode)
			elide: Text.ElideRight
			color: Theme.color_overviewPage_widget_battery_font_secondary
			Layout.fillWidth: true
		}

		RowLayout {
			spacing: Theme.geometry_overviewPage_widget_content_horizontalMargin
			Layout.fillWidth: false

			Label {
				text: Global.system.battery.timeToGo == 0 ? "" : Utils.secondsToString(Global.system.battery.timeToGo)
				visible: Global.system.battery.timeToGo > 0
				elide: Text.ElideRight
				font.pixelSize: Theme.font_overviewPage_secondary
				Layout.fillWidth: true
			}

			CP.ColorImage {
				fillMode: Image.PreserveAspectFit
				color: Theme.color_font_primary
				visible: root.preferRenewableOverride
				source: root.preferRenewableOverrideGenset
						? "qrc:/images/icon_charging_generator.svg"
						: Global.acInputs.activeInSource === VenusOS.AcInputs_InputSource_Shore
						  ? "qrc:/images/icon_charging_shore.svg"
						  : "qrc:/images/icon_charging_grid.svg"
			}
		}

		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true
		}

		RowLayout {
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

			spacing: Theme.geometry_overviewPage_widget_content_horizontalMargin

			FontMetrics {
				id: quantityLabelFont
				font.pixelSize: Theme.font_overviewPage_battery_secondary
				font.family: Global.quantityFontFamily
			}

			QuantityLabel {
				id: batteryVoltageDisplay

				value: Global.system.battery.voltage
				unit: VenusOS.Units_Volt_DC
				unitColor: Theme.color_overviewPage_widget_battery_font_secondary
				font.pixelSize: parent._useSmallFont ? Theme.font_overviewPage_secondary : Theme.font_overviewPage_battery_secondary
				alignment: Qt.AlignLeft
				Layout.fillWidth: true
			}

			QuantityLabel {
				id: batteryCurrentDisplay

				value: Global.system.battery.current
				unit: VenusOS.Units_Amp
				unitColor: Theme.color_overviewPage_widget_battery_font_secondary
				font.pixelSize: parent._useSmallFont ? Theme.font_overviewPage_secondary : Theme.font_overviewPage_battery_secondary
				Layout.fillWidth: true
			}

			QuantityLabel {
				id: batteryPowerDisplay

				value: Global.system.battery.power
				unit: VenusOS.Units_Watt
				unitColor: Theme.color_overviewPage_widget_battery_font_secondary
				font.pixelSize: parent._useSmallFont ? Theme.font_overviewPage_secondary : Theme.font_overviewPage_battery_secondary
				alignment: Qt.AlignRight
				Layout.fillWidth: true
			}
		}
	}
}
