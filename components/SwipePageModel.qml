import QtQuick
import QtQml.Models
import Victron.VenusOS
import Victron.Boat as Boat

ObjectModel {
	id: root

	required property SwipeView view
	readonly property list<SwipeViewPage> pages: showBoatPage && showLevelsPage ?
			[ boatPage, briefPage, overviewPage, levelsPage, notificationsPage, settingsPage ]
		: showBoatPage && boatPage && briefPage ?
			[ boatPage, briefPage, overviewPage, notificationsPage, settingsPage ]
		: showLevelsPage && boatPage && briefPage ?
			[ briefPage, overviewPage, levelsPage, notificationsPage, settingsPage ]
		: [ briefPage, overviewPage, notificationsPage, settingsPage ]
	readonly property bool showLevelsPage: tankCount > 0 || environmentInputCount > 0
	readonly property bool showBoatPage: showBoatPageItem.value ?? false
	readonly property int tankCount: Global.tanks ? Global.tanks.totalTankCount : 0
	readonly property int environmentInputCount: Global.environmentInputs ? Global.environmentInputs.model.count : 0

	readonly property bool completed: _completed
		&& Global.dataManagerLoaded
		&& Global.systemSettings
		&& Global.tanks
		&& Global.environmentInputs
		&& (showBoatPage && showLevelsPage) ? pages.length === 6
		  : showBoatPage ? pages.length === 5
		  : showLevelsPage ? pages.length === 5
		  : pages.length === 4
	property bool _completed: false

	Boat.BoatPage {
		id: boatPage
		view: root.view

		VeQuickItem {
			id: showBoatPageItem
			uid: !!Global.systemSettings ? Global.systemSettings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/Enabled" : ""
		}
	}

	BriefPage {
		id: briefPage
		view: root.view
	}

	OverviewPage {
		id: overviewPage
		view: root.view
	}

	LevelsPage {
		id: levelsPage
		view: root.view
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
