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

	// The cards list view is made up of:
	// - Header - ESS card
	// - List items: Cards for EVCS, Generators, Inverter/chargers
	// - Footer - Manual relays
	//
	// Any single list item should not exceed the width of the view, otherwise it cannot be fully
	// seen when the view is scrolled using key navigation.
	BaseListView {
		id: cardsView

		anchors {
			fill: parent
			leftMargin: Theme.geometry_controlCardsPage_horizontalMargin
			rightMargin: Theme.geometry_controlCardsPage_horizontalMargin
		}
		spacing: Theme.geometry_controlCardsPage_spacing
		orientation: ListView.Horizontal

		header: BaseListLoader {
			active: systemType.value === "ESS" || systemType.value === "Hub-4"
			sourceComponent: BaseListItem {
				width: root.cardWidth + cardsView.spacing
				height: cardsView.height
				background.visible: false
				navigationHighlight.visible: false

				ESSCard {
					width: root.cardWidth
					height: cardsView.height
				}
			}

			VeQuickItem {
				id: systemType
				uid: Global.system.serviceUid + "/SystemType"
			}
		}

		footer: BaseListLoader {
			active: manualRelays.count > 0
			sourceComponent: BaseListItem {
				width: root.cardWidth + cardsView.spacing
				height: cardsView.height
				background.visible: false
				navigationHighlight.visible: false

				SwitchesCard {
					x: cardsView.spacing
					width: root.cardWidth
					height: cardsView.height
					model: manualRelays
				}
			}

			ManualRelayModel { id: manualRelays }
		}

		model: AggregateDeviceModel {
			sortBy: AggregateDeviceModel.NoSort
			sourceModels: [
				Global.evChargers.model,
				Global.generators.model,
				Global.inverterChargers.veBusDevices,
				Global.inverterChargers.acSystemDevices,
				Global.inverterChargers.inverterDevices
			]
		}

		delegate: BaseListLoader {
			id: deviceDelegate

			required property Device device

			// TODO remove Energy Meters from the EVCS model to avoid this hack to hide the card.
			width: preferredVisible ? root.cardWidth : -cardsView.spacing
			height: cardsView.height
			preferredVisible: item?.preferredVisible ?? false
			visible: effectiveVisible

			sourceComponent: {
				const serviceType = BackendConnection.serviceTypeFromUid(device.serviceUid)
				if (serviceType === "evcharger") {
					return evcsComponent
				} else if (serviceType === "generator") {
					return generatorComponent
				}
				return inverterChargerComponent
			}

			Component {
				id: evcsComponent

				EVCSCard {
					width: root.cardWidth
					evCharger: deviceDelegate.device
				}
			}

			Component {
				id: generatorComponent

				GeneratorCard {
					width: root.cardWidth
					generator: deviceDelegate.device
				}
			}

			Component {
				id: inverterChargerComponent

				InverterChargerCard {
					width: root.cardWidth
					serviceUid: deviceDelegate.device.serviceUid
					name: deviceDelegate.device.name
				}
			}
		}
	}
}
