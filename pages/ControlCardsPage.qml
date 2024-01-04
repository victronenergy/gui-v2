/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property int cardWidth: cardsView.count > 2
			? Theme.geometry_controlCard_minimumWidth
			: Theme.geometry_controlCard_maximumWidth

	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsActive

	ListView {
		id: cardsView

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_controlCardsPage_horizontalMargin
			right: parent.right
			top: parent.top
			bottom: parent.bottom
			bottomMargin: Theme.geometry_controlCardsPage_bottomMargin
		}
		rightMargin: Theme.geometry_controlCardsPage_horizontalMargin
		spacing: Theme.geometry_controlCardsPage_spacing
		orientation: ListView.Horizontal
		snapMode: ListView.SnapOneItem
		boundsBehavior: Flickable.DragOverBounds

		model: ObjectModel {
			Row {
				height: cardsView.height
				spacing: Theme.geometry_controlCardsPage_spacing

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
				spacing: Theme.geometry_controlCardsPage_spacing

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

				VeQuickItem {
					id: systemType
					uid: Global.system.serviceUid + "/SystemType"
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
