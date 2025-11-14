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

		// When using key navigation to scroll through the control cards, use a velocity that
		// roughly matches the velocity produced by AuxCardsPage scrollToControl() when it scrolls
		// through the Switch Pane.
		// Note that the control cards do not need a scrollToControl() function, as these cards
		// always fit within a single screen, so it can rely on the ListView auto-scroll behaviour
		// that moves to the start of each card.
		highlightMoveVelocity: Theme.animation_cards_highlightMoveVelocity
		highlightMoveDuration: -1

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

	Loader {
		id: emptyPageLoader
		anchors {
			fill: parent
			leftMargin: Theme.geometry_page_content_horizontalMargin
			rightMargin: Theme.geometry_page_content_horizontalMargin
		}
		active: cardsView.count === 0 && !cardsView.headerItem.active
		sourceComponent: EmptyPageItem {
			//% "Controls"
			titleText: qsTrId("controlcards_empty_title")
			//% "No compatible devices found"
			primaryText: qsTrId("controlcards_empty_desc1")
			//% "Connect devices that support this function"
			secondaryText: qsTrId("controlcards_empty_desc2")
			imageSource: "qrc:/images/controlcards-no-devices.svg"
			imageColor: Theme.color_emptyPageItem_logo
		}
	}
}
