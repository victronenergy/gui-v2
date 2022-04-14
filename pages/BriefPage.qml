/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "../data"

Page {
	id: root

	readonly property bool solarYieldPresent: solarChargers && solarChargers.model.count > 0
	readonly property bool generatorPresent: !!generator0
	readonly property bool loadPresent: true    // TODO check for AC,DC inputs

	property var leftGaugeTypes: []
	property var rightGaugeTypes: []
	property real sideOpacity: 1

	function populateSideGauges() {
		// Determine which side gauges are to be displayed
		let leftTypes = []
		let rightTypes = []
		if (generatorPresent) {
			leftTypes.push('GeneratorLeftGauge.qml')
		}
		if (solarYieldPresent) {
			leftTypes.push('SolarYieldGauge.qml')
		}
		if (loadPresent) {
			rightTypes.push('LoadMiniGauge.qml')
		}
		if (loadPresent) { // TODO - "The two arcs for output layout is a solution for cases where we can not merge AC and DC data"
			rightTypes.push('LoadMiniGauge.qml')
		}
		leftGaugeTypes = leftTypes
		rightGaugeTypes = rightTypes
	}

	property var gauges2: ['GeneratorLeftGauge.qml', 'SolarYieldGauge.qml']
	property var gauges3: ['GeneratorLeftGauge.qml']
	property var gauges4: ['SolarYieldGauge.qml']
	property int dummyIndex: 0
	property var dummyGauges: [gauges2, gauges3, gauges4]

	function nextGauge() {
		leftGaugeTypes = dummyGauges[dummyIndex % dummyGauges.length]
		console.log("nextGauge()", leftGaugeTypes)
		dummyIndex++
	}

	Timer {
		interval: 1000
		//running: true
		repeat: true
		onTriggered: {
			leftGaugeTypes = dummyGauges[dummyIndex % dummyGauges.length]
			console.log("onTriggered", leftGaugeTypes)
			dummyIndex++
		}
	}


	onSolarYieldPresentChanged: root.populateSideGauges()
	onGeneratorPresentChanged: root.populateSideGauges()
	onLoadPresentChanged: root.populateSideGauges()

	Loader {
		id: mainGauge

		property bool multipleValues: gaugeData.model.count > 1

		anchors {
			top: parent.top
			topMargin: Theme.geometry.mainGauge.topMargin
		}
		width: Theme.geometry.mainGauge.size
		height: width
		x: sidePanel.x/2 - width/2
		sourceComponent: gaugeData.model.count === 0 ? null : (multipleValues ? multiGauge : singleGauge)
	}

	Component {
		id: multiGauge

		CircularMultiGauge {
			model: gaugeData.model
		}
	}

	Component {
		id: singleGauge

		CircularSingleGauge {
			model: gaugeData.model.count > 0 ? gaugeData.model.get(0) : null
			caption: battery && battery.timeToGo > 0 ? Utils.formatAsHHMM(battery.timeToGo, true) : ""
		}
	}

	Loader {
		id: leftEdge

		readonly property string gaugeType: leftGaugeTypes.length === 1 ? leftGaugeTypes[0] : ''

		onGaugeTypeChanged: {
			console.log("leftEdge: gaugeType: ", gaugeType)
			leftEdge.setSource(gaugeType, {"gaugeAlignmentY": Qt.AlignVCenter})}
		anchors {
			top: parent.top
			topMargin: Theme.geometry.briefPage.edgeGauge.topMargin
			left: parent.left
			leftMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			right: mainGauge.left
		}
		active: leftGaugeTypes.length === 1
		opacity: root.sideOpacity
	}
	Loader {
		id: leftUpper

		readonly property string gaugeType: leftGaugeTypes.length === 2 ? leftGaugeTypes[0] : ''

		onGaugeTypeChanged: leftUpper.setSource(gaugeType, {"gaugeAlignmentY": Qt.AlignTop})
		anchors {
			top: parent.top
			topMargin: Theme.geometry.briefPage.edgeGauge.topMargin
			left: parent.left
			leftMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			right: mainGauge.left
		}
		active: leftGaugeTypes.length === 2
		opacity: root.sideOpacity
	}
	Loader {
		id: leftLower

		readonly property string gaugeType: leftGaugeTypes.length === 2 ? leftGaugeTypes[1] : ''

		onGaugeTypeChanged: leftLower.setSource(gaugeType, {"gaugeAlignmentY": Qt.AlignBottom})
		anchors {
			top: leftUpper.bottom
			topMargin: Theme.geometry.briefPage.lowerGauge.topMargin
			left: parent.left
			leftMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			right: mainGauge.left
		}
		active: leftGaugeTypes.length === 2
		opacity: root.sideOpacity
	}

	/*
	Loader {
		id: rightEdge
		anchors {
			top: parent.top
			right: parent.right
			rightMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			left: mainGauge.right
		}
		height: parent.height
		opacity: root.sideOpacity
		active: rightGaugeTypes.length === 1
		source: {
			switch (rightGaugeTypes[0]) {
			case 'load': return 'LoadGauge.qml'
			}
			return ''
		}
	}
	*/

	Loader {
		id: rightUpper

		readonly property string gaugeType: rightGaugeTypes.length === 2 ? rightGaugeTypes[0] : ''

		onGaugeTypeChanged: setSource(gaugeType, {"gaugeAlignmentY": Qt.AlignTop})
		anchors {
			top: parent.top
			topMargin: Theme.geometry.briefPage.edgeGauge.topMargin
			right: parent.right
			rightMargin: Theme.geometry.briefPage.edgeGauge.horizontalMargin
			left: mainGauge.right
		}
		opacity: root.sideOpacity
		active: rightGaugeTypes.length === 2
	}
	Loader {
		id: rightLower

		readonly property string gaugeType: rightGaugeTypes.length === 2 ? rightGaugeTypes[1] : ''

		onGaugeTypeChanged: setSource(gaugeType, {"gaugeAlignmentY": Qt.AlignBottom})
		anchors {
			top: rightUpper.bottom
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

		// Use -1 to represent the Battery, as it is not one of the tank type enum values.
		property int batteryType: -1

		property ListModel model: ListModel {}

		Connections {
			target: battery
			function onIconChanged() {
				if (gaugeData.model.count > 0) {
					gaugeData.model.setProperty(0, "icon", battery.icon)
				}
			}
		}

		Instantiator {
			model: [gaugeData.batteryType].concat(tanks.tankTypes)

			delegate: QtObject {
				readonly property int tankType: modelData
				readonly property bool isBattery: modelData === gaugeData.batteryType
				readonly property var tankModel: isBattery ? 1 : tanks.tankModel(tankType)
				readonly property var tankModelCount: tankModel.count
				property bool deleted

				readonly property string tankName: isBattery
						  //% "Battery"
						? qsTrId("brief_battery")
						: Gauges.tankProperties(tankType).name
				readonly property real tankLevel: isBattery
						? Math.round(battery ? battery.stateOfCharge : 0)
						: (tankModel.totalCapacity === 0
						   ? 0
						   : (tankModel.totalRemaining / tankModel.totalCapacity) * 100)

				function orderedGaugeIndex() {
					if (tankModel.count === 0) {
						return -1
					}
					if (isBattery) {
						return 0
					}
					let gaugeIndex = 1  // Skip over Battery gauge at index 0
					for (let i = 0; i < tanks.tankTypes.length; ++i) {
						if (tanks.tankTypes[i] === tankType) {
							break
						} else {
							if (tanks.tankModel(tanks.tankTypes[i]).count > 0) {
								gaugeIndex++
							}
						}
					}
					return gaugeIndex
				}

				function insertedGaugeIndex() {
					for (let i = 0; i < gaugeData.model.count; ++i) {
						if (gaugeData.model.get(i).tankType === tankType) {
							return i
						}
					}
					return -1
				}

				function updateGaugeModel() {
					if (deleted) {
						return
					}
					const orderedIndex = orderedGaugeIndex()
					const insertedIndex = insertedGaugeIndex()

					if (orderedIndex < 0) {
						// No tanks are present for this tank type anymore, so remove it from the model
						if (insertedIndex >= 0) {
							gaugeData.model.remove(insertedIndex)
						}
						return
					}

					if (insertedIndex >= 0) {
						if (orderedIndex !== insertedIndex) {
							// Gauge is already in list, but at wrong index
							gaugeData.model.move(insertedIndex, orderedIndex, 1)
						}
						gaugeData.model.set(orderedIndex, { name: tankName, value: tankLevel })
					} else {
						let gaugeProperties
						if (isBattery) {
							gaugeProperties = {
								icon: "/images/battery.svg",
								valueType: Gauges.FallingPercentage,
								name: tankName,
								tankType: tankType,
								value: tankLevel
							}
						} else {
							gaugeProperties = Object.assign({}, Gauges.tankProperties(tankType),
									{ name: tankName, tankType: tankType, value: tankLevel })
						}
						gaugeData.model.insert(Math.min(orderedIndex, gaugeData.model.count), gaugeProperties)
					}
				}

				// If tank data changes, update the model at the end of the event loop to avoid
				// excess updates if multiple values change simultaneously for the same tank.
				onTankLevelChanged: Qt.callLater(updateGaugeModel)
				onTankNameChanged: Qt.callLater(updateGaugeModel)
				onTankModelCountChanged: Qt.callLater(updateGaugeModel)

				Component.onDestruction: deleted = true
			}
		}
	}

	state: PageManager.sidePanelActive ? 'panelOpen' : ''
	states: State {
		name: 'panelOpen'
		PropertyChanges {
			target: sidePanel
			x: root.width - sidePanel.width - Theme.geometry.page.grid.horizontalMargin
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
