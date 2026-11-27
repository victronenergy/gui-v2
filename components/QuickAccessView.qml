/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// The quick access buttons in the status bar: the button that opens the control cards and the
// button that opens the switches (aux) cards.
FocusScope {
	id: root

	required property CombinedListModel model

	required property Component moreButton

	// Set to false to disable quick access buttons, e.g. while the breadcrumbs are shown.
	property bool buttonsEnabled: true

	readonly property int visibleButtonCount: Math.min(model.count,
			(buttonRow.width - firstLeftInset - lastRightInset) / Theme.geometry_statusBar_button_height)

	// Insets that expand the clickable area of the buttons. The first and last insets apply to
	// the left-most and right-most visible buttons, and buttonInset to the edges between them.
	property real firstLeftInset
	property real lastRightInset: Theme.geometry_statusBar_spacing
	property real buttonInset
	property real bottomInset: Theme.geometry_statusBar_spacing

	signal controlCardsActivated()
	signal auxCardsActivated()
	signal cardsDeactivated()

	implicitWidth: buttonRow.width
	implicitHeight: buttonRow.height

	// Plugin cards for the Switches pane. The pane can be opened when it shows only these.
	GuiPluginIntegrationModel {
		id: pluginSwitchCards
		type: GuiPluginLoader.QuickAccessPaneCard
		cardType: GuiPluginLoader.SwitchesCard
	}

	function _row(index) {
			const first = root.model.firstModel
			return index < first.count
							? first.get(index)
							: root.model.secondModel.integrationAt(index - first.count)
	}

	Row {
		id: buttonRow

		width: parent.width

		Repeater {
			id: buttonRepeater

			model: root.visibleButtonCount < root.model.count // If we cannot show all available buttons...
				   ? root.visibleButtonCount - 1  // -1 to make space for the "More" button
				   : root.visibleButtonCount // show all available buttons

			delegate: StatusBarButton {
				id: controlCardsButton

				required property int index

				readonly property var row: root._row(index)
				readonly property int buttonType: Global.mainView?.currentPage?.topLeftButton ?? VenusOS.StatusBar_LeftButton_None
				readonly property bool paneOpened: Global.mainView?.quickAccessOpen(row.url) ?? false

				leftInset: index === 0 ? root.firstLeftInset : 0
				rightInset: auxButton.visible ? root.buttonInset : root.lastRightInset
				bottomInset: root.bottomInset
				icon.source: paneOpened ? row.iconActive : row.icon
				enabled: root.buttonsEnabled
						&& (buttonType === VenusOS.StatusBar_LeftButton_ControlsInactive
							|| buttonType === VenusOS.StatusBar_LeftButton_ControlsActive)
				visible: enabled
				focus: enabled

				KeyNavigation.right: index >= 0 && index < buttonRepeater.count - 1
						? buttonRepeater.itemAt(index + 1)
						: moreButtonLoader

				onClicked: paneOpened ? Global.mainView.cardsLoader.hide()
									  : Global.mainView.showPluginQuickAccess(model.pluginName, model.url)

			}
		}

		Loader {
			id: moreButtonLoader
			sourceComponent: root.moreButton
			enabled: status === Loader.Ready
		}
	}
}
