/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Shows an energy indicator to indicate energy flow in the Overview portrait layout.
*/
Item {
	id: root

	required property int animationMode

	implicitWidth: boltImage1.width
	implicitHeight: Theme.geometry_overviewPage_energyIndicator_height
	clip: true
	rotation: animationMode === VenusOS.WidgetConnector_AnimationMode_StartToEnd ? 180 : 0

	// Animate two copies of the same image continuously, to make it look like the same image is
	// being looped.
	Image {
		id: boltImage1
		x: parent.width/2 - width/2
		source: "qrc:/images/overview_lightning_bolts.svg"

		NumberAnimation on y {
			from: 0
			to: -boltImage1.height
			running: root.animationMode !== VenusOS.WidgetConnector_AnimationMode_NotAnimated
			duration: 2000
			loops: Animation.Infinite
		}
	}
	Image {
		id: boltImage2
		x: parent.width/2 - width/2
		y: height
		source: "qrc:/images/overview_lightning_bolts.svg"

		NumberAnimation on y {
			from: boltImage2.height
			to: 0
			running: root.animationMode !== VenusOS.WidgetConnector_AnimationMode_NotAnimated
			duration: 2000
			loops: Animation.Infinite
		}
	}

	Rectangle {
		anchors.fill: parent
		gradient: Gradient {
			GradientStop {
				position: Theme.geometry_viewGradient_position1
				color: Theme.color_viewGradient_color3
			}
			GradientStop {
				position: Theme.geometry_viewGradient_position2
				color: Theme.color_viewGradient_color1
			}
			GradientStop {
				position: Theme.geometry_viewGradient_position2
				color: Theme.color_viewGradient_color1
			}
			GradientStop {
				position: Theme.geometry_viewGradient_position3
				color: Theme.color_viewGradient_color3
			}
		}
	}
}
