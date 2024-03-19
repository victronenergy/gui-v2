/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	onClicked: {
		if (Global.batteries.model.count === 1) {
			Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBattery.qml",
					{ "battery": Global.batteries.model.deviceAt(0) })
		} else {
			Global.pageManager.pushPage("/pages/battery/BatteryListPage.qml")
		}
	}

	readonly property var batteryData: Global.batteries.system

	readonly property int _normalizedStateOfCharge: Math.round(batteryData.stateOfCharge || 0)
	readonly property bool _animationReady: animationEnabled && !isNaN(batteryData.stateOfCharge)

	title: CommonWords.battery
	icon.source: batteryData.icon
	type: VenusOS.OverviewWidget_Type_Battery
	enabled: Global.batteries.model.count > 0

	quantityLabel.value: batteryData.stateOfCharge
	quantityLabel.unit: VenusOS.Units_Percentage

	color: "transparent"

	VerticalGauge {
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
	}

	extraContentChildren: [
		Column {
			anchors {
				top: parent.top
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
			}
			Label {
				text: Global.batteries.modeToText(batteryData.mode)
				font.pixelSize: Theme.font_size_body1
				color: Theme.color_font_secondary
			}
			Label {
				text: Global.batteries.timeToGoText(Global.batteries.system, VenusOS.Battery_TimeToGo_ShortFormat)
				color: Theme.color_font_primary
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
			unit: VenusOS.Units_Volt
			font.pixelSize: Theme.font_size_body2
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
			font.pixelSize: Theme.font_size_body2
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
			font.pixelSize: Theme.font_size_body2
			alignment: Qt.AlignRight
		}
	]
}
