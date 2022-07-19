/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "/components/Gauges.js" as Gauges

Page {
	id: root

	property real _gaugeArcMargin: Theme.animation.briefPage.gaugeArc.initialize.margin
	property real _gaugeLabelMargin: Theme.animation.briefPage.gaugeLabel.initialize.margin
	property real _gaugeArcOpacity: 0
	property real _gaugeLabelOpacity: 0
	property bool _animationEnabled

	hasSidePanel: true
	backgroundColor: Theme.color.briefPage.background
	fullScreenWhenIdle: true

	Loader {
		id: mainGauge

		anchors {
			top: parent.top
			topMargin: Theme.geometry.mainGauge.topMargin
		}
		width: Theme.geometry.mainGauge.size
		height: width
		x: sidePanel.x/2 - width/2
		sourceComponent: Global.tanks.totalTankCount <= 1 ? singleGauge : multiGauge
	}

	Component {
		id: multiGauge

		CircularMultiGauge {
			model: gaugeData.model
			animationEnabled: root._animationEnabled
			labelOpacity: root._gaugeLabelOpacity
			labelMargin: root._gaugeLabelMargin
		}
	}

	Component {
		id: singleGauge

		CircularSingleGauge {
			readonly property var properties: Gauges.tankProperties(VenusOS.Tank_Type_Battery)

			name: properties.name
			icon.source: Global.battery.icon
			value: Math.round(Global.battery.stateOfCharge || 0)
			status: Gauges.getValueStatus(value, properties.valueType)
			caption: Global.battery.timeToGo > 0 ? Utils.formatAsHHMM(Global.battery.timeToGo, true) : ""
			animationEnabled: root._animationEnabled
			shineAnimationEnabled: Global.battery.mode === VenusOS.Battery_Mode_Charging
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
			gaugeAlignmentX: Qt.AlignLeft
			gaugeAlignmentY: leftLower.active ? Qt.AlignTop : Qt.AlignVCenter
			arcX: leftLower.active ? undefined : 10
			direction: PathArc.Clockwise
			startAngle: leftLower.active ? 270 : (270 - Theme.geometry.briefPage.largeEdgeGauge.maxAngle / 2)
			animationEnabled: root._animationEnabled

			x: root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			label.leftMargin: root._gaugeLabelMargin - root._gaugeArcMargin
			label.opacity: root._gaugeLabelOpacity

			icon.source: {
				const totalInputs = (Global.acInputs.connectedInput != null ? 1 : 0)
						+ Global.dcInputs.model.count
				if (totalInputs <= 1) {
					if (Global.acInputs.connectedInput !== null) {
						return VenusOS.acInputIcon(Global.acInputs.connectedInput.source)
					} else if (Global.acInputs.generatorInput !== null) {
						return VenusOS.acInputIcon(Global.acInputs.generatorInput.source)
					} else if (Global.dcInputs.model.count > 0) {
						return VenusOS.dcInputIcon(Global.dcInputs.model.get(0).source)
					}
				}
				return "qrc:/images/icon_input_24.svg"
			}
			value: ((Global.acInputs.power || 0) + (Global.dcInputs.power || 0))
					/ Utils.maximumValue("briefPage.inputsPower")
			onValueChanged: Utils.updateMaximumValue("briefPage.inputsPower", value)

			// AC and DC amp values cannot be combined. If there are both AC and DC values, show
			// Watts even if Amps is preferred.
			quantityLabel.unit: Global.systemSettings.energyUnit === VenusOS.Units_Energy_Amp
					&& (Global.acInputs.current || 0 === 0) || (Global.dcInputs.current || 0 === 0)
					   ? VenusOS.Units_Energy_Amp
					   : VenusOS.Units_Energy_Watt
			quantityLabel.value: quantityLabel.unit === VenusOS.Units_Energy_Amp
					? (Global.acInputs.current || 0 === 0)
					  ? Global.dcInputs.current
					  : Global.acInputs.current
					: Utils.sumRealNumbers(Global.acInputs.power, Global.dcInputs.power)
		}
	}

	Loader {
		id: leftLower

		anchors {
			top: leftEdge.bottom
			topMargin: Theme.geometry.briefPage.lowerGauge.topMargin
			left: parent.left
			leftMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			right: mainGauge.left
		}
		active: Global.solarChargers.model.count > 0

		sourceComponent: SolarYieldGauge {
			gaugeAlignmentY: Qt.AlignBottom

			x: root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			label.leftMargin: root._gaugeLabelMargin - root._gaugeArcMargin
			label.opacity: root._gaugeLabelOpacity
		}
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
			gaugeAlignmentY: rightLower.active ? Qt.AlignTop : Qt.AlignVCenter
			animationEnabled: root._animationEnabled
			icon.source: rightLower.active ? "qrc:/images/acloads.svg" : "qrc:/images/consumption.svg"
			value: (Global.system.loads.acPower || 0) / Utils.maximumValue("system.loads.acPower") * 100
			quantityLabel.dataObject: Global.system.ac.consumption

			x: -root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			label.leftMargin: -root._gaugeLabelMargin + root._gaugeArcMargin
			label.opacity: root._gaugeLabelOpacity
		}
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
			gaugeAlignmentY: Qt.AlignBottom
			animationEnabled: root._animationEnabled
			icon.source: "qrc:/images/dcloads.svg"
			value: (Global.system.loads.dcPower || 0) / Utils.maximumValue("system.loads.dcPower") * 100
			quantityLabel.dataObject: Global.system.dc

			x: -root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			label.leftMargin: -root._gaugeLabelMargin + root._gaugeArcMargin
			label.opacity: root._gaugeLabelOpacity
		}
	}

	BriefMonitorPanel {
		id: sidePanel

		anchors {
			verticalCenter: mainGauge.verticalCenter
			verticalCenterOffset: Theme.geometry.briefPage.sidePanel.verticalCenterOffset
		}
		width: Theme.geometry.briefPage.sidePanel.width

		// hidden by default.
		x: root.width
		opacity: 0.0
	}

	Item {
		id: gaugeData

		property ListModel model: ListModel {
			Component.onCompleted: {
				for (let i = 0; i < Global.systemSettings.briefView.gauges.count; ++i) {
					const tankType = Global.systemSettings.briefView.gauges.get(i).value
					append(Object.assign({},
						   Gauges.tankProperties(tankType),
						   { tankType: tankType, value: 0 }))
				}
			}
		}

		Instantiator {
			id: gaugeObjects

			model: Global.systemSettings.briefView.gauges

			delegate: QtObject {
				readonly property int tankType: model.value
				readonly property bool isBattery: tankType === VenusOS.Tank_Type_Battery
				readonly property string tankName: _tankProperties.name
				readonly property string tankIcon: isBattery ? Global.battery.icon : _tankProperties.icon
				readonly property var tankModel: isBattery ? 1 : Global.tanks.tankModel(tankType)
				property bool deleted

				readonly property real tankLevel: isBattery
						? Math.round(Global.battery.stateOfCharge || 0)
						: (tankModel.count === 0 || tankModel.totalCapacity === 0
						   ? 0
						   : (tankModel.totalRemaining / tankModel.totalCapacity) * 100)

				readonly property var _tankProperties: Gauges.tankProperties(tankType)

				function updateGaugeModel() {
					if (deleted) {
						return
					}
					if (model.index < gaugeData.model.count) {
						gaugeData.model.set(model.index, { name: tankName, icon: tankIcon, value: tankLevel })
					}
				}

				// If tank data changes, update the model at the end of the event loop to avoid
				// excess updates if multiple values change simultaneously for the same tank.
				onTankNameChanged: Qt.callLater(updateGaugeModel)
				onTankIconChanged: Qt.callLater(updateGaugeModel)
				onTankLevelChanged: Qt.callLater(updateGaugeModel)

				Component.onDestruction: deleted = true
			}
		}
	}

	states: [
		State {
			name: "initialized"
			when: !Global.splashScreenVisible && !Global.pageManager.sidePanelActive
			PropertyChanges {
				target: root
				_gaugeArcMargin: 0
				_gaugeLabelMargin: 0
				_gaugeArcOpacity: 1
				_gaugeLabelOpacity: 1
				_animationEnabled: root.isCurrentPage
			}
		},
		State {
			name: "panelOpen"
			extend: "initialized"
			when: Global.pageManager.sidePanelActive
			PropertyChanges {
				target: sidePanel
				x: root.width - sidePanel.width - Theme.geometry.page.content.horizontalMargin
				opacity: 1
			}
			PropertyChanges {
				target: root
				_gaugeArcOpacity: 0
				_gaugeLabelOpacity: 0
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
				NumberAnimation {
					target: root
					properties: "_gaugeArcOpacity,_gaugeLabelOpacity"
					duration: Theme.animation.briefPage.edgeGauge.fade.duration
				}
			}
		}
	]
}
