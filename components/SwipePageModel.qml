import QtQuick
import QtQml.Models
import Victron.VenusOS
import Victron.Boat as Boat

ObjectModel {
	id: root

	required property SwipeView view
	readonly property list<SwipeViewPage> pages: {
		var p = []
		if (showBoatPage) p.push(boatPageLoader.item)
		p.push(briefPage)
		p.push(overviewPage)
		for (var i = 0; i < pluginNavRepeater.count; i++) {
			var loader = pluginNavRepeater.itemAt(i)
			if (loader && loader.item) p.push(loader.item)
		}
		if (showLevelsPage) p.push(levelsPageLoader.item)
		p.push(notificationsPage)
		p.push(settingsPage)
		return p
	}
	readonly property bool showLevelsPage: levelsPageLoader.active && !!levelsPageLoader.item
	readonly property bool showBoatPage: boatPageLoader.active && !!boatPageLoader.item
	readonly property int tankCount: Global.tanks ? Global.tanks.totalTankCount : 0
	readonly property int environmentInputCount: Global.environmentInputs ? Global.environmentInputs.model.count : 0

	readonly property bool completed: _completed
		&& Global.dataManagerLoaded
		&& Global.systemSettings
		&& Global.tanks
		&& Global.environmentInputs
		&& pages.length >= 4

	property bool _completed: false

	Loader {
		id: boatPageLoader

		active: showBoatPageItem.value ?? false
		sourceComponent: Boat.BoatPage {
			view: root.view
		}

		VeQuickItem {
			id: showBoatPageItem
			uid: !!Global.systemSettings ? Global.systemSettings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/Enabled" : ""
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

	// Plugin NavigationPage (type 3) support.
	// Queries all loaded plugins for type 3 integrations and dynamically
	// creates a SwipeViewPage for each one, inserted between Overview and
	// Levels in the nav bar.  Each plugin JSON specifies icon, url, and an
	// optional title (falls back to the plugin name when omitted).
	GuiPluginIntegrationModel {
		id: pluginNavIntegrations
		type: GuiPluginLoader.NavigationPage
	}

	Item {
		id: pluginPagesContainer
		visible: false
		width: 0; height: 0

		Repeater {
			id: pluginNavRepeater
			model: pluginNavIntegrations

			delegate: Loader {
				id: pluginPageDelegate
				required property int index
				required property string pluginName
				required property string title
				required property url icon
				required property url url

		active: true
		sourceComponent: SwipeViewPage {
			view: root.view
			topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
			title: pluginPageDelegate.title !== ""
				? pluginPageDelegate.title
				: pluginPageDelegate.pluginName
			iconSource: pluginPageDelegate.icon
			url: pluginPageDelegate.url
			focusPolicy: Qt.TabFocus

				Loader {
					anchors.fill: parent
					source: pluginPageDelegate.url
				}
			}
			}
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
