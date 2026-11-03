/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS

Page {
	id: root

	readonly property alias flickableView: cardsView

	implicitHeight: Theme.geometry_controlCard_height

	//: Name of the Switch Controls feature
	//% "Switches"
	title: qsTrId("aux_page_switches")

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

		// The models are declared inside the view, so that the view is destroyed first. Otherwise,
		// it could warn when it stops creating a delegate for a row that has already been removed.
		model: CombinedListModel {
			firstModel: SortedIOChannelGroupModel { sourceModel: Services.ioChannels.groups }
			secondModel: GuiPluginIntegrationModel {
				id: pluginModel

				type: GuiPluginLoader.QuickAccessPaneCard
				cardType: GuiPluginLoader.SwitchesCard
			}
		}
		delegate: ListItemLoader {
			id: cardDelegate

			required property var sourceModel
			required property var model
			readonly property Item focusedItem: activeFocus && Global.keyNavigationEnabled
					? Window.activeFocusItem
					: null

			width: Theme.screenSize === Theme.Portrait ? cardsView.width : implicitWidth
			height: Theme.screenSize === Theme.Portrait ? implicitHeight : cardsView.height

			onFocusedItemChanged: {
				if (focusedItem && sourceModel === pluginModel) {
					cardsView.scrollToFocusedItem(focusedItem)
				}
			}

			Component.onCompleted: {
				if (sourceModel === pluginModel) {
					source = model.url
					return
				}
				sourceComponent = groupCardComponent
			}

			onLoaded: {
				if (sourceModel !== pluginModel || !item) {
					return
				}
				// PluginCard sizes itself to its content. The pane sets the card's size.
				item.width = Qt.binding(() => Theme.screenSize === Theme.Portrait
						? cardsView.width : item.implicitWidth)
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
				id: groupCardComponent

				IOChannelGroupCard {
					group: cardDelegate.model.group
					onCurrentItemChanged: {
						if (currentItem) {
							cardsView.scrollToFocusedItem(currentItem)
						}
					}
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

}
