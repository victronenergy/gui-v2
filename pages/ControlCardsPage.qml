/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import Victron.Velib
import Victron.VenusOS

Page {
	id: root

	ListView {
		id: cardsView

		anchors {
			left: parent.left
			leftMargin: Theme.geometry.controlCardsPage.leftMargin
			right: parent.right
			top: parent.top
			bottom: parent.bottom
			bottomMargin: Theme.geometry.controlCardsPage.bottomMargin
		}
		spacing: Theme.geometry.controlCardsPage.spacing
		orientation: ListView.Horizontal
		snapMode: ListView.SnapOneItem
		boundsBehavior: Flickable.DragOverBounds

		model: ObjectModel {
			Row {
				height: cardsView.height

				Repeater {
					model: generators ? generators.model : null

					GeneratorCard {
						state: model.generator.state
						runtime: model.generator.runtime
						runningBy: model.generator.runningBy
						manualStartTimer: model.generator.manualStartTimer

						// TODO bind 'autostart' property to dbus backend value (not yet available)
						// and add changeAutoStart() handler to update when autostart switch is toggled.

						onManualStart: function(durationSecs) {
							model.generator.start(durationSecs)
						}
						onManualStop: {
							model.generator.stop()
						}
					}
				}
			}
		}
	}
}
