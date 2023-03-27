/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "/components/Gauges.js" as Gauges

Page {
	id: root

	property bool _sidePanelActive
	property real _gaugeArcMargin: Theme.geometry.briefPage.edgeGauge.initialize.margin
	property real _gaugeLabelMargin: Theme.geometry.briefPage.edgeGauge.label.initialize.margin
	property real _gaugeArcOpacity: 0
	property real _gaugeLabelOpacity: 0
	property bool _animationEnabled
	readonly property string _gridIcon: {
		const totalInputs = (Global.acInputs.connectedInput != null ? 1 : 0)
				+ Global.dcInputs.model.count
		if (totalInputs <= 1) {
			if (Global.acInputs.connectedInput != null) {
				return VenusOS.acInputIcon(Global.acInputs.connectedInput.source)
			} else if (Global.acInputs.generatorInput != null) {
				return VenusOS.acInputIcon(Global.acInputs.generatorInput.source)
			} else if (Global.dcInputs.model.count > 0) {
				return VenusOS.dcInputIcon(Global.dcInputs.model.get(0).source)
			}
		}
		return "qrc:/images/icon_input_24.svg"
	}

	backgroundColor: Theme.color.briefPage.background
	fullScreenWhenIdle: true
	topRightButton: _sidePanelActive
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
		sourceComponent: Global.tanks.totalTankCount <= 1 ? singleGauge : multiGauge
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load main gauge")
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
			alignment: Qt.AlignLeft | (leftLower.active ? Qt.AlignTop : Qt.AlignVCenter)
			arcX: leftLower.active ? undefined : 10
			direction: PathArc.Clockwise
			startAngle: leftLower.active ? 270 : (270 - Theme.geometry.briefPage.largeEdgeGauge.maxAngle / 2)
			animationEnabled: root._animationEnabled

			x: root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			label.leftMargin: root._gaugeLabelMargin - root._gaugeArcMargin
			label.opacity: root._gaugeLabelOpacity

			icon.source: root._gridIcon

			// AC and DC amp values cannot be combined. If there are both AC and DC values, show
			// Watts even if Amps is preferred.
			quantityLabel.unit: Global.systemSettings.energyUnit.value === VenusOS.Units_Energy_Amp
					&& ((Global.acInputs.current || 0) === 0 || (Global.dcInputs.current || 0) === 0)
					   ? VenusOS.Units_Energy_Amp
					   : VenusOS.Units_Energy_Watt
			quantityLabel.value: quantityLabel.unit === VenusOS.Units_Energy_Amp
					? (Global.acInputs.current || 0) === 0
					  ? Global.dcInputs.current
					  : Global.acInputs.current
					: Utils.sumRealNumbers(Global.acInputs.power, Global.dcInputs.power)

			// Gauge always shows the watts value, and ignores the current.
			value: inputPowerRange.valueAsRatio * 100

			ValueRange {
				id: inputPowerRange
				value: (Global.acInputs.power || 0) + (Global.dcInputs.power || 0)
			}
		}
		onStatusChanged: if (status === Loader.Error) console.warn("Unable to load left edge")
	}

	Loader {
		id: leftLower

		anchors {
			top: leftEdge.bottom
			topMargin: leftEdge.active ? Theme.geometry.briefPage.lowerGauge.topMargin : 0
			left: parent.left
			leftMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			right: mainGauge.left
		}
		active: Global.solarChargers.model.count > 0

		sourceComponent: SolarYieldGauge {
			alignment: Qt.AlignLeft | (leftEdge.active ? Qt.AlignBottom : Qt.AlignVCenter)
			x: root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			label.leftMargin: root._gaugeLabelMargin - root._gaugeArcMargin
			label.opacity: root._gaugeLabelOpacity
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
			animationEnabled: root._animationEnabled
			icon.source: rightLower.active ? "qrc:/images/acloads.svg" : "qrc:/images/consumption.svg"
			value: acLoadsRange.valueAsRatio * 100
			quantityLabel.dataObject: Global.system.ac.consumption

			x: -root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			label.leftMargin: -root._gaugeLabelMargin + root._gaugeArcMargin
			label.opacity: root._gaugeLabelOpacity

			ValueRange {
				id: acLoadsRange
				value: Global.system.loads.acPower || 0
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
			animationEnabled: root._animationEnabled
			icon.source: "qrc:/images/dcloads.svg"
			value: dcLoadsRange.valueAsRatio * 100
			quantityLabel.dataObject: Global.system.dc

			x: -root._gaugeArcMargin
			opacity: root._gaugeArcOpacity
			label.leftMargin: -root._gaugeLabelMargin + root._gaugeArcMargin
			label.opacity: root._gaugeLabelOpacity

			ValueRange {
				id: dcLoadsRange
				value: Global.system.loads.dcPower || 0
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
		gridIcon: root._gridIcon

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

	Connections {
		target: Global.pageManager.statusBar
		enabled: root.isCurrentPage

		function onRightButtonClicked() {
			root._sidePanelActive = !root._sidePanelActive
		}
	}

	states: [
		State {
			name: "initialized"
			when: !Global.splashScreenVisible && !root._sidePanelActive
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
			when: root._sidePanelActive
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
