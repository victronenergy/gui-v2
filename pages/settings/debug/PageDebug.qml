/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: ObjectModel {

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
		}
	}
}
