/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils
import Victron.Units
import Victron.Gauges

Page {
	id: root

	property real _gaugeArcMargin: Theme.geometry.briefPage.edgeGauge.initialize.margin
	property real _gaugeLabelMargin: Theme.geometry.briefPage.edgeGauge.label.initialize.margin
	property real _gaugeArcOpacity: 0
	property real _gaugeLabelOpacity: 0
	readonly property string _inputsIconSource: {
		const totalInputs = (Global.acInputs.connectedInput != null ? 1 : 0)
				+ Global.dcInputs.model.count
		if (totalInputs <= 1) {
			if (Global.acInputs.connectedInput != null) {
				return VenusOS.acInputIcon(Global.acInputs.connectedInput.source)
			} else if (Global.acInputs.generatorInput != null) {
				return VenusOS.acInputIcon(Global.acInputs.generatorInput.source)
			} else if (Global.dcInputs.model.count > 0) {
				return VenusOS.dcInputIcon(Global.dcInputs.model.deviceAt(0).source)
			}
		}
		return "qrc:/images/icon_input_24.svg"
	}

	backgroundColor: Theme.color.briefPage.background
	fullScreenWhenIdle: true
	animationEnabled: root.isCurrentPage && BackendConnection.applicationVisible && !Global.splashScreenVisible
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
	topRightButton: sidePanel.active
			? VenusOS.StatusBar_RightButton_SidePanelActive
			: VenusOS.StatusBar_RightButton_SidePanelInactive

	Loader {
		id: mainGauge

		anchors {
			top: parent.top
			topMargin: Theme.geometry.mainGauge.topMargin
		}
		width: Theme.geometry.mainGauge.size
		height: width
		x: sidePanel.x/2 - width/2
		sourceComponent: Global.tanks.totalTankCount === 0 ? singleGauge : multiGauge
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load main gauge")
	}

	Component {
		id: multiGauge

		CircularMultiGauge {
			model: GaugeModel {
				sourceModel: Gauges.briefCentralGauges
				maximumGaugeCount: Theme.geometry.briefPage.centerGauge.maximumGaugeCount
			}
			animationEnabled: root.animationEnabled
			labelOpacity: root._gaugeLabelOpacity
			labelMargin: root._gaugeLabelMargin
		}
	}

	Component {
		id: singleGauge

		CircularSingleGauge {
			readonly property var properties: Gauges.tankProperties(VenusOS.Tank_Type_Battery)
			readonly property var battery: Global.batteries.system

			name: properties.name
			icon.source: battery.icon
			value: (!visible || isNaN(battery.stateOfCharge)) ? 0 : Math.round(battery.stateOfCharge)
			voltage: battery.voltage
			current: battery.current
			status: Gauges.getValueStatus(value, properties.valueType)
			caption: Global.batteries.timeToGoText(battery, VenusOS.Battery_TimeToGo_LongFormat)
			animationEnabled: root.animationEnabled
			shineAnimationEnabled: battery.mode === VenusOS.Battery_Mode_Charging && root.animationEnabled
		}
	}

	Loader {
		id: leftEdge

		anchors {
			top: parent.top
			topMargin: Theme.geometry.briefPage.edgeGauge.topMargin
			left: parent.left
			leftMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			right: mainGauge.left
		}
		// Show gauge even if there are no active AC inputs, so that the gauge visibility doesn't
		// jump on/off when inputs are connected/disconnected
		active: Global.acInputs.model.count > 0 || Global.dcInputs.model.count > 0

		sourceComponent: SideGauge {
			alignment: Qt.AlignLeft | (leftLower.active ? Qt.AlignTop : Qt.AlignVCenter)
			arcX: leftLower.active ? undefined : 10
			direction: PathArc.Clockwise
			startAngle: leftLower.active ? 270 : (270 - Theme.geometry.briefPage.largeEdgeGauge.maxAngle / 2)
			animationEnabled: root.animationEnabled

			// Gauge color changes only apply when there is a maximum value.
			valueType: isNaN(inputsRange.maximumValue)
					   ? VenusOS.Gauges_ValueType_NeutralPercentage
					   : VenusOS.Gauges_ValueType_RisingPercentage

			x: root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			label.leftMargin: root._gaugeLabelMargin - root._gaugeArcMargin
			label.opacity: root._gaugeLabelOpacity

			icon.source: root._inputsIconSource

			// AC and DC amp values cannot be combined. If there are both AC and DC values, show
			// Watts even if Amps is preferred.
			quantityLabel.unit: Global.systemSettings.electricalQuantity.value === VenusOS.Units_Amp
					&& ((Global.acInputs.current || 0) === 0 || (Global.dcInputs.current || 0) === 0)
					   ? VenusOS.Units_Amp
					   : VenusOS.Units_Watt
			quantityLabel.value: quantityLabel.unit === VenusOS.Units_Amp
					? (Global.acInputs.current || 0) === 0
					  ? Global.dcInputs.current
					  : Global.acInputs.current
					: Units.sumRealNumbers(Global.acInputs.power, Global.dcInputs.power)

			value: !visible ? 0 : inputsRange.valueAsRatio * 100

			ValueRange {
				id: inputsRange

				value: quantityLabel.value

				// When showing current instead of power, set a max value to change the gauge colors
				// when the value approaches the currentLimit.
				maximumValue: quantityLabel.unit === VenusOS.Units_Amp
					? Global.acInputs.currentLimit
					: NaN
			}
		}
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load left edge")
	}

	Loader {
		id: leftLower

		anchors {
			top: leftEdge.active ? leftEdge.bottom : parent.top
			topMargin: leftEdge.active ? Theme.geometry.briefPage.lowerGauge.topMargin : Theme.geometry.briefPage.edgeGauge.topMargin
			left: parent.left
			leftMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			right: mainGauge.left
		}
		active: Global.solarChargers.model.count > 0 || Global.pvInverters.model.count > 0

		sourceComponent: SolarYieldGauge {
			alignment: Qt.AlignLeft | (leftEdge.active ? Qt.AlignBottom : Qt.AlignVCenter)
			x: root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			label.leftMargin: root._gaugeLabelMargin - root._gaugeArcMargin
			label.opacity: root._gaugeLabelOpacity
			animationEnabled: root.animationEnabled
		}
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load left lower")
	}

	Loader {
		id: rightEdge

		anchors {
			top: parent.top
			topMargin: Theme.geometry.briefPage.edgeGauge.topMargin
			right: parent.right
			rightMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			left: mainGauge.right
		}
		active: !isNaN(Global.system.loads.acPower) || rightLower.active
		sourceComponent: SideGauge {
			alignment: Qt.AlignRight | (rightLower.active ? Qt.AlignTop : Qt.AlignVCenter)
			animationEnabled: root.animationEnabled
			icon.source: rightLower.active ? "qrc:/images/acloads.svg" : "qrc:/images/consumption.svg"
			value: !visible ? 0 : acLoadsRange.valueAsRatio * 100
			quantityLabel.dataObject: Global.system.ac.consumption

			x: -root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			label.leftMargin: -root._gaugeLabelMargin + root._gaugeArcMargin
			label.opacity: root._gaugeLabelOpacity

			ValueRange {
				id: acLoadsRange
				value: root.visible ? Global.system.loads.acPower || 0 : 0
				maximumValue: Global.system.loads.maximumAcPower
			}
		}
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load right edge")
	}

	Loader {
		id: rightLower

		anchors {
			top: rightEdge.bottom
			topMargin: Theme.geometry.briefPage.lowerGauge.topMargin
			right: parent.right
			rightMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			left: mainGauge.right
		}
		active: !isNaN(Global.system.loads.dcPower)
		sourceComponent: SideGauge {
			alignment: Qt.AlignRight | Qt.AlignBottom
			animationEnabled: root.animationEnabled
			icon.source: "qrc:/images/dcloads.svg"
			value: visible ? dcLoadsRange.valueAsRatio * 100 : 0
			quantityLabel.dataObject: Global.system.dc

			x: -root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			label.leftMargin: -root._gaugeLabelMargin + root._gaugeArcMargin
			label.opacity: root._gaugeLabelOpacity

			ValueRange {
				id: dcLoadsRange
				value: root.visible ? Global.system.loads.dcPower || 0 : 0
			}
		}
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load right lower")
	}

	BriefMonitorPanel {
		id: sidePanel

		anchors {
			verticalCenter: mainGauge.verticalCenter
			verticalCenterOffset: Theme.geometry.briefPage.sidePanel.verticalCenterOffset
		}
		width: Theme.geometry.briefPage.sidePanel.width
		inputsIconSource: root._inputsIconSource
		animationEnabled: root.animationEnabled && sidePanel.active

		// hidden by default.
		property bool active: false
		x: root.width
		opacity: 0.0
		visible: false
	}

	Connections {
		target: !!Global.pageManager ? Global.pageManager.statusBar : null
		enabled: root.isCurrentPage

		function onRightButtonClicked() {
			sidePanel.active = !sidePanel.active
		}
	}

	states: [
		State {
			name: "initialized"
			when: !Global.splashScreenVisible && !sidePanel.active
			PropertyChanges {
				target: root
				_gaugeArcMargin: 0
				_gaugeLabelMargin: 0
				_gaugeArcOpacity: 1
				_gaugeLabelOpacity: 1
			}
		},
		State {
			name: "panelOpen"
			extend: "initialized"
			when: sidePanel.active
			PropertyChanges {
				target: sidePanel
				x: root.width - sidePanel.width - Theme.geometry.page.content.horizontalMargin
				opacity: 1
			}
			PropertyChanges {
				target: root
				_gaugeArcOpacity: 0
				_gaugeLabelOpacity: 1
			}
		}
	]

	transitions: [
		Transition {
			from: ""
			to: "initialized"
			SequentialAnimation {
				ParallelAnimation {
					NumberAnimation {
						target: root
						properties: "_gaugeArcOpacity,_gaugeArcMargin"
						duration: Theme.animation.briefPage.gaugeArc.initialize.duration
					}
					SequentialAnimation {
						PauseAnimation {
							duration: Theme.animation.briefPage.gaugeLabel.initialize.delayedStart.duration
						}
						NumberAnimation {
							target: root
							properties: "_gaugeLabelOpacity,_gaugeLabelMargin"
							duration: Theme.animation.briefPage.gaugeLabel.initialize.duration
						}
					}
				}
			}
		},
		Transition {
			to: "panelOpen"
			from: "initialized"
			SequentialAnimation {
				NumberAnimation {
					target: root
					properties: "_gaugeArcOpacity,_gaugeLabelOpacity"
					duration: Theme.animation.briefPage.edgeGauge.fade.duration
				}
				ScriptAction { script: sidePanel.visible = true }
				NumberAnimation {
					target: sidePanel
					properties: 'x,opacity'
					duration: Theme.animation.briefPage.sidePanel.slide.duration
					easing.type: Easing.InQuad
				}
			}
		},
		Transition {
			to: "initialized"
			from: "panelOpen"
			SequentialAnimation {
				NumberAnimation {
					target: sidePanel
					properties: 'x,opacity'
					duration: Theme.animation.briefPage.sidePanel.slide.duration
					easing.type: Easing.InQuad
				}
				ScriptAction { script: sidePanel.visible = false }
				NumberAnimation {
					target: root
					properties: "_gaugeArcOpacity,_gaugeLabelOpacity"
					duration: Theme.animation.briefPage.edgeGauge.fade.duration
				}
			}
		}
	]
}
