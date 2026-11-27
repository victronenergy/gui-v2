import QtQuick
import QtQml.Models
import Victron.VenusOS
import Victron.Boat as Boat

ObjectModel {
	id: root

	required property SwipeView view

	// Not a binding to SwipeView.contentChildren: replacing that list resets
	// currentIndex to 0. setSwipeViewPages() inserts or removes one row instead.
	property list<SwipeViewPage> pages
	property bool _pagesReady: false
	property bool _applyingPages: false

	// The ordered list has been written to the view.
	signal pagesApplied()

	function indexOfPage(pageList, page) {
		for (let i = 0; i < pageList.length; ++i) {
			if (pageList[i] === page) {
				return i
			}
		}
		return -1
	}

	// Repeater order is the model order: location, then plugin name, then URL.
	function pluginPages(location) {
		const found = []
		for (let i = 0; i < pluginNavRepeater.count; ++i) {
			const page = pluginNavRepeater.itemAt(i)
			if (page && !page.contentFailed && page.location === location) {
				found.push(page)
			}
		}
		return found
	}

	function desiredPages() {
		const pageList = []
		pageList.push(...pluginPages(GuiPluginLoader.NavigationPageLocation_BeforeBoat))
		if (showBoatPage) {
			pageList.push(boatPageLoader.item)
		}
		pageList.push(...pluginPages(GuiPluginLoader.NavigationPageLocation_BeforeBrief))
		pageList.push(briefPage)
		pageList.push(...pluginPages(GuiPluginLoader.NavigationPageLocation_BeforeOverview))
		pageList.push(overviewPage)
		pageList.push(...pluginPages(GuiPluginLoader.NavigationPageLocation_BeforeLevels))
		if (showLevelsPage) {
			pageList.push(levelsPageLoader.item)
		}
		pageList.push(...pluginPages(GuiPluginLoader.NavigationPageLocation_BeforeNotifications))
		pageList.push(notificationsPage)
		pageList.push(...pluginPages(GuiPluginLoader.NavigationPageLocation_BeforeSettings))
		pageList.push(settingsPage)
		pageList.push(...pluginPages(GuiPluginLoader.NavigationPageLocation_AfterSettings))
		return pageList
	}

	function setSwipeViewPages() {
		if (!_pagesReady || _applyingPages) {
			return
		}
		const desired = desiredPages()
		const swipeView = view
		let pagesChanged = pages.length !== desired.length
		for (let i = 0; !pagesChanged && i < desired.length; ++i) {
			pagesChanged = pages[i] !== desired[i]
		}
		let viewChanged = !swipeView
		if (swipeView) {
			viewChanged = swipeView.count !== desired.length
			for (let i = 0; !viewChanged && i < desired.length; ++i) {
				viewChanged = swipeView.itemAt(i) !== desired[i]
			}
		}
		if (!pagesChanged && !viewChanged) {
			return
		}
		_applyingPages = true
		if (pagesChanged) {
			pages = desired
		}
		if (swipeView) {
			for (let i = swipeView.count - 1; i >= 0; --i) {
				if (indexOfPage(desired, swipeView.itemAt(i)) < 0) {
					swipeView.removeItem(swipeView.itemAt(i))
				}
			}
			for (let i = 0; i < desired.length; ++i) {
				let found = -1
				for (let j = 0; j < swipeView.count; ++j) {
					if (swipeView.itemAt(j) === desired[i]) {
						found = j
						break
					}
				}
				if (found < 0) {
					swipeView.insertItem(i, desired[i])
				} else if (found !== i) {
					swipeView.moveItem(found, i)
				}
			}
			// So that the view's current index is final when pagesApplied is emitted.
			swipeView.forceLayout()
		}
		_applyingPages = false
		pagesApplied()
	}

	readonly property bool showLevelsPage: levelsPageLoader.active && !!levelsPageLoader.item
	readonly property bool showBoatPage: boatPageLoader.active && !!boatPageLoader.item
	onShowLevelsPageChanged: {
		if (_pagesReady) {
			setSwipeViewPages()
		}
	}
	onShowBoatPageChanged: {
		if (_pagesReady) {
			setSwipeViewPages()
		}
	}
	readonly property int tankCount: Services.tanks.totalTankCount
	readonly property int environmentInputCount: Services.environment.model.count

	// Wait for Boat/Levels items and plugin page wrappers, not plugin content.
	// A hanging plugin must not block startup.
	readonly property bool completed: _completed
		&& (!boatPageLoader.active || showBoatPage)
		&& (!levelsPageLoader.active || showLevelsPage)
		&& pluginNavRepeater.count === pluginNavIntegrations.count

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

	// Each navigation integration is one SwipeViewPage. The repeater lives in
	// a hidden item so these pages are not ObjectModel children.
	// setSwipeViewPages() inserts them at their named location.
	GuiPluginIntegrationModel {
		id: pluginNavIntegrations
		type: GuiPluginLoader.NavigationPage
	}

	Item {
		visible: false
		width: 0
		height: 0

		Repeater {
			id: pluginNavRepeater
			model: pluginNavIntegrations
			delegate: SwipeViewPage {
				id: pluginPage

				required property string sourceTitle
				required property string pluginName
				required property url icon
				required property url iconActive
				required property int location

				property bool contentVisited: false
				property bool contentFailed: false

				// The compiler title may be a translation id from the plugin's own translations.
				title: sourceTitle !== "" ? qsTrId(sourceTitle) : pluginName
				view: root.view
				iconSource: pluginPage.SwipeView.isCurrentItem && String(iconActive).length > 0
						? iconActive
						: icon
				// The nav bar reads this page's focusPolicy. The loaded PluginPage cannot
				// set that, so this copies the loaded page's own focusPolicy.
				focusPolicy: contentLoader.item?.focusPolicy ?? Qt.NoFocus

				// A navigation page that is not a PluginPage is not shown. The messages
				// are the same as for a pushed plugin page.
				function loadedPageIsRejected(item) {
					const pageUrl = url
					if (item && item.__is_venus_gui_page__) {
						console.warn("Aborted attempt to push a plugin page whose base type is a Page: " + pageUrl
								+ ". The base type of a plugin page must be a PluginPage from Victron.GuiPlugins.")
						return true
					}
					if (!(item instanceof Item)) {
						console.warn("Aborted attempt to push a plugin page whose base type is not an item: " + pageUrl
								+ ". The base type of a plugin page must be a PluginPage from Victron.GuiPlugins.")
						return true
					}
					if (item.__is_plugin_page__ !== true) {
						console.warn("Aborted attempt to push a plugin page whose base type is not a PluginPage: " + pageUrl
								+ ". The base type of a plugin page must be a PluginPage from Victron.GuiPlugins.")
						return true
					}
					return false
				}

				Loader {
					id: contentLoader
					anchors.fill: parent
					focus: true
					asynchronous: true
					active: pluginPage.SwipeView.isCurrentItem || pluginPage.contentVisited
					source: pluginPage.url
					onLoaded: {
						if (pluginPage.loadedPageIsRejected(item)) {
							pluginPage.contentFailed = true
							source = ""
							root.setSwipeViewPages()
						}
					}
					onActiveChanged: {
						if (active) {
							pluginPage.contentVisited = true
						}
					}
					onStatusChanged: {
						if (status === Loader.Error) {
							pluginPage.contentFailed = true
							root.setSwipeViewPages()
						}
					}
				}
			}
			onItemAdded: {
				if (root._pagesReady) {
					root.setSwipeViewPages()
				}
			}
			onItemRemoved: {
				if (root._pagesReady) {
					root.setSwipeViewPages()
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

	Component.onCompleted: {
		_pagesReady = true
		setSwipeViewPages()
		Qt.callLater(function() { root._completed = true })
	}

	onViewChanged: {
		if (_pagesReady) {
			setSwipeViewPages()
		}
	}
}
