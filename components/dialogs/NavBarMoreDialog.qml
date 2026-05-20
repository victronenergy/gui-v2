/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ModalDialog {
	id: root

	required property list<SwipeViewPage> pages
	required property int hiddenPageCount
	required property int currentNavBarIndex

	signal buttonClicked(pageIndex : int)

	backgroundColor: Theme.color_page_background
	footer: null
	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_CancelOnly
	bottomPadding: 0

	// Turn off fade in/out. They cause the flickering because the nested NavBar fades in/out on
	// top of the actual NavBar.
	enter: null
	exit: null

	contentItem: ColumnLayout {
		spacing: 0

		Repeater {
			id: moreButtonsRepeater

			model: root.hiddenPageCount
			delegate: ListItem {
				id: hiddenPageItem

				required property int index
				readonly property int pageIndex: root.pages.length - root.hiddenPageCount + index
				readonly property SwipeViewPage page: root.pages[pageIndex]

				function click() {
					root.buttonClicked(pageIndex)
				}

				contentItem: RowLayout {
					spacing: hiddenPageItem.spacing

					CP.ColorImage {
						source: hiddenPageItem.page.iconSource ?? ""
						color: Theme.color_navigationBar_button_off

						Loader {
							anchors {
								left: parent.horizontalCenter
								topMargin: Theme.geometry_navigationBar_notifications_redDot_margin
							}
							active: (Global.notifications?.navBarNotificationCounterVisible ?? false)
									&& hiddenPageItem.page.url.endsWith("NotificationsPage.qml")
							sourceComponent: NotificationCounter {
								count: Global.notifications?.unacknowledgedCount ?? 0
							}
						}
					}

					Label {
						text: hiddenPageItem.page.title ?? ""
						font: hiddenPageItem.font
						elide: Text.ElideRight

						Layout.fillWidth: true
					}

					CP.ColorImage {
						source: "qrc:/images/icon_chevron_right_32.svg"
						color: Theme.color_listItem_forwardIcon
					}
				}

				background: ListItemBackground {
					implicitWidth: Theme.geometry_listItem_width
					implicitHeight: Theme.geometry_listItem_height

					ListPressArea {
						anchors.fill: parent
						onClicked: hiddenPageItem.click()
					}
				}

				KeyNavigation.down: index >= 0 && index < moreButtonsRepeater.count - 1
						? moreButtonsRepeater.itemAt(index + 1)
						: null
				Keys.onSpacePressed: hiddenPageItem.click()
			}
		}

		// Spacer item, needed because the Repeater and nested NavBar cannot be stretched.
		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true
		}

		// A replica of the navigation bar that is shown in the main view, to allow the user to
		// click back to any of those pages from within the "More" dialog.
		NavBar {
			id: navBar
			pages: root.pages
			backgroundColor: "transparent" // allow dialog background with shadow to come through
			moreDialogVisible: true
			moreButton: NavButton {
				// This is a "More" button that does nothing when clicked, since the "More" dialog
				// is currently shown.
				width: navBar.buttonWidth
				text: root.title
				icon.source: "qrc:/images/icon_more_dots.svg"
				checked: true
				enabled: false
			}
			onCurrentIndexChanged: {
				root.buttonClicked(currentIndex)
			}
		}
	}
}
