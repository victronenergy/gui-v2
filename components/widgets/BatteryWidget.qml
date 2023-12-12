/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils
import Victron.Units

OverviewWidget {
	id: root

	readonly property var batteryData: Global.batteries.system

	readonly property int _normalizedStateOfCharge: Math.round(batteryData.stateOfCharge || 0)
	readonly property bool _animationReady: animationEnabled && !isNaN(batteryData.stateOfCharge)

	title: CommonWords.battery
	icon.source: batteryData.icon
	type: Enums.OverviewWidget_Type_Battery
	enabled: Global.batteries.model.count > 0

	quantityLabel.value: batteryData.stateOfCharge
	quantityLabel.unit: Enums.Units_Percentage

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
		backgroundColor: Theme.color.overviewPage.widget.background
		foregroundColor: Theme.color.overviewPage.widget.battery.background
		radius: Theme.geometry.overviewPage.widget.battery.background.radius

		Item {
			id: animationClip

			width: parent.width
			height: parent.height * (animationRect.value)
			y: parent.height - height
			visible: batteryData.mode === Enums.Battery_Mode_Charging && root._animationReady
			clip: true

			Timer {
				id: delayedStartTimer
				property int count: 0
				property bool startRunning: root._animationReady
				interval: Theme.animation.overviewPage.widget.battery.bubble.duration / Theme.animation.overviewPage.widget.battery.bubbles
				repeat: true

				onStartRunningChanged: {
					if (startRunning) {
						count = 0
						running = true
					}
				}

				onTriggered: {
					if (count++ > Theme.animation.overviewPage.widget.battery.bubbles) {
						running = false
					}
				}
			}

			Row {
				id: chimneysRow

				height: parent.height

				Repeater {
					id: chimneyRepeater

					model: Theme.animation.overviewPage.widget.battery.chimneys

					delegate: Item {
						id: chimney // a "chimney" which the bubbles rise up within.

						required property int index

						width: animationClip.width / Theme.animation.overviewPage.widget.battery.chimneys
						height: root.expandedHeight // always full height, the clip item will clip it.
						y: -(height - animationClip.height)

						Repeater {
							model: Theme.animation.overviewPage.widget.battery.bubbles
							delegate: Rectangle {
								id: bubble
								required property int index
								y: chimney.height
								width: Theme.geometry.overviewPage.widget.battery.bubble.width
								height: width
								color: Theme.color.overviewPage.widget.battery.bubble.background
								radius: height/2
								border.width: 1
								border.color: Theme.color.overviewPage.widget.battery.bubble.border

								YAnimator {
									id: yanimator
									target: bubble
									from: chimney.height
									to: 0
									duration: Theme.animation.overviewPage.widget.battery.bubble.duration + 100*Math.random()*bubble.index
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
									from: Theme.animation.overviewPage.widget.battery.bubble.opacity
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
			topMargin: Theme.geometry.overviewPage.widget.battery.temperature.topMargin
			right: parent.right
			rightMargin: Theme.geometry.overviewPage.widget.battery.temperature.rightMargin
		}

		value: Math.round(Global.systemSettings.temperatureUnit.value === Enums.Units_Temperature_Celsius
				? batteryData.temperature_celsius
				: Units.celsiusToFahrenheit(batteryData.temperature_celsius))
		unit: !!Global.systemSettings.temperatureUnit.value ? Global.systemSettings.temperatureUnit.value : Enums.Units_Temperature_Celsius
		font.pixelSize: Theme.font.size.body2
	}

	extraContent.children: [
		Column {
			anchors {
				top: parent.top
				left: parent.left
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
			}
			Label {
				text: Global.batteries.modeToText(batteryData.mode)
				font.pixelSize: Theme.font.size.body1
				color: Theme.color.font.secondary
			}
			Label {
				text: Global.batteries.timeToGoText(Global.batteries.system, Enums.Battery_TimeToGo_ShortFormat)
				color: Theme.color.font.primary
				font.pixelSize: Theme.font.overviewPage.battery.timeToGo.pixelSize
			}
		},

		QuantityLabel {
			id: batteryVoltageDisplay

			anchors {
				left: parent.left
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry.overviewPage.widget.battery.bottomRow.bottomMargin
			}

			value: batteryData.voltage
			unit: Enums.Units_Volt
			font.pixelSize: Theme.font.size.body2
		},

		QuantityLabel {
			id: batteryCurrentDisplay

			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: Theme.geometry.overviewPage.widget.battery.bottomRow.bottomMargin
			}
			value: batteryData.current
			unit: Enums.Units_Amp
			font.pixelSize: Theme.font.size.body2
		},

		QuantityLabel {
			id: batteryPowerDisplay

			anchors {
				right: parent.right
				rightMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry.overviewPage.widget.battery.bottomRow.bottomMargin
			}
			value: batteryData.power
			unit: Enums.Units_Watt
			font.pixelSize: Theme.font.size.body2
		}
	]

	MouseArea {
		anchors.fill: parent
		onClicked: {
			if (Global.batteries.model.count === 1) {
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBattery.qml",
						{ "battery": Global.batteries.model.deviceAt(0) })
			} else {
				Global.pageManager.pushPage("/pages/battery/BatteryListPage.qml")
			}
		}
	}

}
