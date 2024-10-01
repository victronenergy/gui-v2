/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	property int phaseCount
	readonly property alias extraContentLoader: extraContentLoader

	quantityLabel.visible: !!quantityLabel.dataObject
	preferredSize: phaseCount > 1 ? VenusOS.OverviewWidget_PreferredSize_PreferLarge : VenusOS.OverviewWidget_PreferredSize_Any

	extraContentChildren: Loader {
		id: extraContentLoader

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin + root.rightPadding
			bottom: parent.bottom
			bottomMargin: root.verticalMargin
		}
		active: root.phaseCount > 1
		states: [
			State {
				name: "extrasmall"
				when: root.size === VenusOS.OverviewWidget_Size_XS
				PropertyChanges {
					target: root.quantityLabel
					visible: !!quantityLabel.dataObject && extraContentLoader.status !== Loader.Ready // hide the total power
					font.pixelSize: Theme.font_overviewPage_widget_quantityLabel_minimumSize
				}
				PropertyChanges {
					target: extraContentLoader
					anchors.bottomMargin: root.verticalMargin / 3
				}
			},
			State {
				name: "small"
				when: root.size === VenusOS.OverviewWidget_Size_S
				PropertyChanges {
					target: root.quantityLabel
					font.pixelSize: Theme.font_overviewPage_widget_quantityLabel_smallSizeWithExtraContent
				}
				PropertyChanges {
					target: extraContentLoader
					anchors.bottomMargin: root.verticalMargin / 3
				}
			},
			State {
				name: "medium"
				when: root.size === VenusOS.OverviewWidget_Size_M
				PropertyChanges {
					target: root.quantityLabel
					font.pixelSize: extraContentLoader.status === Loader.Ready
							   ? Theme.font_overviewPage_widget_quantityLabel_minimumSize
							   : Theme.font_overviewPage_widget_quantityLabel_maximumSize
				}
			},
			State {
				name: "large"
				when: root.size === VenusOS.OverviewWidget_Size_L || root.size === VenusOS.OverviewWidget_Size_XL
				PropertyChanges {
					target: root.quantityLabel
					font.pixelSize: Theme.font_overviewPage_widget_quantityLabel_maximumSize
				}
			}
		]
	}

}
