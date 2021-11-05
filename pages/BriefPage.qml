/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS

Page {
	id: root

	CircularMultiGauge {
		id: gauge

		x: sidePanel.x/2 - width/2
		anchors {
			top: parent.top
			topMargin: 56
		}
		width: 315
		height: 320
		model: dataModel
	}

	Button {
		id: button

		anchors {
			top: parent.top
			topMargin: 15
			right: parent.right
			rightMargin: 27
		}

		topSpacing: 0
		bottomSpacing: 0
		horizontalSpacing: 0

		width: icon.implicitWidth
		height: icon.implicitHeight
		icon.source: sidePanel.state === '' ? "qrc:/images/panel-toggle.svg" : "qrc:/images/panel-toggled.svg"
		color: Theme.primaryFontColor

		onClicked: {
			sidePanel.state = (sidePanel.state == '') ? 'hidden' : ''
		}
	}

	BriefMonitorPanel {
		id: sidePanel

		anchors.top: button.bottom
		x: root.width
		opacity: 0
		width: 240
		height: 367
		states: State {
			name: 'hidden'
			PropertyChanges {
				target: sidePanel
				x: root.width - sidePanel.width - Theme.horizontalPageMargin
				opacity: 1
			}
		}

		transitions: Transition {
			NumberAnimation {
				properties: 'x,opacity'; duration: 400
				easing.type: Easing.InQuad
			}
		}
	}

	property VeQuickItem batterySoC: VeQuickItem { uid: veSystem.childUId("/Dc/Battery/Soc") }

	Connections {
		target: batterySoC
		function onValueChanged(veItem, value) {
			console.log('batterySoC:', batterySoC.value)
			dataModel.setProperty(1, 'value', value)
		}
	}

	property var tanks: []

	function getTanks() {
		const childIds = veDBus.childIds

		let tanksIds = []
		for (let i = 0; i < childIds.length; ++i) {
			let id = childIds[i]
			if (id.startsWith('com.victronenergy.tank.')) {
				tanksIds.push(id)
			}
		}
		tanks = tanksIds
	}

	Connections {
		target: veDBus
		function onChildIdsChanged() { getTanks() }
		Component.onCompleted: getTanks()
	}

	Instantiator {
		model: tanks
		delegate: QtObject {
			id: tank
			property string uid: modelData
			property int type: -1
			property int level: -1
			property var modelIndex: {
				if (type === 0) { // Fuel
					return 0
				} else if (type === 1) { // Fresh
					return 2
				} else if (type === 5) { // Black
					return 3
				}
				return undefined
			}
			property bool valid: type >= 0 && level >= 0 && modelIndex !== undefined
			onValidChanged: console.log('tank - type:', type, 'level:', level)

			property VeQuickItem _tankType: VeQuickItem {
				uid: "dbus/" + tank.uid + "/FluidType"
				onValueChanged: tank.type = value || -1
			}
			property VeQuickItem _tankLevel: VeQuickItem {
				uid: "dbus/" + tank.uid + "/Level"
				onValueChanged: tank.level = value || -1
			}

			property var _binding: Binding {
				when: valid
				target: dataModel.get(modelIndex)
				property: 'value'
				value: tank.level
			}
		}
	}

	property var fuelLevel
	property var freshLevel
	property var blackLevel

	ListModel {
		id: dataModel

		ListElement { value: 10; text: 'gaugeFuelText'; icon: '/images/tank.svg'; valueType: CircularMultiGauge.FallingPercentage }
		ListElement { value: 60; text: 'gaugeBatteryText'; icon: '/images/battery.svg'; valueType: CircularMultiGauge.FallingPercentage }
		ListElement { value: 80; text: 'gaugeFreshWaterText'; icon: '/images/freshWater.svg'; valueType: CircularMultiGauge.FallingPercentage }
		ListElement { value: 20; text: 'gaugeBlackWaterText'; icon: '/images/blackWater.svg'; valueType: CircularMultiGauge.FallingPercentage }
	}

	property var _gaugeStrings: [
		//% "Fuel"
		QT_TRID_NOOP('gaugeFuelText'),
		//% "Battery"
		QT_TRID_NOOP('gaugeBatteryText'),
		//% "Fresh water"
		QT_TRID_NOOP('gaugeFreshWaterText'),
		//% "Black water"
		QT_TRID_NOOP('gaugeBlackWaterText')
	]
}
