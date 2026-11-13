/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
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
				type: GuiPluginLoader.QuickAccessPaneCard
				cardType: GuiPluginLoader.SwitchesCard
			}
		}
		delegate: ListItemLoader {
			id: cardDelegate

			required property bool fromSecondModel
			required property var model

			width: Theme.screenSize === Theme.Portrait ? cardsView.width : implicitWidth
			height: Theme.screenSize === Theme.Portrait ? implicitHeight : cardsView.height
			preferredVisible: !fromSecondModel || item?.status === Loader.Ready
			sourceComponent: fromSecondModel ? pluginCardComponent : groupCardComponent

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

			Component {
				id: pluginCardComponent

				Loader {
					id: pluginCardLoader

					readonly property Item focusedItem: activeFocus && Global.keyNavigationEnabled
							? Window.activeFocusItem
							: null

					focus: true
					source: cardDelegate.model.url
					onLoaded: {
						if (item) {
							item.focus = true
						}
					}
					onFocusedItemChanged: {
						if (focusedItem) {
							cardsView.scrollToFocusedItem(focusedItem)
						}
					}
					onStatusChanged: {
						if (status === Loader.Error) {
							// The Loader clears source when the card cannot be created.
							console.warn("Unable to load card from plugin %1: %2"
								.arg(cardDelegate.model.pluginName)
								.arg(cardDelegate.model.url))
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
