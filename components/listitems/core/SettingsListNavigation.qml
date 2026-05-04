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

	topPadding: topInset + Theme.geometry_settingsListNavigation_verticalPadding
	bottomPadding: bottomInset + Theme.geometry_settingsListNavigation_verticalPadding
	leftPadding: leftInset + horizontalContentPadding

	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: labelLayout.implicitHeight

		CP.ColorImage {
			id: mainIcon

			anchors {
				verticalCenter: parent.verticalCenter
				left: parent.left
			}
			source: root.iconSource
			color: Theme.color_font_primary
		}

		ThreeLabelLayout {
			id: labelLayout

			anchors {
				verticalCenter: parent.verticalCenter
				left: root.iconSource.length > 0 ? mainIcon.right : parent.left
				leftMargin: root.iconSource.length > 0 ? root.horizontalContentPadding : 0
				right: arrowIcon.left
				rightMargin: Theme.geometry_listItem_arrow_leftMargin
			}
			primaryText: root.text
			primaryLabel.font: root.font
			primaryLabel.textFormat: root.textFormat
			secondaryText: root.secondaryText
			secondaryLabel.color: root.secondaryTextColor
			captionText: root.caption
			stretchSecondaryText: true
		}

		ForwardIcon {
			id: arrowIcon

			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			visible: root.interactive
		}
	}

	onClicked: {
		Global.pageManager.pushPage(root.pageSource, root.pageProperties)
	}
}
