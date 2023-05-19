/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import "/components/Utils.js" as Utils

Row {
	id: root

	readonly property bool valid: strength.valid

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

	visible: simStatus.valid

	Text {
		id: gsmStatusText

		anchors {
			top: parent.top
			topMargin: Theme.geometry.settingspage.gsmModem.icon.statusText.topMargin
		}
		text: (roaming.valid && roaming.value) ? "R" : Utils.simplifiedNetworkType(networkType.value)
		color: Theme.color.settings.gsmmodem.signalstrength.active
		verticalAlignment: Text.AlignTop
		visible: !simLockedIcon.visible && ((roaming.valid && roaming.value) || (connected.valid && connected.value))
		font {
			pixelSize: Theme.font.size.gsm.icon.caption
		}
	}

	Row {
		id: gsmRow

		spacing: Theme.geometry.settingspage.gsmModem.signalStrengthBars.spacing
		visible: !simLockedIcon.visible

		anchors {
			top: parent.top
			topMargin: Theme.geometry.settingspage.gsmModem.signalStrengthBars.topMargin
			bottom: parent.bottom
		}

		Repeater {
			id: signalRepeater

			model: 4

			Rectangle {
				y: parent.height - height
				height: (index + 1) * Theme.geometry.settingspage.gsmModem.signalStrengthBars.bar.incremental.height
				width: Theme.geometry.settingspage.gsmModem.signalStrengthBars.bar.width
				radius: width / 2
				color: getScaledStrength(strength.value) >= (index + 1) ?
						   Theme.color.settings.gsmmodem.signalstrength.active : Theme.color.settings.gsmmodem.signalstrength.inactive
			}
		}
	}

	CP.IconImage {
		id: simLockedIcon

		anchors.verticalCenter: parent.verticalCenter
		color: Theme.color.settings.gsmmodem.signalstrength.active
		source: "qrc:/images/icon_simlocked_32.svg"
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
}
