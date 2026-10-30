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
	property color statusColor: Theme.color_critical

	// If quantityValue or quantityText is set, the QuantityLabel is displayed.
	property real quantityValue: NaN
	property int quantityUnit: -1 // If -1, will use the IOChannel unit
	property string quantityText // If set, this overrides the displayed quantityValue
	property color quantityColor: Theme.color_font_primary

	spacing: Theme.geometry_iochannel_label_margin

	Label {
		id: nameLabel

		Layout.fillWidth: true
		Layout.bottomMargin: Theme.geometry_iochannel_label_margin
		text: root.ioChannel.formattedName
		elide: Text.ElideMiddle // don't elide right, as it may obscure a trailing channel id
		font.pixelSize: Theme.font_switches_header_title
	}

	IOChannelQuantityLabel {
		Layout.bottomMargin: Theme.geometry_iochannel_label_margin
		Layout.preferredHeight: nameLabel.height
		ioChannel: root.ioChannel
		value: root.quantityValue
		valueColor: root.quantityColor
		valueText: root.quantityText || quantityInfo.number
		unit: root.quantityUnit >= 0 ? root.quantityUnit : Services.settings.toPreferredUnit(ioChannel.unitType)
		unitColor: root.quantityColor
		font.pixelSize: Theme.font_switches_header_secondary
		visible: !root.statusVisible && (root.quantityText.length > 0 || !isNaN(root.quantityValue))
	}

	Rectangle {
		id: statusRect

		Layout.bottomMargin: Theme.geometry_iochannel_label_margin
		Layout.maximumWidth: parent.width / 2
		Layout.minimumWidth: statusLabel.implicitWidth
		Layout.alignment: Qt.AlignRight | Qt.AlignTop
		Layout.preferredHeight: statusLabel.height
		color: statusLabel.color === Theme.color_success ? Theme.color_darkSuccess
				: statusLabel.color === Theme.color_warning ? Theme.color_darkWarning
				: statusLabel.color === Theme.color_critical ? Theme.color_darkCritical
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
			font.pixelSize: Theme.font_switches_header_status
			color: root.statusColor
		}
	}
}
