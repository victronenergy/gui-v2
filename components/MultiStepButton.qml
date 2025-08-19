/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import QtQuick.Templates as T
import Victron.VenusOS

FocusScope {
	id: root

	property int fontPixelSize: Theme.font_size_body3
	property alias model: baseListView.model //buttonRepeater.model
	property int currentIndex
	property bool checked

	signal clicked(index: int)
	signal toggled()

	implicitWidth: parent.width
	implicitHeight: Theme.geometry_segmentedButtonRow_height

	Keys.onSpacePressed: {
		if (buttonRepeater.count > 0) {
			if (currentIndex < 0) {
				currentIndex = 0
			}
			buttonRepeater.itemAt(currentIndex).focus = true
		}
	}
	Keys.enabled: Global.keyNavigationEnabled
	// When the row is focused but none of its individual items are focused/highlighted, then
	// highlight the row as a whole.
	KeyNavigationHighlight.active: root.currentIndex < 0 && root.activeFocus
	KeyNavigationHighlight.fill: baseListView

	BaseListView {
		id: baseListView

		property int totalDelegateWidth: width - headerItem.width
		property int maxIndexCount: model.length - 1

		height: parent.height
		width: parent.width
		orientation: ListView.Horizontal

		delegate: BaseListItem {
			height: root.height
			width: baseListView.totalDelegateWidth / (baseListView.maxIndexCount + 1)

			// background border color
			Rectangle {
				anchors.fill: parent
				topRightRadius: index === baseListView.maxIndexCount ? Theme.geometry_button_radius : 0
				bottomRightRadius: index === baseListView.maxIndexCount ? Theme.geometry_button_radius : 0
				color: root.enabled ? root.checked ? Theme.color_ok : Theme.color_button_off_background : Theme.color_gray4
			}

			// background color
			Rectangle {
				anchors.fill: parent
				anchors.topMargin: Theme.geometry_button_border_width
				anchors.bottomMargin: Theme.geometry_button_border_width
				anchors.rightMargin: index === baseListView.maxIndexCount ? Theme.geometry_button_border_width : 0

				topRightRadius: index === baseListView.maxIndexCount ? Theme.geometry_button_radius - Theme.geometry_button_border_width : 0
				bottomRightRadius: index === baseListView.maxIndexCount ? Theme.geometry_button_radius - Theme.geometry_button_border_width : 0
				color: root.enabled ? index === root.currentIndex ? root.checked ? Theme.color_ok : Theme.color_button_off_background : Theme.color_darkOk : Theme.color_background_disabled
			}

			Label {
				anchors.fill: parent
				width: 50

				text: modelData.text
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				font.pixelSize: Theme.font_size_body1
				color: root.enabled ? index === root.currentIndex ? Theme.color_button_down_text : Theme.color_font_primary : Theme.color_gray6
			}

			MouseArea {
				anchors.fill: parent
				onPressed: {
					if (root.checked) {
						root.clicked(index)
					}
				}
			}

			activeFocusOnTab : true
			Keys.enabled: Global.keyNavigationEnabled
			Keys.onSpacePressed: root.clicked(index)
			KeyNavigationHighlight.active: activeFocus
		}

		header: Rectangle {
			width: Math.ceil(labelTextMetrics.tightBoundingRect.x + labelTextMetrics.tightBoundingRect.width)
				   + Theme.geometry_dimmingSlider_separator_width + (Theme.geometry_dimmingSlider_text_padding * 2)
			height: parent.height
			topLeftRadius: Theme.geometry_slider_groove_radius
			bottomLeftRadius: Theme.geometry_slider_groove_radius
			color: root.enabled ? root.checked ? Theme.color_ok : Theme.color_button_off_background : Theme.color_gray4

			// background color
			Rectangle {
				anchors.fill: parent
				anchors.topMargin: Theme.geometry_button_border_width
				anchors.bottomMargin: Theme.geometry_button_border_width
				anchors.leftMargin: Theme.geometry_button_border_width

				topLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
				bottomLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
				color: root.enabled ? Theme.color_darkOk : Theme.color_background_disabled
			}

			Label {
				id: stateLabel
				anchors.fill: parent

				text: root.checked ? CommonWords.on : CommonWords.off
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				font.pixelSize: Theme.font_size_body1
				color: root.enabled ? Theme.color_font_primary : Theme.color_gray6
			}

			Rectangle {
				anchors.right: stateLabel.right
				anchors.verticalCenter: parent.verticalCenter
				width: Theme.geometry_dimmingSlider_separator_width
				height: parent.height - (Theme.geometry_dimmingSlider_decorator_vertical_padding * 2)
				radius: Theme.geometry_dimmingSlider_separator_width / 2
				visible: currentIndex > 0
				color: root.enabled ? Theme.color_multistepbutton_separator : Theme.color_background_disabled
			}

			MouseArea {
				anchors.fill: parent
				onPressed: root.toggled()
			}

			TextMetrics {
				id: labelTextMetrics
				font.pixelSize: Theme.font_size_body1
				text: (CommonWords.on.length > CommonWords.off.length) ? CommonWords.on : CommonWords.off
			}

			activeFocusOnTab : true
			Keys.enabled: Global.keyNavigationEnabled
			Keys.onSpacePressed: root.toggled()
			KeyNavigationHighlight.active: activeFocus
		}
	}
}
