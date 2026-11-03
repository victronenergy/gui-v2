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
		: (cardsView.count > 2 ? Theme.geometry_controlCard_minimumWidth : Theme.geometry_controlCard_maximumWidth)

	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsActive

	//% "Controls"
	title: qsTrId("control_cards_title")

	// The cards list view is made up of:
	// - Header - ESS card
	// - Per-device Control Cards for EVCS, Generators, Inverter/chargers
	// - Plugin-provided Cards
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

		// The built-in ListView scrolling only shows the start of each card. Instead, scroll to show
		// the focused control, so that it can be seen even if its card is larger than the view.
		highlightFollowsCurrentItem: false

		header: ListItemLoader {
			active: systemType.value === "ESS" || systemType.value === "Hub-4"
			sourceComponent: FocusScope {
				width: essCard.width + cardsView.spacing
				height: essCard.height + cardsView.spacing
				focus: true

				ESSCard {
					id: essCard
					width: root.cardWidth
					height: Theme.screenSize === Theme.Portrait ? implicitHeight : cardsView.height
				}
			}

			VeQuickItem {
				id: systemType
				uid: Services.system.serviceUid + "/SystemType"
			}
		}

		// The models are declared inside the view, so that the view is destroyed first. Otherwise,
		// it could warn when it stops creating a delegate for a row that has already been removed.
		model: CombinedListModel {
			firstModel: FilteredDeviceModel {
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
			secondModel: GuiPluginIntegrationModel {
				id: pluginModel

				type: GuiPluginLoader.QuickAccessPaneCard
				cardType: GuiPluginLoader.ControlsCard
			}
		}
		delegate: ListItemLoader {
			id: cardDelegate

			required property var sourceModel
			required property var model
			readonly property Item focusedItem: activeFocus && Global.keyNavigationEnabled
					? Window.activeFocusItem
					: null

			width: root.cardWidth
			height: Theme.screenSize === Theme.Portrait ? implicitHeight : cardsView.height

			onFocusedItemChanged: {
				if (focusedItem) {
					cardsView.scrollToFocusedItem(focusedItem)
				}
			}

			Component.onCompleted: {
				if (sourceModel === pluginModel) {
					source = model.url
					return
				}
				sourceComponent = model.device.serviceType === "evcharger" ? evcsComponent
						: model.device.serviceType === "generator" ? generatorComponent
						: inverterChargerComponent
			}

			onLoaded: {
				if (sourceModel !== pluginModel || !item) {
					return
				}
				// PluginCard sizes itself to its content. The pane sets the card's size.
				item.width = Qt.binding(() => root.cardWidth)
				item.height = Qt.binding(() => Theme.screenSize === Theme.Portrait
						? item.implicitHeight : cardsView.height)
			}

			onStatusChanged: {
				if (sourceModel !== pluginModel || status !== Loader.Error) {
					return
				}
				const failedUrl = model.url
				console.warn("Unable to load card from plugin %1: %2"
						.arg(model.pluginName).arg(failedUrl))
				// The row is removed after this function returns, so the loader is not destroyed
				// while its status is still changing.
				Qt.callLater(function() { pluginModel.removeUrl(failedUrl) })
			}

			Component {
				id: evcsComponent

				EVCSCard {
					width: root.cardWidth
					serviceUid: cardDelegate.model.device.serviceUid
				}
			}

			Component {
				id: generatorComponent

				GeneratorCard {
					width: root.cardWidth
					serviceUid: cardDelegate.model.device.serviceUid
				}
			}

			Component {
				id: inverterChargerComponent

				InverterChargerCard {
					width: root.cardWidth
					serviceUid: cardDelegate.model.device.serviceUid
					name: cardDelegate.model.device.name
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
