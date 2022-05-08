/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "/components/Gauges.js" as Gauges

Page {
	id: root

	property real sideOpacity: 1

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
		opacity: root.sideOpacity

		sourceComponent: SideGauge {
			gaugeAlignmentX: Qt.AlignLeft
			gaugeAlignmentY: leftLower.active ? Qt.AlignTop : Qt.AlignVCenter
			arcX: leftLower.active ? undefined : 10
			direction: PathArc.Clockwise
			startAngle: leftLower.active ? 270 : (270 - Theme.geometry.briefPage.largeEdgeGauge.maxAngle / 2)
			animationEnabled: root.isCurrentPage
			source: {
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
					/ Utils.maximumValue("briefPage.inputsPower") * 100
			textValue: isNaN(Global.acInputs.power) && isNaN(Global.dcInputs.power)
					? NaN
					: (Global.acInputs.power || 0) + (Global.dcInputs.power || 0)
			onTextValueChanged: Utils.updateMaximumValue("briefPage.inputsPower", textValue)
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
		opacity: root.sideOpacity

		sourceComponent: SolarYieldGauge {
			gaugeAlignmentY: Qt.AlignBottom
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
		opacity: root.sideOpacity
		active: !isNaN(Global.system.loads.acPower) || rightLower.active
		sourceComponent: SideGauge {
			gaugeAlignmentY: rightLower.active ? Qt.AlignTop : Qt.AlignVCenter
			animationEnabled: root.isCurrentPage
			source: rightLower.active ? "qrc:/images/acloads.svg" : "qrc:/images/consumption.svg"
			value: (Global.system.loads.acPower || 0) / Utils.maximumValue("system.loads.acPower") * 100
			textValue: Global.system.loads.acPower
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
		opacity: root.sideOpacity
		active: !isNaN(Global.system.loads.dcPower)
		sourceComponent: SideGauge {
			gaugeAlignmentY: Qt.AlignBottom
			animationEnabled: root.isCurrentPage
			source: "qrc:/images/dcloads.svg"
			value: (Global.system.loads.dcPower || 0) / Utils.maximumValue("system.loads.dcPower") * 100
			textValue: Global.system.loads.dcPower
		}
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
