/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListNavigation {
	id: root

	property string pageSource
	property string iconSource
	property var pageProperties: ({"title": Qt.binding(function() { return root.text }) })

	// TODO these padding/margin customisations are temporary, to align the text with the existing
	// UI. These should be removed once the Control migration (#2789) is completed.
	topPadding: Theme.geometry_settingsListNavigation_verticalPadding
	bottomPadding: Theme.geometry_settingsListNavigation_verticalPadding
	leftPadding: horizontalContentPadding + (iconSource.length ? icon.width + horizontalContentPadding : 0)
	captionTopMargin: 0

	onClicked: {
		Global.pageManager.pushPage(root.pageSource, root.pageProperties)
	}

	CP.ColorImage {
		id: icon

		anchors {
			verticalCenter: parent.verticalCenter
			left: parent.left
			leftMargin: root.horizontalContentPadding
		}
		color: Theme.color_font_primary
		source: root.iconSource
	}
}
