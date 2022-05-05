/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property bool timersActive: true

	signal setBatteryRequested(var config)
	signal setAcInputsRequested(var config)
	signal setDcInputsRequested(var config)
	signal setEnvironmentInputsRequested(var config)
	signal setSolarChargersRequested(var config)
	signal setSystemRequested(var config)
	signal setTanksRequested(var config)

	readonly property var _demoConfigConfigs: ({
		"qrc:/pages/OverviewPage.qml": overviewConfig,
		"qrc:/pages/LevelsPage.qml": levelsConfig,
	})

	function setConfigIndex(demoConfig, configIndex, forceReload) {
		let config = demoConfig.configs[configIndex]
		demoConfig.configIndex = configIndex
		if (config) {
			demoConfig.loadConfig(config)
			demoConfigTitle.text = configIndex+1 + ". " + config.name || ""
		} else {
			demoConfigTitle.text = ""
		}

		// Overview and Levels pages sometimes don't update layout if already on that page
		if (forceReload) {
			const pageIndex = indexOfPage(Global.pageManager.navBar.currentUrl)
			Global.pageManager.navBar.buttonClicked(Global.pageManager.navBar.model.count - 1) // go to settings page
			Global.pageManager.navBar.buttonClicked(pageIndex)
		}
	}

	function nextConfig() {
		const demoConfig = _demoConfigConfigs[Global.pageManager.navBar.currentUrl]
		const nextIndex = demoConfig.configIndex === demoConfig.configs.length-1 ? 0 : demoConfig.configIndex+1
		setConfigIndex(demoConfig, nextIndex, true)
	}

	function previousConfig() {
		const demoConfig = _demoConfigConfigs[Global.pageManager.navBar.currentUrl]
		const prevIndex = demoConfig.configIndex <= 0 ? demoConfig.configs.length-1 : demoConfig.configIndex-1
		setConfigIndex(demoConfig, prevIndex, true)
	}

	function indexOfPage(url) {
		for (let i = 0; i < Global.pageManager.navBar.model.count; ++i) {
			if (Global.pageManager.navBar.model.get(i).url === url) {
				return i
			}
		}
		console.warn('Cannot find url', url, 'in navBar.model')
		return -1
	}

	function keyPressed(event) {
		switch (event.key) {
		case Qt.Key_Left:
			if (Global.pageManager.navBar.currentUrl in root._demoConfigConfigs) {
				previousConfig()
				event.accepted = true
			}
			break
		case Qt.Key_Right:
			if (Global.pageManager.navBar.currentUrl in root._demoConfigConfigs) {
				nextConfig()
				event.accepted = true
			}
			break
		case Qt.Key_Plus:
			if (Theme.screenSize !== Theme.SevenInch) {
				Theme.load(Theme.SevenInch, Theme.colorScheme)
				event.accepted = true
			}
			break
		case Qt.Key_Minus:
			if (Theme.screenSize !== Theme.FiveInch) {
				Theme.load(Theme.FiveInch, Theme.colorScheme)
				event.accepted = true
			}
			break
		case Qt.Key_C:
			if (Theme.colorScheme == Theme.Dark) {
				Theme.load(Theme.screenSize, Theme.Light)
			} else {
				Theme.load(Theme.screenSize, Theme.Dark)
			}
			event.accepted = true
			break
		case Qt.Key_D:
			Global.notifications.deactivate()
			event.accepted = true
			break
		case Qt.Key_L:
			Language.current = (Language.current === Language.English ? Language.French : Language.English)
			demoConfigTitle.text = "Language: " + Language.toString(Language.current)
			event.accepted = true
			break
		case Qt.Key_T:
			root.timersActive = !root.timersActive
			demoConfigTitle.text = "Timers on: " + root.timersActive
			event.accepted = true
			break
		default:
			break
		}
	}

	anchors.fill: parent

	Rectangle {
		id: demoConfigTitleBackground

		width: demoConfigTitle.width * 1.1
		height: demoConfigTitle.height * 1.1
		color: "white"
		opacity: 0.9
		visible: demoConfigTitleTimer.running

		Label {
			id: demoConfigTitle
			anchors.centerIn: parent
			color: "black"
			onTextChanged: demoConfigTitleTimer.restart()
		}

		Timer {
			id: demoConfigTitleTimer
			interval: 3000
		}
	}

	OverviewPageConfig {
		id: overviewConfig

		property int configIndex: -1
	}

	LevelsPageConfig {
		id: levelsConfig

		property int configIndex: -1
	}
}
