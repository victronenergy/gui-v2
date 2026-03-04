/*
** Copyside (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A widget in the Brief side panel.

	In landscape orientation, the layout is:

	| Icon & Title             |
	| Quantity label |  Graph  |
	|             Footer       |

	In portrait orientation, the layout is:

	| Icon & Title |   Graph   | Quantity label |
	|             Footer       |
*/
Rectangle {
	id: root

	required property string title
	property alias icon: header.icon
	property alias quantityLabel: quantityLabel
	property alias graph: graphLoader.sourceComponent
	property alias footer: footerLoader.sourceComponent
	property bool loadersActive

	// True if the graph should be stretched to fill as much space as possible.
	property bool stretchGraph: true

	implicitWidth: parent?.width ?? Theme.geometry_briefPage_sidePanel_width
	implicitHeight: contentItem.height + (2 * Theme.geometry_sidePanel_sideWidget_verticalMargin)

	// In portrait layout, show a background and shrink the content area to fit within that
	// background, with some margin between the content and the background.
	color: Theme.screenSize === Theme.Portrait ? Theme.color_background_secondary : "transparent"
	radius: Theme.geometry_button_radius

	Item {
		id: contentItem

		anchors.centerIn: parent
		width: parent.width - (2 * Theme.geometry_sidePanel_sideWidget_horizontalMargin)
		implicitHeight: footerLoader.y + footerLoader.height

		WidgetHeader {
			id: header

			anchors.left: parent.left
			width: Theme.screenSize === Theme.Portrait
				   ? root.stretchGraph
					 ? implicitWidth
					 : Math.min(implicitWidth, parent.width - quantityLabel.width - graphLoader.width - Theme.geometry_sidePanel_sideWidget_spacing)
				   : parent.width
			height: Theme.screenSize === Theme.Portrait ? quantityLabel.height : implicitHeight
			rightPadding: Theme.screenSize === Theme.Portrait ? Theme.geometry_sidePanel_sideWidget_spacing : 0
			text: root.title
		}

		ElectricalQuantityLabel {
			id: quantityLabel

			anchors {
				top: Theme.screenSize === Theme.Portrait ? undefined : header.bottom
				left: Theme.screenSize === Theme.Portrait ? undefined : parent.left
				right: Theme.screenSize === Theme.Portrait ? parent.right : undefined
			}
			rightPadding: Theme.screenSize === Theme.Portrait ? 0 : Theme.geometry_sidePanel_sideWidget_spacing
			font.pixelSize: Theme.font_briefPage_sidePanel_quantityLabel_size
			alignment: Theme.screenSize === Theme.Portrait ? Qt.AlignRight : Qt.AlignLeft
		}

		Loader {
			id: graphLoader

			anchors {
				left: root.stretchGraph ? (Theme.screenSize === Theme.Portrait ? header.right : quantityLabel.right) : undefined
				top: Theme.screenSize === Theme.Portrait ? quantityLabel.top : header.bottom
				bottom: Theme.screenSize === Theme.Portrait ? quantityLabel.bottom : footerLoader.top
				bottomMargin: Theme.screenSize === Theme.Portrait ? 0 : Theme.geometry_sidePanel_sideWidget_bottomMargin
				right: Theme.screenSize === Theme.Portrait ? quantityLabel.left : parent.right
				rightMargin: Theme.screenSize === Theme.Portrait ? Theme.geometry_sidePanel_sideWidget_spacing : 0
			}
			active: root.loadersActive
			sourceComponent: root.graph
		}

		Loader {
			id: footerLoader
			anchors {
				top: quantityLabel.bottom
				topMargin: status === Loader.Null ? 0 : Theme.geometry_sidePanel_quantityLabel_bottomMargin
			}
			width: parent.width
			active: root.loadersActive
		}
	}
}
