/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	SettingsListView {
		model: ObjectModel {

			SettingsListNavigationItem {
				text: "Power"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PagePowerDebug.qml", { title: text })
			}

			SettingsListNavigationItem {
				text: "System data"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageSystemData.qml", { title: text })
			}

			SettingsListNavigationItem {
				text: "Test"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageSettingsDemo.qml", { title: text })
			}

			SettingsListNavigationItem {
				text: "Values"
				onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageDebugVeQItems.qml", { title: text })
			}

			SettingsListNavigationItem {
				text: "glibc memory"
				// TODO implement when venus-platform provides equivalent of vePlatform.getMemInfo()
				// onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageDebugMemoryLibc.qml", { title: text })
			}

			SettingsListNavigationItem {
				text: "Qt memory"
				// TODO implement when venus-platform provides equivalent of QuickView.imageCacheSize()
				// onClicked: Global.pageManager.pushPage("/pages/settings/debug/PageDebugMemoryQt.qml", { title: text })
			}
		}
	}
}
