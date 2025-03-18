import QtQuick
import QtQuick.Window
import Victron.VenusOS

import Victron.Gauges

Page {
	id: root

	property int cardWidth: Theme.geometry_controlCard_minimumWidth
	topLeftButton: VenusOS.StatusBar_LeftButton_None
	topAuxButton: VenusOS.StatusBar_AuxButton_AuxActive
	width: parent.width
	anchors {
		top: parent.top
		bottom: parent.bottom
		bottomMargin: Theme.geometry_controlCardsPage_bottomMargin
	}


	ListView {
		id: auxView
		anchors {
			fill: parent
			leftMargin: Theme.geometry_controlCardsPage_horizontalMargin
			rightMargin: Theme.geometry_controlCardsPage_horizontalMargin
		}
		spacing: Theme.geometry_controlCardsPage_spacing
		orientation: ListView.Horizontal
		boundsBehavior: Flickable.StopAtBounds
		maximumFlickVelocity: Theme.geometry_flickable_maximumFlickVelocity
		flickDeceleration: Theme.geometry_flickable_flickDeceleration

		model: ObjectModel {
			Loader {
				id: switchesLoader
				sourceComponent: SwitchAuxInsert{
					onImplicitWidthChanged: switchesLoader.width = implicitWidth
					height: auxView.height
				}
			}
			//place holder for other aux cards types ie Bilge pump service
		}
	}
}
