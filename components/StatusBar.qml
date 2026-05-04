/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Loader {
	id: root

	required property PageStack pageStack

	signal controlCardsActivated()
	signal auxCardsActivated()
	signal cardsDeactivated()
	signal sidePanelToggled()

	sourceComponent: Theme.screenSize === Theme.Portrait ? statusBarPortrait : statusBarLandscape

	Component {
		id: statusBarLandscape

		StatusBar_Landscape {
			pageStack: root.pageStack
			focus: true

			onControlCardsActivated: root.controlCardsActivated()
			onAuxCardsActivated: root.auxCardsActivated()
			onCardsDeactivated: root.cardsDeactivated()
			onSidePanelToggled: root.sidePanelToggled()
		}
	}

	Component {
		id: statusBarPortrait

		StatusBar_Portrait {
			pageStack: root.pageStack
			focus: true

			onControlCardsActivated: root.controlCardsActivated()
			onAuxCardsActivated: root.auxCardsActivated()
			onCardsDeactivated: root.cardsDeactivated()
			onSidePanelToggled: root.sidePanelToggled()
		}
	}
}
