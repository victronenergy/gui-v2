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
			? Theme.geometry_controlCard_minimumWidth
			: Theme.geometry_controlCard_maximumWidth

	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsActive
	width: parent.width
	anchors {
		top: parent.top
		bottom: parent.bottom
		bottomMargin: Theme.geometry_controlCardsPage_bottomMargin
	}

	ListView {
		id: cardsView

		anchors {
			fill: parent
			leftMargin: Theme.geometry_controlCardsPage_horizontalMargin
		}
		spacing: Theme.geometry_controlCardsPage_spacing
		orientation: ListView.Horizontal
		boundsBehavior: Flickable.StopAtBounds
		maximumFlickVelocity: Theme.geometry_flickable_maximumFlickVelocity
		flickDeceleration: Theme.geometry_flickable_flickDeceleration

		model: ObjectModel {
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
					model: Global.inverterChargers.veBusDevices

					InverterChargerCard {
						width: root.cardWidth
						inverterCharger: model.device
					}
				}

				Repeater {
					model: Global.inverterChargers.acSystemDevices

					RsSystemCard {
						width: root.cardWidth
						device: model.device
					}
				}

				Repeater {
					model: Global.inverterChargers.inverterDevices

					InverterCard {
						width: root.cardWidth
						inverter: model.device
					}
				}
			}

			Loader {
				active: manualRelays.count > 0
				sourceComponent: SwitchesCard {
					width: root.cardWidth
					height: cardsView.height
					model: manualRelays
				}

				ManualRelayModel { id: manualRelays }
			}
		}
	}
}
