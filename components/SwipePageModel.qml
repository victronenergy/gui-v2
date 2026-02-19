import QtQuick
import QtQml.Models
import Victron.VenusOS
import Victron.Boat as Boat

ObjectModel {
	id: root

	required property SwipeView view
	readonly property list<Page> pages: showBoatPage && showLevelsPage ?
			[ boatPageLoader.item, briefPageLoader.item, overviewPage, levelsPageLoader.item, notificationsPage, settingsPage ]
		: showBoatPage ?
			[ boatPageLoader.item, briefPageLoader.item, overviewPage, notificationsPage, settingsPage ]
		: showLevelsPage ?
			[ briefPageLoader.item, overviewPage, levelsPageLoader.item, notificationsPage, settingsPage ]
		:	[ briefPageLoader.item, overviewPage, notificationsPage, settingsPage ]
	readonly property bool showLevelsPage: tankCount > 0 || environmentInputCount > 0
	readonly property bool showBoatPage: boatPageLoader.showBoatPageItem.value
	readonly property int tankCount: Global.tanks ? Global.tanks.totalTankCount : 0
	readonly property int environmentInputCount: Global.environmentInputs ? Global.environmentInputs.model.count : 0

	readonly property bool completed: _completed
		&& Global.dataManagerLoaded
		&& Global.systemSettings
		&& Global.tanks
		&& Global.environmentInputs
		&& (showBoatPage && showLevelsPage) ? pages.length === 6 && boatPageLoader.item && levelsPageLoader.item
		  : showBoatPage ? pages.length === 5 && boatPageLoader.item
		  : showLevelsPage ? pages.length === 5 && levelsPageLoader.item
	      : pages.length === 4
	property bool _completed: false

	Loader {
		id: boatPageLoader

		active: root.showBoatPage
		sourceComponent: Global.portraitMode ? portraitBoatPage : landscapeBoatPage

		readonly property Component landscapeBoatPage: Component {
			Boat.BoatPage {
				view: root.view
			}
		}

		readonly property Component portraitBoatPage: Component {
			Boat.PortraitBoatPage {
				view: root.view
			}
		}

		readonly property VeQuickItem showBoatPageItem: VeQuickItem {
			uid: !!Global.systemSettings ? Global.systemSettings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/Enabled" : ""
		}
	}

	Loader {
		id: briefPageLoader

		sourceComponent: Global.portraitMode ? portraitBriefPage : landscapeBriefPage

		readonly property Component landscapeBriefPage: BriefPage {
			view: root.view
			Image {
				width: status === Image.Null ? 0 : Global.screenWidth
				fillMode: Image.PreserveAspectFit
				source: BackendConnection.demoImageFileName
				onStatusChanged: {
					if (status === Image.Ready) {
						console.info("Loaded demo image:", source)
					}
				}
			}
		}

		readonly property Component portraitBriefPage: PortraitBriefPage {
			view: root.view
		}
	}

	OverviewPage {
		id: overviewPage
		view: root.view
	}

	Loader {
		id: levelsPageLoader

		active: root.showLevelsPage
		sourceComponent: landscapeLevelsPage

		readonly property Component landscapeLevelsPage: Component {
			LevelsPage {
				view: root.view
			}
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
