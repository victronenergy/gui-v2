/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS

Page {
	id: root

	property int cardWidth: cardsView.count > 2
			? Theme.geometry.controlCard.minimumWidth
			: Theme.geometry.controlCard.maximumWidth

	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsActive

	ListView {
		id: cardsView

		anchors {
			left: parent.left
			leftMargin: Theme.geometry.controlCardsPage.horizontalMargin
			right: parent.right
			top: parent.top
			bottom: parent.bottom
			bottomMargin: Theme.geometry.controlCardsPage.bottomMargin
		}
		rightMargin: Theme.geometry.controlCardsPage.horizontalMargin
		spacing: Theme.geometry.controlCardsPage.spacing
		orientation: ListView.Horizontal
		snapMode: ListView.SnapOneItem
		boundsBehavior: Flickable.DragOverBounds

		model: ObjectModel {
			Row {
				height: cardsView.height
				spacing: Theme.geometry.controlCardsPage.spacing

				Repeater {
					model: Global.generators.model

					GeneratorCard {
						width: root.cardWidth
						generator: model.device
					}
				}
			}

			Row {
				height: cardsView.height
				spacing: Theme.geometry.controlCardsPage.spacing

				Repeater {
					model: Global.veBusDevices.model

					VeBusDeviceCard {
						width: root.cardWidth
						veBusDevice: model.device
					}
				}
			}

			Loader {
				active: systemType.value === "ESS" || systemType.value === "Hub-4"
				sourceComponent: ESSCard {
					width: root.cardWidth
					height: cardsView.height
				}

				DataPoint {
					id: systemType
					source: "com.victronenergy.system/SystemType"
				}
			}

			Loader {
				active: Global.relays.manualRelays.count > 0
				sourceComponent: SwitchesCard {
					width: root.cardWidth
					height: cardsView.height
					model: Global.relays.manualRelays
				}
			}
		}
	}
}
