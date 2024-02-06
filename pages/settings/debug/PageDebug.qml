/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: ObjectModel {
			ListItem {
				id: frameRateSwitch
				//% "Enable frame-rate visualizer"
				text: qsTrId("settings_page_debug_enable_fps_visualizer")
				content.children: [
					Switch {
						id: switchItem
						checked: FrameRateModel.enabled
						onClicked: FrameRateModel.enabled = !FrameRateModel.enabled
					}
				]

				MouseArea {
					anchors.fill: parent
					onClicked: FrameRateModel.enabled = !FrameRateModel.enabled
				}
			}

			ListItem {
				id: quitSwitch
				//% "Quit Application"
				text: qsTrId("settings_page_debug_quit_application")
				property bool isQuitting: false
				onIsQuittingChanged: if (isQuitting) Qt.quit()
				content.children: [
					Switch {
						checked: quitSwitch.isQuitting
						onClicked: quitSwitch.isQuitting = !quitSwitch.isQuitting
					}
				]

				MouseArea {
					anchors.fill: parent
					onClicked: quitSwitch.isQuitting = !quitSwitch.isQuitting
				}
			}

			ListNavigationItem {
				text: "Power"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PagePowerDebug.qml", { title: text })
			}

			ListNavigationItem {
				text: "System data"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageSystemData.qml", { title: text })
			}

			ListNavigationItem {
				text: "Test"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageSettingsDemo.qml", { title: text })
			}

			ListNavigationItem {
				text: "Values"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageDebugVeQItems.qml", { title: text })
			}

			ListNavigationItem {
				text: "glibc memory"
				// TODO implement when venus-platform provides equivalent of vePlatform.getMemInfo()
				// onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageDebugMemoryLibc.qml", { title: text })
			}

			ListNavigationItem {
				text: "Qt memory"
				// TODO implement when venus-platform provides equivalent of QuickView.imageCacheSize()
				// onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageDebugMemoryQt.qml", { title: text })
			}

			ListTextItem {
				//% "Application version"
				text: qsTrId("settings_page_debug_application_version")
				secondaryText: Theme.applicationVersion
			}
		}
	}
}
