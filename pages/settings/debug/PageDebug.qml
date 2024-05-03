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

			component SwitchItem : ListItem {
				id: switchItem

				signal clicked
				property alias checked: childSwitch.checked

				content.children: Switch {
					id: childSwitch
					focus: true
					Keys.onSpacePressed: switchItem.clicked()
					onClicked: switchItem.clicked()
				}

				ListPressArea {
					radius: switchItem.backgroundRect.radius
					anchors {
						fill: parent
						bottomMargin: switchItem.spacing
					}
					onClicked: switchItem.clicked()
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
				allowed: defaultAllowed && Qt.platform.os === "linux"
			}

			SwitchItem {
				//% "Pause electron animations"
				text: qsTrId("settings_page_debug_pause_electron_animations")
				checked: Global.pauseElectronAnimations
				onClicked: Global.pauseElectronAnimations = !Global.pauseElectronAnimations
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
