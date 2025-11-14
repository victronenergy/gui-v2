/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Column {
	id: root

	property alias titleText: title.text
	property alias primaryText: primaryLabel.text
	property alias secondaryText: secondaryLabel.text
	property alias imageSource: logo.source
	property alias imageColor: logo.color

	spacing: Theme.geometry_emptyPageItem_column_spacing

	Label {
		id: title
		width: parent.width
		height: implicitHeight + Theme.geometry_emptyPageItem_title_bottomMargin
		wrapMode: Text.Wrap
		horizontalAlignment: Text.AlignHCenter
		font.pixelSize: Theme.font_size_body2
	}

	CP.ColorImage {
		id: logo
		anchors.horizontalCenter: parent.horizontalCenter
	}

	Label {
		id: primaryLabel
		topPadding: Theme.geometry_emptyPageItem_primaryLabel_topPadding
		width: parent.width
		wrapMode: Text.Wrap
		horizontalAlignment: Text.AlignHCenter
		font.pixelSize: Theme.font_size_body2
	}

	Label {
		id: secondaryLabel
		width: parent.width
		wrapMode: Text.Wrap
		horizontalAlignment: Text.AlignHCenter
		font.pixelSize: Theme.font_size_body1
		color: Theme.color_font_secondary
	}
}
