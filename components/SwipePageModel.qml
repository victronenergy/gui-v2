import QtQuick
import QtQml.Models
import Victron.VenusOS
import Victron.Boat as Boat

ObjectModel {
	id: root

	required property SwipeView view
	// Bump when plugin enable flips so `pages` re-filters without destroying delegates.
	property int pluginEnableRevision: 0
	// Delegate Loaders finish after `count` changes. `itemAt()` is not a binding
	// dependency, so a nav page is dropped until something re-reads `pages`.
	property int pluginNavReady: 0

	readonly property list<SwipeViewPage> pages: {
		void pluginEnableRevision
		void pluginNavReady
		var p = []
		if (showBoatPage) p.push(boatPageLoader.item)
		p.push(briefPage)
		p.push(overviewPage)
		for (var i = 0; i < pluginNavRepeater.count; i++) {
			var loader = pluginNavRepeater.itemAt(i)
			if (!loader || !loader.item) {
				continue
			}
			// Disabled nav plugins stay in the repeater but drop out of the swipe/nav list.
			if (!GuiPluginLoader.isPluginEnabled(loader.pluginName)) {
				continue
			}
			if (loader.item.contentFailed) {
				continue
			}
			p.push(loader.item)
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
		// Boat, Levels, and plugin nav wrappers load after the four stock pages. A later change
		// to `pages` resets the swipe view to the first page, which drops a configured start page.
		// Plugin content is not waited on, so a hanging plugin cannot block startup.
		&& (!boatPageLoader.active || showBoatPage)
		&& (!levelsPageLoader.active || showLevelsPage)
		&& _pluginNavPagesReady

	readonly property bool _pluginNavPagesReady: {
		void pluginNavReady
		for (let i = 0; i < pluginNavRepeater.count; ++i) {
			const loader = pluginNavRepeater.itemAt(i)
			if (!loader || !loader.item) {
				return false
			}
		}
		return true
	}

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

	function pluginHasNavigation(name) {
		const plugin = GuiPluginLoader.plugin(name)
		const integrations = plugin ? plugin.integrations : null
		if (!integrations)
			return false
		for (let i = 0; i < integrations.length; ++i) {
			if (integrations[i].type === GuiPluginLoader.NavigationPage)
				return true
		}
		return false
	}

	Connections {
		target: GuiPluginLoader
		function onPluginEnabledChanged(name) {
			const mv = Global.mainView
			if (mv) {
				const current = mv.swipeView && mv.swipeView.currentItem && mv.swipeView.currentItem.url
						? String(mv.swipeView.currentItem.url) : ""
				const pinned = mv._pinnedMainPageUrl ? String(mv._pinnedMainPageUrl) : ""
				// The visible page wins. A stale pin must not pull the view back to Brief.
				mv._resyncUrl = current || pinned
			}
			if (root.pluginHasNavigation(name))
				root.pluginEnableRevision++
		}
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
				required property url iconActive
				required property url url

				// Keep delegates alive across enable toggles; `pages` filters by enabled.
				active: true
				onStatusChanged: {
					if (status === Loader.Ready)
						root.pluginNavReady++
				}
				sourceComponent: SwipeViewPage {
					id: pluginSwipePage
					view: root.view
					topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
					title: pluginPageDelegate.title !== ""
						? pluginPageDelegate.title
						: pluginPageDelegate.pluginName
					iconSource: pluginSwipePage.SwipeView.isCurrentItem
							&& String(pluginPageDelegate.iconActive).length > 0
						? pluginPageDelegate.iconActive
						: pluginPageDelegate.icon
					url: pluginPageDelegate.url
					focusPolicy: Qt.TabFocus

					property bool contentVisited: false
					readonly property bool contentEnabled: {
						void root.pluginEnableRevision
						return GuiPluginLoader.isPluginEnabled(pluginPageDelegate.pluginName)
					}
					onContentEnabledChanged: {
						// Disable unloads the page. Leave the visited flag set and a re-enable
						// while the user is still in Settings reloads it off-screen.
						if (!contentEnabled)
							contentVisited = false
					}
					readonly property bool contentFailed: pluginContentLoader.status === Loader.Error

					onActiveFocusChanged: {
						if (activeFocus && Global.keyNavigationEnabled && pluginContentLoader.item) {
							pluginContentLoader.item.forceActiveFocus()
						}
					}

					Loader {
						id: pluginContentLoader
						anchors.fill: parent
						asynchronous: true
						active: pluginSwipePage.contentEnabled
								&& (pluginSwipePage.SwipeView.isCurrentItem || pluginSwipePage.contentVisited)
						source: pluginPageDelegate.url
						onActiveChanged: {
							if (active)
								pluginSwipePage.contentVisited = true
						}
						onStatusChanged: {
							if (status === Loader.Error) {
								const mv = Global.mainView
								if (mv && mv._previousMainPageUrl.length > 0)
									mv._resyncUrl = mv._previousMainPageUrl
								root.pluginEnableRevision++
								if (mv)
									Qt.callLater(mv.resyncMainPageSelection)
							}
						}
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
