/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "pages"

Item {
	id: root

	readonly property var _demos: ({
		"qrc:/pages/OverviewPage.qml": overviewDemo,
		"qrc:/pages/LevelsPage.qml": levelsDemo,
	})

	// Set to a specified config, or -1 to select a random config.
	function setConfigIndex(demo, configIndex, forceReload) {
		let config = configIndex === -1
				? demo.configs[Math.floor(Math.random() * demo.configs.length)]
				: demo.configs[configIndex]
		demo.configIndex = configIndex
		if (config) {
			demo.loadConfig(config)
			demoTitle.text = configIndex === -1 ? "" : (configIndex+1 + ". " + config.name || "")
		} else {
			demo.reset()
			demoTitle.text = ""
		}

		// Overview and Levels pages don't update layout if already on that page
		if (forceReload) {
			const pageIndex = indexOfPage(PageManager.navBar.currentUrl)
			PageManager.navBar.buttonClicked(PageManager.navBar.model.count - 1) // go to settings page
			PageManager.navBar.buttonClicked(pageIndex)
		}
	}

	function nextConfig() {
		const demo = _demos[PageManager.navBar.currentUrl]
		const nextIndex = demo.configIndex === demo.configs.length-1 ? 0 : demo.configIndex+1
		setConfigIndex(demo, nextIndex, true)
	}

	function previousConfig() {
		const demo = _demos[PageManager.navBar.currentUrl]
		const prevIndex = demo.configIndex <= 0 ? demo.configs.length-1 : demo.configIndex-1
		setConfigIndex(demo, prevIndex, true)
	}

	function indexOfPage(url) {
		for (let i = 0; i < PageManager.navBar.model.count; ++i) {
			if (PageManager.navBar.model.get(i).url === url) {
				return i
			}
		}
		console.warn('Cannot find url', url, 'in navBar.model')
		return -1
	}

	anchors.fill: parent
	focus: true

	Keys.onPressed: function(event) {
		switch (event.key) {
		case Qt.Key_Left:
			if (PageManager.navBar.currentUrl in root._demos) {
				previousConfig()
			}
			break
		case Qt.Key_Right:
			if (PageManager.navBar.currentUrl in root._demos) {
				nextConfig()
			}
			break
		case Qt.Key_Plus:
			if (Theme.screenSize !== Theme.SevenInch) {
				Theme.load(Theme.SevenInch, Theme.colorScheme)
			}
			break
		case Qt.Key_Minus:
			if (Theme.screenSize !== Theme.FiveInch) {
				Theme.load(Theme.FiveInch, Theme.colorScheme)
			}
			break
		case Qt.Key_C:
			if (Theme.colorScheme == Theme.Dark) {
				Theme.load(Theme.screenSize, Theme.Light)
			} else {
				Theme.load(Theme.screenSize, Theme.Dark)
			}
			break
		case Qt.Key_L:
			Language.current = (Language.current === Language.English ? Language.French : Language.English)
			break
		default:
			break
		}
	}

	Rectangle {
		id: demoTitleBackground

		width: demoTitle.width * 1.1
		height: demoTitle.height * 1.1
		color: "white"
		opacity: 0.9
		visible: demoTitleTimer.running

		Label {
			id: demoTitle
			anchors.centerIn: parent
			color: "black"
			onTextChanged: demoTitleTimer.restart()
		}

		Timer {
			id: demoTitleTimer
			interval: 3000
		}
	}

	Connections {
		target: PageManager.navBar || null
		function onCurrentUrlChanged() {
			for (let demoUrl in _demos) {
				const demo = _demos[demoUrl]
				if (PageManager.navBar.currentUrl === demoUrl) {
					if (demo.configIndex === -1) {
						setConfigIndex(demo, -1, false)
					}
					break
				}
			}
		}
	}

	OverviewPageDemo {
		id: overviewDemo

		property int configIndex: -1
	}

	LevelsPageDemo {
		id: levelsDemo

		property int configIndex: -1
	}
}
