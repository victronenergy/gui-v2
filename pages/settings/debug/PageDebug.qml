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

				PressArea {
					radius: frameRateSwitch.backgroundRect.radius
					anchors {
						fill: parent
						bottomMargin: frameRateSwitch.spacing
					}
					onClicked: FrameRateModel.enabled = !FrameRateModel.enabled
				}
			}

			ListButton {
				id: quitSwitch

				//% "Quit application"
				text: qsTrId("settings_page_debug_quit_application")

				//% "Quit"
				button.text: qsTrId("settings_page_debug_quit")

				onClicked: Qt.quit()
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

			// TODO implement when venus-platform provides equivalent of vePlatform.getMemInfo()
			/*ListNavigationItem {
				text: "glibc memory"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageDebugMemoryLibc.qml", { title: text })
			}*/

			// TODO implement when venus-platform provides equivalent of QuickView.imageCacheSize()
			/*ListNavigationItem {
				text: "Qt memory"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageDebugMemoryQt.qml", { title: text })
			}*/

			ListTextItem {
				//% "Application version"
				text: qsTrId("settings_page_debug_application_version")
				secondaryText: Theme.applicationVersion
			}
		}
	}
}
