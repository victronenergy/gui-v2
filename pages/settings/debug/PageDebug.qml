/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: VisibleItemModel {

			component SwitchItem : ListItem {
				id: switchItem

				property alias checked: childSwitch.checked

				content.children: Switch {
					id: childSwitch
					onClicked: switchItem.clicked()
				}
			}

			ListText {
				//% "Application version"
				text: qsTrId("settings_page_debug_application_version")
				secondaryText: Theme.applicationVersion
			}

			ListButton {
				id: quitSwitch

				//% "Quit application"
				text: qsTrId("settings_page_debug_quit_application")

				//% "Quit"
				secondaryText: qsTrId("settings_page_debug_quit")

				onClicked: Qt.quit()
			}

			ListNavigation {
				text: "Power"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PagePowerDebug.qml", { title: text })
			}

			ListNavigation {
				text: "System data"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageSystemData.qml", { title: text })
			}

			ListNavigation {
				text: "Values"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageDebugVeQItems.qml", { title: text })
			}

			SwitchItem {
				//% "Enable frame-rate visualizer"
				text: qsTrId("settings_page_debug_enable_fps_visualizer")
				checked: FrameRateModel.enabled
				onClicked: FrameRateModel.enabled = !FrameRateModel.enabled
			}

			SwitchItem {
				//% "Display CPU usage"
				text: qsTrId("settings_page_debug_display_cpu_usage")
				checked: Global.displayCpuUsage
				onClicked: Global.displayCpuUsage = !Global.displayCpuUsage
				preferredVisible: Qt.platform.os === "linux"
			}

			SwitchItem {
				//% "Pause electron animations"
				text: qsTrId("settings_page_debug_pause_electron_animations")
				checked: Global.pauseElectronAnimations
				onClicked: Global.pauseElectronAnimations = !Global.pauseElectronAnimations
			}

			ListNavigation {
				text: "UI Library"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageSettingsDemo.qml", { title: text })
			}

			// TODO implement when venus-platform provides equivalent of vePlatform.getMemInfo()
			/*ListNavigation {
				text: "glibc memory"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageDebugMemoryLibc.qml", { title: text })
			}*/

			// TODO implement when venus-platform provides equivalent of QuickView.imageCacheSize()
			/*ListNavigation {
				text: "Qt memory"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageDebugMemoryQt.qml", { title: text })
			}*/
		}
	}
}
