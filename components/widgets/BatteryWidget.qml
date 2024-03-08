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
			y: parent.height - height
			visible: batteryData.mode === VenusOS.Battery_Mode_Charging && root._animationReady
			clip: true

			Timer {
				id: delayedStartTimer
				property int count: 0
				property bool startRunning: root._animationReady
				interval: Theme.animation_overviewPage_widget_battery_bubble_duration / Theme.animation_overviewPage_widget_battery_bubbles
				repeat: true

				onStartRunningChanged: {
					if (startRunning) {
						count = 0
						running = true
					}
				}

				onTriggered: {
					if (count++ > Theme.animation_overviewPage_widget_battery_bubbles) {
						running = false
					}
				}
			}

			Row {
				id: chimneysRow

				height: parent.height

				Repeater {
					id: chimneyRepeater

					model: Theme.animation_overviewPage_widget_battery_chimneys

					delegate: Item {
						id: chimney // a "chimney" which the bubbles rise up within.

						width: animationClip.width / Theme.animation_overviewPage_widget_battery_chimneys
						height: root.expandedHeight // always full height, the clip item will clip it.
						y: -(height - animationClip.height)

						Repeater {
							model: Theme.animation_overviewPage_widget_battery_bubbles
							delegate: Rectangle {
								id: bubble
								required property int index
								y: chimney.height
								width: Theme.geometry_overviewPage_widget_battery_bubble_width
								height: width
								color: Theme.color_overviewPage_widget_battery_bubble_background
								radius: height/2
								border.width: 1
								border.color: Theme.color_overviewPage_widget_battery_bubble_border

								YAnimator {
									id: yanimator
									target: bubble
									from: chimney.height
									to: 0
									duration: Theme.animation_overviewPage_widget_battery_bubble_duration + 100*Math.random()*bubble.index
									easing.type: Easing.InOutQuad
									loops: Animation.Infinite
									running: root._animationReady && delayedStartTimer.count >= bubble.index
								}

								XAnimator {
									target: bubble
									// define three slightly different paths for bubbles.
									from: bubble.index % 3 === 0 ? chimney.width/2 - bubble.width
										: bubble.index % 2 === 0 ? chimney.width - 3*bubble.width
										: (3*bubble.width)
									to: bubble.index % 3 === 0 ? chimney.width/2 + bubble.width
									  : bubble.index % 2 === 0 ? 3*bubble.width
									  : (chimney.width - 3*bubble.width)
									duration: yanimator.duration
									easing.type: Easing.InBack
									easing.overshoot: Math.max(2.0, (0.8 + Math.random() * bubble.index))
									loops: Animation.Infinite
									running: yanimator.running
								}

								OpacityAnimator {
									target: bubble
									from: Theme.animation_overviewPage_widget_battery_bubble_opacity
									to: 0.0
									easing.type: Easing.InQuad
									duration: yanimator.duration
									loops: Animation.Infinite
									running: yanimator.running
									onRunningChanged: if (!running) bubble.opacity = 0
								}
							}
						}
					}
				}
			}
		}
	}

	QuantityLabel {
		id: batteryTempDisplay

		anchors {
			top: parent.top
			topMargin: Theme.geometry_overviewPage_widget_battery_temperature_topMargin
			right: parent.right
			rightMargin: Theme.geometry_overviewPage_widget_battery_temperature_rightMargin
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
