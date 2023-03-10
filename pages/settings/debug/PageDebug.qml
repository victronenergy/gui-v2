/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListPage {
	id: root

	listView: GradientListView {
		model: ObjectModel {

			ListNavigationItem {
				text: "Power"
				listPage: root
				listIndex: ObjectModel.index
				onClicked: listPage.navigateTo("/pages/settings/debug/PagePowerDebug.qml", { title: text }, listIndex)
			}

			ListNavigationItem {
				text: "System data"
				listPage: root
				listIndex: ObjectModel.index
				onClicked: listPage.navigateTo("/pages/settings/debug/PageSystemData.qml", { title: text }, listIndex)
			}

			ListNavigationItem {
				text: "Test"
				listPage: root
				listIndex: ObjectModel.index
				onClicked: listPage.navigateTo("/pages/settings/debug/PageSettingsDemo.qml", { title: text }, listIndex)
			}

			ListNavigationItem {
				text: "Values"
				listPage: root
				listIndex: ObjectModel.index
				onClicked: listPage.navigateTo("/pages/settings/debug/PageDebugVeQItems.qml", { title: text }, listIndex)
			}

			ListNavigationItem {
				text: "glibc memory"
				// TODO implement when venus-platform provides equivalent of vePlatform.getMemInfo()
				//listPage: root
				//listIndex: ObjectModel.index
				//onClicked: listPage.navigateTo("/pages/settings/debug/PageDebugMemoryLibc.qml", { title: text }, listIndex)
			}

			ListNavigationItem {
				text: "Qt memory"
				// TODO implement when venus-platform provides equivalent of QuickView.imageCacheSize()
				//listPage: root
				//listIndex: ObjectModel.index
				//onClicked: listPage.navigateTo("/pages/settings/debug/PageDebugMemoryQt.qml", { title: text }, listIndex)
			}
		}
	}
}
