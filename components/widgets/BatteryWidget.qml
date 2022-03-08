/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "../Utils.js" as Utils

OverviewWidget {
	id: root

	property var batteryData

	//% "Battery"
	title.text: qsTrId("overview_widget_battery_title")
	icon.source: Utils.batteryIcon(batteryData)

	value: batteryData.stateOfCharge
	physicalQuantity: Units.Percentage
	precision: 2

	Rectangle {
		id: animationRect

		anchors {
			left: parent.left
			leftMargin: root.border.width
			right: parent.right
			rightMargin: root.border.width
			bottom: parent.bottom
			bottomMargin: root.border.width
		}
		height: Math.floor(parent.height * root.value/100) - root.border.width*2
		z: -1
		color: Theme.color.overviewPage.widget.battery.background

		Grid {
			id: animationGrid
			anchors.horizontalCenter: parent.horizontalCenter
			topPadding: Theme.geometry.overviewPage.widget.battery.animatedBar.verticalSpacing / 2
			horizontalItemAlignment: Grid.AlignHCenter
			visible: !batteryData.idle

			columns: {
				const maxWidth = parent.width - Theme.geometry.overviewPage.widget.battery.animatedBar.horizontalSpacing*4
				const maxColumns = Math.floor(maxWidth / (Theme.geometry.overviewPage.widget.battery.animatedBar.maximumWidth
					+ Theme.geometry.overviewPage.widget.battery.animatedBar.horizontalSpacing*2))
				// Ensure an odd column count so that bars animate differently in alternate rows
				return Math.max(0, maxColumns % 2 ? maxColumns : maxColumns - 1)
			}

			Repeater {
				id: animatedBarsRepeater

				model: {
					const maxHeight = animationRect.height - Theme.geometry.overviewPage.widget.battery.animatedBar.verticalSpacing*2
					const maxRows = maxHeight / (Theme.geometry.overviewPage.widget.battery.animatedBar.height
						+ Theme.geometry.overviewPage.widget.battery.animatedBar.verticalSpacing*2)
					const rows = Math.max(0, Math.floor(maxRows))
					return animationGrid.columns * rows
				}

				delegate: Item {
					id: animatedBar

					readonly property real fromWidth: model.index % 2
							? Theme.geometry.overviewPage.widget.battery.animatedBar.maximumWidth
							: Theme.geometry.overviewPage.widget.battery.animatedBar.minimumWidth
					readonly property real toWidth: model.index % 2
							? Theme.geometry.overviewPage.widget.battery.animatedBar.minimumWidth
							: Theme.geometry.overviewPage.widget.battery.animatedBar.maximumWidth

					width: Theme.geometry.overviewPage.widget.battery.animatedBar.maximumWidth
						   + Theme.geometry.overviewPage.widget.battery.animatedBar.horizontalSpacing*2
					height: Theme.geometry.overviewPage.widget.battery.animatedBar.height
							+ Theme.geometry.overviewPage.widget.battery.animatedBar.verticalSpacing*2

					Rectangle {
						anchors.centerIn: parent
						width: animatedBar.fromWidth
						height: Theme.geometry.overviewPage.widget.battery.animatedBar.height
						color: Theme.color.overviewPage.widget.battery.animatedBar
						radius: height

						SequentialAnimation on width {
							loops: Animation.Infinite
							running: PageManager.navBar.currentUrl === "qrc:/pages/OverviewPage.qml"

							NumberAnimation {
								from: animatedBar.fromWidth
								to: animatedBar.toWidth
								duration: 800
							}
							PauseAnimation {
								duration: 200
							}
							NumberAnimation {
								from: animatedBar.toWidth
								to: animatedBar.fromWidth
								duration: 800
							}
							PauseAnimation {
								duration: 200
							}
						}
					}
				}
			}
		}
	}

	Rectangle {
		anchors.fill: animationRect
		z: -1

		gradient: Gradient {
			GradientStop { position: 0.0; color: "transparent" }
			GradientStop { position: 1.0; color: Theme.color.overviewPage.widget.battery.background }
		}
	}

	Label {
		anchors {
			bottom: extraContent.top
			bottomMargin: 2
			right: parent.right
			rightMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
		}
		text: batteryData.timeToGo > 0 ? Utils.formatAsHHMM(batteryData.timeToGo, true) : ""
		color: Theme.color.font.secondary
		font.pixelSize: Theme.font.size.m
	}

	extraContent.children: [
		Label {
			anchors {
				top: parent.top
				left: parent.left
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
			}
			text: batteryData.idle
					//% "Idle"
				  ? qsTrId("overview_widget_battery_idle")
				  : (batteryData.current > 0
					  //% "Charging"
					? qsTrId("overview_widget_battery_charging")
					  //% "Discharging"
					: qsTrId("overview_widget_battery_discharging"))
			font.pixelSize: Theme.font.size.s
			color: Theme.color.font.secondary
		},

		Row {
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: Theme.geometry.overviewPage.widget.content.verticalMargin
			}
			width: root.width - Theme.geometry.overviewPage.widget.content.horizontalMargin*2

			ValueQuantityDisplay {
				id: batteryPowerDisplay

				value: batteryData.power
				physicalQuantity: Units.Power
				font.pixelSize: Theme.font.size.m
			}

			Item {
				height: batteryCurrentDisplay.height
				width: parent.width - batteryPowerDisplay.width - batteryTempDisplay.width

				ValueQuantityDisplay {
					id: batteryCurrentDisplay

					anchors.horizontalCenter: parent.horizontalCenter
					value: batteryData.current
					physicalQuantity: Units.Current
					font.pixelSize: Theme.font.size.m
				}
			}

			ValueQuantityDisplay {
				id: batteryTempDisplay

				value: batteryData.temperature
				physicalQuantity: Units.Temperature
				font.pixelSize: Theme.font.size.m
			}
		}
	]
}
