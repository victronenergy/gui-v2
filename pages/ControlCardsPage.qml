/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS

Page {
	id: root

	readonly property alias flickableView: cardsView
	readonly property int cardWidth: Theme.screenSize === Theme.Portrait
		? Theme.geometry_screen_width - (2 * Theme.geometry_page_content_horizontalMargin)
		: (_cardCount > 2 ? Theme.geometry_controlCard_minimumWidth : Theme.geometry_controlCard_maximumWidth)

	readonly property int _cardCount: cardsView.count + (cardsView.headerItem?.headerCardCount ?? 0)

	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsActive

	//% "Controls"
	title: qsTrId("control_cards_title")

	// The cards list view is made up of:
	// - Header - ESS card
	// - Per-device Control Cards for EVCS, Generators, Inverter/chargers
	BaseListView {
		id: cardsView

		anchors {
			fill: parent
			leftMargin: Theme.geometry_controlCardsPage_horizontalMargin
			rightMargin: Theme.geometry_controlCardsPage_horizontalMargin
			bottomMargin: Theme.geometry_controlCardsPage_bottomMargin
		}
		spacing: Theme.geometry_controlCardsPage_spacing
		orientation: Theme.screenSize === Theme.Portrait ? ListView.Vertical : ListView.Horizontal

		// When using key navigation to scroll through the control cards, use a velocity that
		// roughly matches the velocity produced by AuxCardsPage scrollToControl() when it scrolls
		// through the Switch Pane.
		// Note that the control cards do not need a scrollToControl() function, as these cards
		// always fit within a single screen, so it can rely on the ListView auto-scroll behaviour
		// that moves to the start of each card.
		highlightMoveVelocity: Theme.animation_cards_highlightMoveVelocity
		highlightMoveDuration: -1

		header: SettingsFlow {
			readonly property int headerCardCount: emergencyChargeDeviceModel.count
								+ (essCardLoader.active ? 1 : 0)
			width: Theme.screenSize === Theme.Portrait
					? cardsView.width
					: (headerCardCount * root.cardWidth) + (headerCardCount * Theme.geometry_controlCardsPage_spacing)
			height: Theme.screenSize === Theme.Portrait
					? implicitHeight + Theme.geometry_controlCardsPage_spacing
					: cardsView.height
			spacing: Theme.geometry_controlCardsPage_spacing
			focus: true

			Repeater {
				model: emergencyChargeDeviceModel
				delegate: EmergencyChargeCard {
					width: root.cardWidth
					height: Theme.screenSize === Theme.Portrait ? implicitHeight : cardsView.height
				}
			}

			ListItemLoader {
				id: essCardLoader
				width: root.cardWidth
				height: Theme.screenSize === Theme.Portrait ? implicitHeight : cardsView.height
				active: systemType.value === "ESS" || systemType.value === "Hub-4"
				sourceComponent: ESSCard {
					width: root.cardWidth
				}

				VeQuickItem {
					id: systemType
					uid: Services.system.serviceUid + "/SystemType"
				}
			}
		}

		model: controlCardModel
		delegate: ListItemLoader {
			id: deviceDelegate

			required property Device device

			width: root.cardWidth
			height: Theme.screenSize === Theme.Portrait ? implicitHeight : cardsView.height
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
		WheelHandler {
			enabled: Qt.platform.os === "wasm" || Global.isDesktop
			onWheel: (wheel) => {
				// each "click" of the wheel is 120 degrees
				// each "click" of the wheel results in 2/3rds of a second of flick velocity
				// accumulate that with the horizontalVelocity of the view
				// note the sign of that view velocity is opposite to the flick velocity, hence minus.
				cardsView.flick((cardsView.flickDeceleration * 2.0*wheel.angleDelta.y/360) - cardsView.horizontalVelocity, 0)
				wheel.accepted = true
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

	// Note this model of emergency charge devices cannot be simply a FilteredDeviceModel with a
	// childFilterFunction that filters out invalid /EmergencyCharge/Control values, because with
	// such an implementation, the model would be rebuilt every time the /EmergencyCharge/Control
	// value was changed inside EmergencyChargerCard, which in turn would cause the view to
	// re-create the EmergencyChargerCard delegate.
	DeviceModel {
		id: emergencyChargeDeviceModel
	}
	Instantiator {
		model: FilteredDeviceModel {
			sorting: FilteredDeviceModel.Name
			serviceTypes: [ "alternator", "dcdc" ]
		}
		delegate: VeQuickItem {
			required property Device device
			uid: device.serviceUid + "/EmergencyCharge/Control"
			onValidChanged: {
				if (valid) {
					emergencyChargeDeviceModel.addDevice(device)
				} else {
					emergencyChargeDeviceModel.removeDevice(device.serviceUid)
				}
			}
		}
		onObjectRemoved: (index, obj) => {
			emergencyChargeDeviceModel.removeDevice(obj.device.serviceUid)
		}
	}

	Loader {
		id: emptyPageLoader
		anchors {
			fill: parent
			leftMargin: Theme.geometry_page_content_horizontalMargin
			rightMargin: Theme.geometry_page_content_horizontalMargin
		}
		active: root._cardCount === 0
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
