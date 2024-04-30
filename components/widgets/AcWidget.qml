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
	preferLargeSize: phaseCount > 1

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
				name: "small"
				when: root.size === VenusOS.OverviewWidget_Size_XS || root.size === VenusOS.OverviewWidget_Size_S
				PropertyChanges {
					target: root.quantityLabel
					visible: !!quantityLabel.dataObject && extraContentLoader.status !== Loader.Ready
					font.pixelSize: Theme.font_overviewPage_widget_quantityLabel_minimumSize
				}
				PropertyChanges {
					target: root
					secondaryTitle: extraContentLoader.status === Loader.Ready
									? "(%1)".arg(Units.defaultUnitString(Global.systemSettings.electricalQuantity))
									: ""
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
				name: "medium-or-larger"
				when: root.size === VenusOS.OverviewWidget_Size_L || root.size === VenusOS.OverviewWidget_Size_XL
				PropertyChanges {
					target: root.quantityLabel
					font.pixelSize: Theme.font_overviewPage_widget_quantityLabel_maximumSize
				}
			}
		]
	}

}
