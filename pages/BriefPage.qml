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
			dataModel.setProperty(1, 'value', value)
		}
	}

	ListModel {
		id: dataModel

		ListElement { value: 10; text: 'Fuel'; icon: '/images/tank.svg'; valueType: CircularMultiGauge.FallingPercentage }
		ListElement { value: 60; text: 'Battery'; icon: '/images/battery.svg'; valueType: CircularMultiGauge.FallingPercentage }
		ListElement { value: 80; text: 'Fresh water'; icon: '/images/freshWater.svg'; valueType: CircularMultiGauge.FallingPercentage }
		ListElement { value: 20; text: 'Black water'; icon: '/images/blackWater.svg'; valueType: CircularMultiGauge.FallingPercentage }
	}
}
