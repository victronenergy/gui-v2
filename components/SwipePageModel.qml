import QtQuick
import QtQml.Models
import Victron.VenusOS
import Victron.Boat as Boat

ObjectModel {
	id: root

	required property SwipeView view
	readonly property list<SwipeViewPage> pages: {
		let list = []
		if (showBoatPage) {
			list.push(boatPageLoader.item)
		}
		list.push(briefPage, overviewPage)
		if (showCamperPage) {
			list.push(camperPageLoader.item)
		}
		if (showLevelsPage) {
			list.push(levelsPageLoader.item)
		}
		list.push(notificationsPage, settingsPage)
		return list
	}
	readonly property bool showLevelsPage: levelsPageLoader.active && !!levelsPageLoader.item
	readonly property bool showBoatPage: boatPageLoader.active && !!boatPageLoader.item
	readonly property bool showCamperPage: camperPageLoader.active && !!camperPageLoader.item
	readonly property int tankCount: Services.tanks.totalTankCount
	readonly property int environmentInputCount: Services.environment.model.count

	readonly property bool completed: _completed
		&& pages.length === 4 + (boatPageLoader.active ? 1 : 0) + (camperPageLoader.active ? 1 : 0) + (levelsPageLoader.active ? 1 : 0)

	property bool _completed: false

	Loader {
		id: boatPageLoader

		active: showBoatPageItem.value ?? false
		sourceComponent: Boat.BoatPage {
			view: root.view
		}

		VeQuickItem {
			id: showBoatPageItem
			uid: Services.settings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/Enabled"
		}
	}

	BriefPage {
		id: briefPage
		view: root.view

		Image {
			width: status === Image.Null ? 0 : Theme.geometry_screen_width
			fillMode: Image.PreserveAspectFit
			source: UiConfig.demoImageFileName
			onStatusChanged: {
				if (status === Image.Ready) {
					console.info("Loaded demo image:", source)
				}
			}
		}
	}

	OverviewPage {
		id: overviewPage
		view: root.view
	}

	Loader {
		id: camperPageLoader

		// 0: no illustration, 1: RV illustration
		active: customIllustrationItem.value === 1
		sourceComponent: CamperPage {
			view: root.view
		}

		VeQuickItem {
			id: customIllustrationItem
			uid: Services.settings.serviceUid + "/Settings/Gui/CustomIllustration"
		}
	}

	Loader {
		id: levelsPageLoader

		active: root.tankCount > 0 || root.environmentInputCount > 0
		sourceComponent: LevelsPage {
			view: root.view
		}
	}

	NotificationsPage {
		id: notificationsPage
		view: root.view
	}

	SettingsPage {
		id: settingsPage
		view: root.view
	}

	Component.onCompleted: Qt.callLater(function() { root._completed = true })
}
