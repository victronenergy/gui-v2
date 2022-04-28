/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "/components/Gauges.js" as Gauges

Page {
	id: root

	readonly property bool solarYieldPresent: Global.solarChargers.model.count > 0

	readonly property bool generatorPresent: !isNaN(Global.system.generator.power)
	readonly property real generatorPower: Global.system.generator.power
	readonly property real generatorPowerPercentage: generatorPower / Utils.maximumValue("system.generator.power") * 100

	readonly property bool acLoadPresent: Global.system.ac.consumption.power
	readonly property real acLoad: acLoadPresent ? Global.system.ac.consumption.power : 0
	readonly property real acLoadPercentage: acLoad / Utils.maximumValue("system.ac.consumption.power") * 100

	readonly property bool dcLoadPresent: !isNaN(Global.system.dc.power)
	readonly property real dcLoad: dcLoadPresent ? Global.system.dc.power : 0
	readonly property real dcLoadPercentage: dcLoad / Utils.maximumValue("system.dc.power") * 100

	readonly property bool combinedLoadPresent: !isNaN(Global.system.loads.power)
	readonly property real combinedLoad: combinedLoadPresent ? Global.system.loads.power : 0
	readonly property real combinedLoadPercentage: combinedLoadPresent ? Global.system.loads.power / Utils.maximumValue("system.loads.power") * 100 : 0

	property var leftGaugeTypes: []
	property var rightGaugeTypes: []
	property real sideOpacity: 1

	function populateSideGauges() {
		// Determine which side gauges are to be displayed
		let leftTypes = []
		let rightTypes = []
		if (generatorPresent) {
			leftTypes.push('generator')
		}
		if (solarYieldPresent) {
			leftTypes.push('solar')
		}
		if (acLoadPresent && dcLoadPresent) {
			rightTypes.push('combinedload')
		} else {
			if (acLoadPresent) {
				rightTypes.push('acload')
			}
			if (dcLoadPresent) {
				rightTypes.push('dcload')
			}
		}

		leftGaugeTypes = leftTypes
		rightGaugeTypes = rightTypes
	}

	hasSidePanel: true
	backgroundColor: Theme.color.briefPage.background
	fullScreenWhenIdle: true

	onSolarYieldPresentChanged: root.populateSideGauges()
	onGeneratorPresentChanged: root.populateSideGauges()
	onDcLoadPresentChanged: root.populateSideGauges()
	onAcLoadPresentChanged: root.populateSideGauges()

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
			animationEnabled: root.isCurrentPage
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
			animationEnabled: root.isCurrentPage
		}
	}

	Loader {
		id: leftEdge

		readonly property string gaugeType: leftGaugeTypes.length >= 1 ? leftGaugeTypes[0] : ''

		onGaugeTypeChanged: {
			if (gaugeType === 'generator') {
				setSource('qrc:/components/SideGauge.qml', {
					"gaugeAlignmentX": Qt.AlignLeft,
					"gaugeAlignmentY": Qt.binding(function() { return leftGaugeTypes.length === 2 ? Qt.AlignTop : Qt.AlignVCenter } ),
					"arcX": Qt.binding(function() { return leftGaugeTypes.length === 1 ? 10 : undefined } ),
					"direction": PathArc.Clockwise,
					"startAngle": Qt.binding(function() { return leftGaugeTypes.length === 2 ? 270 : (270 - Theme.geometry.briefPage.largeEdgeGauge.maxAngle / 2)} ),
					"animationEnabled": Qt.binding(function() { return root.isCurrentPage } ),
					"source": "qrc:/images/generator.svg",
					"value": Qt.binding(function() { return generatorPowerPercentage }),
					"textValue": Qt.binding(function() { return generatorPower })
				})
			} else if (gaugeType === 'solar'){
				setSource('qrc:/components/SolarYieldGauge.qml', {"gaugeAlignmentY": Qt.AlignVCenter})
			}
		}
		anchors {
			top: parent.top
			topMargin: Theme.geometry.briefPage.edgeGauge.topMargin
			left: parent.left
			leftMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			right: mainGauge.left
		}
		active: leftGaugeTypes.length >= 1
		opacity: root.sideOpacity
	}

	Loader {
		id: leftLower

		readonly property string gaugeType: leftGaugeTypes.length === 2 ? leftGaugeTypes[1] : ''

		onGaugeTypeChanged: setSource('qrc:/components/SolarYieldGauge.qml', {"gaugeAlignmentY": Qt.AlignBottom})
		anchors {
			top: leftGaugeTypes.length, leftEdge.bottom
			topMargin: Theme.geometry.briefPage.lowerGauge.topMargin
			left: parent.left
			leftMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			right: mainGauge.left
		}
		active: leftGaugeTypes.length === 2
		opacity: root.sideOpacity
	}

	Loader {
		id: rightEdge

		readonly property string gaugeType: rightGaugeTypes.length >= 1 ? rightGaugeTypes[0] : ''

		onGaugeTypeChanged: {
			setSource('qrc:/components/SideGauge.qml', {
				"gaugeAlignmentY": Qt.binding(function(){ return rightGaugeTypes.length == 2 ? Qt.AlignTop : Qt.AlignVCenter }),
				"animationEnabled": Qt.binding(function() { return root.isCurrentPage } ),
				"source": Qt.binding(function() {
					return rightGaugeTypes.length == 2 ?
						(gaugeType === 'acload' ? "qrc:/images/acloads.svg" : "qrc:/images/dcloads.svg") : "qrc:/images/consumption.svg"
				}),
				"value": Qt.binding(function() {
					return rightGaugeTypes.length == 2 ? (gaugeType === 'acload' ? acLoadPercentage : dcLoadPercentage) : combinedLoadPercentage
				}),
				"textValue": Qt.binding(function() {
					return rightGaugeTypes.length == 2 ? (gaugeType === 'acload' ? acLoad : dcLoad) : combinedLoad
				})
			})
		}
		anchors {
			top: parent.top
			topMargin: Theme.geometry.briefPage.edgeGauge.topMargin
			right: parent.right
			rightMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			left: mainGauge.right
		}
		opacity: root.sideOpacity
		active: rightGaugeTypes.length >= 1
	}

	Loader {
		id: rightLower

		readonly property string gaugeType: rightGaugeTypes.length === 2 ? rightGaugeTypes[1] : ''

		onGaugeTypeChanged: {
			setSource('qrc:/components/SideGauge.qml', {
				"animationEnabled": Qt.binding(function() { return root.isCurrentPage } ),
				"gaugeAlignmentY": Qt.AlignBottom,
				"source": Qt.binding(function() { return (gaugeType === 'acload' ? "qrc:/images/acloads.svg" : "qrc:/images/dcloads.svg") }),
				"value": Qt.binding(function() { return gaugeType === 'acload' ? acLoadPercentage : dcLoadPercentage }),
				"textValue": Qt.binding(function() { return gaugeType === 'acload' ? acLoad : dcLoad })
			})
		}
		anchors {
			top: rightEdge.bottom
			topMargin: Theme.geometry.briefPage.lowerGauge.topMargin
			right: parent.right
			rightMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			left: mainGauge.right
		}
		opacity: root.sideOpacity
		active: rightGaugeTypes.length === 2
	}

	BriefMonitorPanel {
		id: sidePanel

		anchors {
			top: parent.top
			topMargin: Theme.geometry.briefPage.sidePanel.topMargin
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

	state: Global.pageManager.sidePanelActive ? 'panelOpen' : ''
	states: State {
		name: 'panelOpen'
		PropertyChanges {
			target: sidePanel
			x: root.width - sidePanel.width - Theme.geometry.page.content.horizontalMargin
			opacity: 1
		}
		PropertyChanges {
			target: root
			sideOpacity: 0
		}
	}

	transitions: [
		Transition {
			to: "panelOpen"
			from: ""
			SequentialAnimation {
				NumberAnimation {
					target: root
					property: 'sideOpacity'
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
			to: ""
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
					property: 'sideOpacity'
					duration: Theme.animation.briefPage.edgeGauge.fade.duration
				}
			}
		}
	]
}
