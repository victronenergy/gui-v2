/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A button in the status bar, after the controls button, that opens a pane in the cards view.

	Declaring a pane adds its button; destroying the pane removes it, and closes the pane if it
	is open. Buttons are ordered by 'order', then by the order in which they were added.

	As paneId is required, an Instantiator delegate gets no 'model' context property, so declare
	the model roles it needs as required properties.
*/
QtObject {
	id: root

	required property string paneId
	property int order
	property bool available: true
	property url iconSource
	property url activeIconSource: iconSource
	property Component paneComponent

	readonly property bool opened: (Global.mainView?.cardsActive ?? false)
			&& Global.mainView.cardsLoader.viewId === paneId

	Component.onCompleted: Global.statusBarPanes.addPane(root)
	Component.onDestruction: {
		if (opened) {
			Global.mainView.cardsLoader.hide()
		}
		Global.statusBarPanes.removePane(root)
	}
}
