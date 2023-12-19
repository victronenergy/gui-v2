/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Utils

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

	Label {
		id: gsmStatusText

		anchors {
			top: parent.top
			topMargin: Theme.geometry_settings_gsmModem_icon_statusText_topMargin
		}
		text: (roaming.valid && roaming.value) ? "R" : Utils.simplifiedNetworkType(networkType.value)
		color: Theme.color_settings_gsmModem_signalStrength_active
		verticalAlignment: Text.AlignTop
		visible: !simLockedIcon.visible && ((roaming.valid && roaming.value) || (connected.valid && connected.value))
		font {
			pixelSize: Theme.font_size_gsm_icon_caption
		}
	}

	Row {
		id: gsmRow

		spacing: Theme.geometry_settings_gsmModem_signalStrengthBars_spacing
		visible: !simLockedIcon.visible

		anchors {
			top: parent.top
			topMargin: Theme.geometry_settings_gsmModem_signalStrengthBars_topMargin
			bottom: parent.bottom
		}

		Repeater {
			id: signalRepeater

			model: 4

			Rectangle {
				y: parent.height - height
				height: (index + 1) * Theme.geometry_settings_gsmModem_signalStrengthBars_bar_incremental_height
				width: Theme.geometry_settings_gsmModem_signalStrengthBars_bar_width
				radius: width / 2
				color: getScaledStrength(strength.value) >= (index + 1) ?
						   Theme.color_settings_gsmModem_signalStrength_active : Theme.color_settings_gsmModem_signalStrength_inactive
			}
		}
	}

	CP.IconImage {
		id: simLockedIcon

		anchors.verticalCenter: parent.verticalCenter
		color: Theme.color_settings_gsmModem_signalStrength_active
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
