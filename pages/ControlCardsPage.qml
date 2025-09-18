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
	// - Per-device Control Cards for EVCS, Generators, Inverter/chargers
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
				KeyNavigationHighlight.active: false

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

		model: controlCardModel
		delegate: BaseListLoader {
			id: deviceDelegate

			required property Device device

			width: root.cardWidth
			height: cardsView.height
			sourceComponent: {
				if (device.serviceType === "evcharger") {
					return evcsComponent
				} else if (device.serviceType === "generator") {
					return generatorComponent
				}
				return inverterChargerComponent
			}

			Component {
				id: evcsComponent

				EVCSCard {
					width: root.cardWidth
					serviceUid: deviceDelegate.device.serviceUid
				}
			}

			Component {
				id: generatorComponent

				GeneratorCard {
					width: root.cardWidth
					serviceUid: deviceDelegate.device.serviceUid
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

	FilteredDeviceModel {
		id: controlCardModel
		sorting: FilteredDeviceModel.ServiceTypeOrder | FilteredDeviceModel.Name
		serviceTypes: [ "evcharger", "generator", "vebus", "acsystem", "inverter" ]
		childFilterIds: { "evcharger": ["Mode"], "generator": ["Enabled"] }
		childFilterFunction: (device, childItems) => {
			if (device.serviceType === "evcharger") {
				// Only include EV chargers that represent controllable EV chargers (with valid
				// /Mode values), to prevent Energy Meters from appearing in the cards.
				return childItems["Mode"]?.value !== undefined
			} else if (device.serviceType === "generator") {
				// Only include generators with /Enabled=1, which means they have the startstop1
				// for starting/stopping the generator.
				return childItems["Enabled"]?.value === 1
			} else {
				return true
			}
		}
	}
}
