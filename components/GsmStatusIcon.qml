/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import "/components/Utils.js" as Utils

Row { // TODO: update this when we get a design
	id: root

	property bool showNetworkType: activeNetworkConnection.value === VenusOS.NetworkConnection_GSM
	property bool showRoamingIcon: true
	property string color: "#FFFFFF"
	property bool valid: strength.valid

	function getScaledStrength(strength) {
		if (strength <= 3) {
			return 0
		}
		if (strength <= 9) {
			return 1
		}
		if (strength <= 14) {
			return 2
		}
		if (strength <= 19) {
			return 3
		}
		if (strength <= 31) {
			return 4
		}
		return 0
	}

	height: 16
	visible: simStatus.valid

	Row {
		spacing: 4
		height: parent.height
		visible: showNetworkType || showRoamingIcon

		Text {
			id: netType

			height: 16
			text: Utils.simplifiedNetworkType(networkType.value)
			color: root.color
			verticalAlignment: Text.AlignVCenter
			visible: showNetworkType && (connected.valid && connected.value)
			font {
				bold: true
				pixelSize: 10
			}
		}

		Text {
			id: roamingIndicator

			height: 16
			text: "R"
			color: root.color
			verticalAlignment: Text.AlignVCenter
			visible: showRoamingIcon && roaming.valid ? roaming.value : false
			font {
				bold: true
				pixelSize: 10
			}
		}
	}

	Row {
		id: gsmRow

		spacing: 1
		visible: !simLockedIcon.visible

		anchors {
			top: parent.top; topMargin: 2
			bottom: parent.bottom; bottomMargin: 0
		}

		Repeater {
			id: signalRepeater

			model: 4

			Rectangle {
				y: parent.height - height
				height: (index + 1) * parent.height / signalRepeater.model
				width: 3
				color: root.color
				opacity: getScaledStrength(strength.value) >= (index + 1) ? 1 : 0.2
			}
		}
	}

	CP.IconImage {
		id: simLockedIcon

		anchors.centerIn: parent
		width: Theme.geometry.modalWarningDialog.alarmIcon.width
		height: Theme.geometry.modalWarningDialog.alarmIcon.width
		source: "qrc:/images/icon-statusbar-sim-locked.svg"
		visible: [11, 16].indexOf(simStatus.value) > -1
	}

	DataPoint {
		id: strength

		source: "com.victronenergy.modem/SignalStrength"
	}

	DataPoint {
		id: networkType

		source: "com.victronenergy.modem/NetworkType"
	}

	DataPoint {
		id: simStatus

		source: "com.victronenergy.modem/SimStatus"
	}

	DataPoint {
		id: roaming

		source: "com.victronenergy.modem/Roaming"
	}

	DataPoint {
		id: connected

		source: "com.victronenergy.modem/Connected"
	}

	DataPoint {
		id: activeNetworkConnection

		source: "com.victronenergy.settings/Settings/System/ActiveNetworkConnection"
	}

}
