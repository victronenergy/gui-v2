/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				ListText {
					//% "Application version"
					text: qsTrId("settings_page_debug_application_version")
					secondaryText: Theme.applicationVersion
				}
			}

			DelegateComponent {
				ListButton {
					id: quitSwitch

					//% "Quit application"
					text: qsTrId("settings_page_debug_quit_application")

					//% "Quit"
					secondaryText: qsTrId("settings_page_debug_quit")

					onClicked: Qt.quit()
				}
			}

			DelegateComponent {
				ListNavigation {
					text: "Power"
					onClicked: Global.pageManager.pushPage("/pages/settings/debug/PagePowerDebug.qml", { title: text })
				}
			}

			DelegateComponent {
				ListNavigation {
					text: "System data"
					onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageSystemData.qml", { title: text })
				}
			}

			DelegateComponent {
				ListNavigation {
					text: "Values"
					onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageDebugVeQItems.qml", { title: text })
				}
			}

			DelegateComponent {
				ListSwitch {
					//% "Enable frame-rate visualizer"
					text: qsTrId("settings_page_debug_enable_fps_visualizer")
					checked: FrameRateModel.enabled
					onClicked: FrameRateModel.enabled = !FrameRateModel.enabled
				}
			}

			DelegateComponent {
				preferredVisible: Qt.platform.os === "linux"
				ListSwitch {
					//% "Display CPU usage"
					text: qsTrId("settings_page_debug_display_cpu_usage")
					checked: Global.displayCpuUsage
					onClicked: Global.displayCpuUsage = !Global.displayCpuUsage
				}
			}

			DelegateComponent {
				ListNavigation {
					text: "UI Library"
					onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageSettingsDemo.qml", { title: text })
				}
			}

			// TODO implement when venus-platform provides equivalent of vePlatform.getMemInfo()
			/*DelegateComponent {
				ListNavigation {
					text: "glibc memory"
					onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageDebugMemoryLibc.qml", { title: text })
				}
			}*/

			// TODO implement when venus-platform provides equivalent of QuickView.imageCacheSize()
			/*DelegateComponent {
				ListNavigation {
					text: "Qt memory"
					onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageDebugMemoryQt.qml", { title: text })
				}
			}*/
		}
	}
}
