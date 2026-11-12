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
			if (page && !page.contentFailed && page.navigationLocation === location) {
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

				// SwipeViewPage already has required properties, so Repeater
				// does not inject model as a context property. Require it.
				required property var model

				view: root.view
				topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
				// The title may be a translation id from the plugin's own translations.
				title: model.title !== "" ? qsTrId(model.title) : model.pluginName
				iconSource: pluginPage.SwipeView.isCurrentItem && String(model.iconActive).length > 0
						? model.iconActive
						: model.icon
				url: model.url
				focusPolicy: Qt.TabFocus

				property int navigationLocation: model.location
				property bool contentVisited: false
				property bool contentFailed: false

				Loader {
					anchors.fill: parent
					// Loader is a FocusScope. This keeps it the page's focus
					// child, so key navigation stays inside the page.
					focus: true
					asynchronous: true
					active: pluginPage.SwipeView.isCurrentItem || pluginPage.contentVisited
					source: pluginPage.url
					onLoaded: {
						// A plugin Page binds focus to isCurrentPage, which is
						// false inside this wrapper. Assigning focus selects it
						// within the loader without stealing focus from outside.
						if (item) {
							item.focus = true
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
