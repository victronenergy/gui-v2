/*
** Copyright (C) 2023 Victron Energy B.V.
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

			ListNavigationItem {
				Component {
					id: pagePowerDebug

					PagePowerDebug { }
				}
				text: "Power"
				onClicked: Global.pageManager.pushPage(pagePowerDebug, { title: text })
			}

			ListNavigationItem {
				Component {
					id: pageSystemData

					PageSystemData { }
				}
				text: "System data"
				onClicked: Global.pageManager.pushPage(pageSystemData, { title: text })
			}

			ListNavigationItem {
				Component {
					id: pageSettingsDemo

					PageSettingsDemo { }
				}
				text: "Test"
				onClicked: Global.pageManager.pushPage(pageSettingsDemo, { title: text })
			}

			ListNavigationItem {
				Component {
					id: pageDebugVeQItems

					PageDebugVeQItems { }
				}
				text: "Values"
				onClicked: Global.pageManager.pushPage(pageDebugVeQItems, { title: text })
			}

			ListNavigationItem {
				text: "glibc memory"
				// TODO implement when venus-platform provides equivalent of vePlatform.getMemInfo()
				// onClicked: Global.pageManager.pushPage("PageDebugMemoryLibc.qml", { title: text })
			}

			ListNavigationItem {
				text: "Qt memory"
				// TODO implement when venus-platform provides equivalent of QuickView.imageCacheSize()
				// onClicked: Global.pageManager.pushPage("PageDebugMemoryQt.qml", { title: text })
			}
		}
	}
}
