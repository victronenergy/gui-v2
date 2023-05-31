/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "../Utils.js" as Utils
import "../Units.js" as Units

OverviewWidget {
	id: root

	property alias animationPaused: barAnimation.paused
	readonly property var batteryData: Global.batteries.first

	readonly property int _normalizedStateOfCharge: batteryData
			&& !isNaN(batteryData.stateOfCharge) ? Math.round(batteryData.stateOfCharge) : 0
	readonly property bool _animationReady: animationEnabled && !!batteryData && !isNaN(batteryData.stateOfCharge)

	title: CommonWords.battery
	icon.source: batteryData ? batteryData.icon : ""
	type: VenusOS.OverviewWidget_Type_Battery

	quantityLabel.value: {
		// Show 2 decimal places if available
		if (!batteryData) {
			return NaN
		}
		const fixed = batteryData.stateOfCharge.toFixed(2)
		const floored = Math.floor(batteryData.stateOfCharge)
		if (fixed === floored) {
			return floored
		}
		return fixed
	}
	quantityLabel.unit: VenusOS.Units_Percentage

	color: "transparent"

	Rectangle {
		id: animationRect
		z: -1

		anchors {
			fill: parent
			margins: root.border.width
		}

		gradient: Gradient {
			GradientStop { position: 0.0; color: Theme.color.overviewPage.widget.background }
			GradientStop { position: Math.min(0.999999, (1.0 - _normalizedStateOfCharge/100)); color: Theme.color.overviewPage.widget.background }
			GradientStop { position: Math.min(1.0, (1.0 - _normalizedStateOfCharge/100) + 0.001); color: Theme.color.overviewPage.widget.battery.background }
			GradientStop { position: 1.0; color: Theme.color.overviewPage.widget.battery.background }
		}
		radius: parent.radius

		Grid {
			id: animationGrid
			anchors {
				top: parent.top
				topMargin: parent.height - Math.floor(parent.height * _normalizedStateOfCharge/100) - root.border.width*2
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
			}

			topPadding: Theme.geometry.overviewPage.widget.battery.animatedBar.verticalSpacing / 2
			horizontalItemAlignment: Grid.AlignHCenter
			visible: !!batteryData && batteryData.mode === VenusOS.Battery_Mode_Charging

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
					// Always use the compactHeight to calculate the model, to avoid changing the
					// model when switching between expanded and compact height.
					const compactAnimatingAreaHeight = Math.floor(root.compactHeight * _normalizedStateOfCharge/100) - root.border.width*2
					const maxHeight = compactAnimatingAreaHeight - Theme.geometry.overviewPage.widget.battery.animatedBar.verticalSpacing*2
					const maxRows = maxHeight / (Theme.geometry.overviewPage.widget.battery.animatedBar.height
						+ Theme.geometry.overviewPage.widget.battery.animatedBar.verticalSpacing*2)
					const rows = Math.max(0, Math.floor(maxRows))

					// Ensure an odd row count so that the animation does not jump (due to changes
					// in the alternate-row pattern of animations) when the model changes.
					const oddRowCount = Math.max(0, rows % 2 ? rows : rows - 1)
					return animationGrid.columns * oddRowCount
				}

				delegate: Item {
					id: animatedBar

					property alias barWidth: bar.width

					width: Theme.geometry.overviewPage.widget.battery.animatedBar.maximumWidth
						   + Theme.geometry.overviewPage.widget.battery.animatedBar.horizontalSpacing*2
					height: Theme.geometry.overviewPage.widget.battery.animatedBar.height
							+ Theme.geometry.overviewPage.widget.battery.animatedBar.verticalSpacing*2

					Rectangle {
						id: bar

						anchors.centerIn: parent
						height: Theme.geometry.overviewPage.widget.battery.animatedBar.height
						color: Theme.color.overviewPage.widget.battery.animatedBar
						radius: height
					}

					Component.onCompleted: Qt.callLater(barAnimation.update)
				}
			}
		}

		Rectangle {
			anchors.fill: animationGrid

			gradient: Gradient {
				GradientStop { position: 0.0; color: "transparent" }
				GradientStop { position: 1.0; color: Theme.color.overviewPage.widget.battery.background }
			}
		}
	}

	SequentialAnimation {
		id: barAnimation

		property var _evenAnimationTargets: []
		property var _oddAnimationTargets: []

		function update() {
			let evenTargets = []
			let oddTargets = []
			for (let i = 0; i < animatedBarsRepeater.count; ++i) {
				const animationTarget = animatedBarsRepeater.itemAt(i)
				if (!animationTarget) {
					// Don't set animation targets until all bar delegates have been initialized
					return
				}
				if (i % 2 == 0) {
					evenTargets.push(animationTarget)
				} else {
					oddTargets.push(animationTarget)
				}
			}
			barAnimation._evenAnimationTargets = evenTargets
			barAnimation._oddAnimationTargets = oddTargets
			if (root._animationReady) {
				barAnimation.restart()
			}
		}

		loops: Animation.Infinite
		running: root._animationReady

		ParallelAnimation {
			NumberAnimation {
				targets: barAnimation._evenAnimationTargets
				property: "barWidth"
				from: Theme.geometry.overviewPage.widget.battery.animatedBar.maximumWidth
				to: Theme.geometry.overviewPage.widget.battery.animatedBar.minimumWidth
				duration: 800
				alwaysRunToEnd: true
			}
			NumberAnimation {
				targets: barAnimation._oddAnimationTargets
				property: "barWidth"
				from: Theme.geometry.overviewPage.widget.battery.animatedBar.minimumWidth
				to: Theme.geometry.overviewPage.widget.battery.animatedBar.maximumWidth
				duration: 800
				alwaysRunToEnd: true
			}
		}
		PauseAnimation {
			duration: 200
		}
		ParallelAnimation {
			NumberAnimation {
				targets: barAnimation._evenAnimationTargets
				property: "barWidth"
				from: Theme.geometry.overviewPage.widget.battery.animatedBar.minimumWidth
				to: Theme.geometry.overviewPage.widget.battery.animatedBar.maximumWidth
				duration: 800
				alwaysRunToEnd: true
			}
			NumberAnimation {
				targets: barAnimation._oddAnimationTargets
				property: "barWidth"
				from: Theme.geometry.overviewPage.widget.battery.animatedBar.maximumWidth
				to: Theme.geometry.overviewPage.widget.battery.animatedBar.minimumWidth
				duration: 800
				alwaysRunToEnd: true
			}
		}
		PauseAnimation {
			duration: 200
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

		value: batteryData
			? Math.round(Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Celsius
				? batteryData.temperature_celsius
				: Units.celsiusToFahrenheit(batteryData.temperature_celsius))
			: NaN
		unit: !!Global.systemSettings.temperatureUnit.value ? Global.systemSettings.temperatureUnit.value : VenusOS.Units_Temperature_Celsius
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
				text: batteryData && batteryData.mode === VenusOS.Battery_Mode_Idle
						//% "Idle"
					  ? qsTrId("overview_widget_battery_idle")
					  : (batteryData && batteryData.mode === VenusOS.Battery_Mode_Charging
						  //% "Charging"
						? qsTrId("overview_widget_battery_charging")
						  //% "Discharging"
						: qsTrId("overview_widget_battery_discharging"))
				font.pixelSize: Theme.font.size.body1
				color: Theme.color.font.secondary
			}
			Label {
				readonly property var timeToGo: Global.batteries.daysHoursMinutesToGo
				text: {
					if (!Global.batteries.first || !Global.batteries.first.timeToGo || Global.batteries.first.timeToGo < 0) {
						return ""
					} else if (timeToGo.d > 0) {
						//% "%1d %2h %3m"
						return qsTrId("battery_widget_time_to_go_days_hours_minutes").arg(timeToGo.d).arg(timeToGo.h).arg(timeToGo.m)
					} else if (timeToGo.h > 0) {
						//% "%2h %3m"
						return qsTrId("battery_widget_time_to_go_hours_minutes").arg(timeToGo.h).arg(timeToGo.m)
					} else {
						//% "%3m"
						return qsTrId("battery_widget_time_to_go_minutes").arg(timeToGo.m)
					}
				}
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

			value: batteryData ? batteryData.voltage.toFixed(1) : NaN
			unit: VenusOS.Units_Volt
			font.pixelSize: Theme.font.size.body2
		},

		QuantityLabel {
			id: batteryCurrentDisplay

			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: Theme.geometry.overviewPage.widget.battery.bottomRow.bottomMargin
			}
			value: batteryData ? batteryData.current.toFixed(1) : NaN
			unit: VenusOS.Units_Amp
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
			value: batteryData ? batteryData.power.toFixed(1) : NaN
			unit: VenusOS.Units_Watt
			font.pixelSize: Theme.font.size.body2
		}
	]
}
