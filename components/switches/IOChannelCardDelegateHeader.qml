/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

RowLayout {
	id: root

	required property IOChannel ioChannel
	required property string statusText
	property bool statusVisible
	property color statusColor: Theme.color_red

	// If quantityValue or quantityText is set, the QuantityLabel is displayed.
	property real quantityValue: NaN
	property int quantityUnit: -1 // If -1, will use the IOChannel unit
	property string quantityText // If set, this overrides the displayed quantityValue
	property color quantityColor: Theme.color_font_primary

	spacing: Theme.geometry_iochannel_label_margin

	Label {
		Layout.fillWidth: true
		Layout.bottomMargin: Theme.geometry_iochannel_label_margin
		text: root.ioChannel.formattedName
		elide: Text.ElideMiddle // don't elide right, as it may obscure a trailing channel id
	}

	IOChannelQuantityLabel {
		Layout.bottomMargin: Theme.geometry_iochannel_label_margin
		ioChannel: root.ioChannel
		value: root.quantityValue
		valueColor: root.quantityColor
		valueText: root.quantityText || quantityInfo.number
		unit: root.quantityUnit >= 0 ? root.quantityUnit : Global.systemSettings.toPreferredUnit(ioChannel.unitType)
		unitColor: root.quantityColor
		visible: !root.statusVisible && (root.quantityText.length > 0 || !isNaN(root.quantityValue))
	}

	Rectangle {
		id: statusRect

		Layout.bottomMargin: Theme.geometry_iochannel_statusBackground_bottomPadding
		Layout.maximumWidth: parent.width / 2
		Layout.minimumWidth: statusLabel.implicitWidth
		Layout.alignment: Qt.AlignRight
		height: statusLabel.height
		color: statusLabel.color === Theme.color_green ? Theme.color_darkGreen
				: statusLabel.color === Theme.color_orange ? Theme.color_darkOrange
				: statusLabel.color === Theme.color_red ? Theme.color_darkRed
				: Theme.color_switch_status_disabled
		radius: Theme.geometry_iochannel_status_radius
		visible: root.statusVisible

		Label {
			id: statusLabel

			anchors.centerIn: parent
			text: root.statusText
			width: parent.width
			topPadding: Theme.geometry_iochannel_status_verticalPadding
			bottomPadding: Theme.geometry_iochannel_status_verticalPadding
			leftPadding: Theme.geometry_iochannel_status_horizontalPadding
			rightPadding: Theme.geometry_iochannel_status_horizontalPadding
			horizontalAlignment: Text.AlignHCenter
			elide: Text.ElideRight
			font.pixelSize: Theme.font_size_tiny
			color: root.statusColor
		}
	}
}
