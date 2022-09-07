/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property bool timersActive: !Global.splashScreenVisible

	signal setBatteryRequested(var config)
	signal setAcInputsRequested(var config)
	signal setDcInputsRequested(var config)
	signal setEnvironmentInputsRequested(var config)
	signal setSolarChargersRequested(var config)
	signal setSystemRequested(var config)
	signal setTanksRequested(var config)
	signal deactivateSingleAlarm()

	readonly property var _demoConfigConfigs: ({
		"qrc:/pages/BriefPage.qml": briefAndOverviewConfig,
		"qrc:/pages/OverviewPage.qml": briefAndOverviewConfig,
		"qrc:/pages/LevelsPage.qml": levelsConfig,
	})

	function setConfigIndex(demoConfig, configIndex) {
		let config = demoConfig.configs[configIndex]
		demoConfig.configIndex = configIndex
		if (config) {
			demoConfig.loadConfig(config)
			demoConfigTitle.text = configIndex+1 + ". " + config.name || ""
		} else {
			demoConfigTitle.text = ""
		}
	}

	function nextConfig() {
		const demoConfig = _demoConfigConfigs[Global.pageManager.navBar.currentUrl]
		const nextIndex = demoConfig.configIndex === demoConfig.configs.length-1 ? 0 : demoConfig.configIndex+1
		setConfigIndex(demoConfig, nextIndex)
	}

	function previousConfig() {
		const demoConfig = _demoConfigConfigs[Global.pageManager.navBar.currentUrl]
		const prevIndex = demoConfig.configIndex <= 0 ? demoConfig.configs.length-1 : demoConfig.configIndex-1
		setConfigIndex(demoConfig, prevIndex)
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
		case Qt.Key_1:
		case Qt.Key_2:
		case Qt.Key_3:
		case Qt.Key_4:
		case Qt.Key_5:
			Global.pageManager.navBar.currentIndex = event.key - Qt.Key_1
			event.accepted = true
			break
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
		case Qt.Key_L:
			Language.current = (Language.current === Language.English ? Language.French : Language.English)
			demoConfigTitle.text = "Language: " + Language.toString(Language.current)
			event.accepted = true
			break
		case Qt.Key_N:
			if (event.modifiers & Qt.ShiftModifier) {
				Global.notifications.activeModel.deactivateSingleAlarm()
			} else {
				var n = notificationsConfig.getRandomAlarm()
				Global.notifications.activeModel.insertByDate(n.acknowledged, n.active, n.type, n.deviceName, n.dateTime, n.description)
			}
			event.accepted = true
			break
		case Qt.Key_O:
			notificationsConfig.showToastNotification()
			event.accepted = true
			break
		case Qt.Key_P:
			Global.dialogManager.showWarning(notificationsConfig.warningNotificationTitle, notificationsConfig.warningNotificationDescription)
			event.accepted = true
			break
		case Qt.Key_T:
			root.timersActive = !root.timersActive
			demoConfigTitle.text = "Timers on: " + root.timersActive
			event.accepted = true
			break
		case Qt.Key_U:
			Global.systemSettings.energyUnit.setValue(
					Global.systemSettings.energyUnit.value === VenusOS.Units_Energy_Watt
					? VenusOS.Units_Energy_Amp
					: VenusOS.Units_Energy_Watt)
			Global.systemSettings.temperatureUnit.setValue(
					Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Celsius
					? VenusOS.Units_Temperature_Fahrenheit
					: VenusOS.Units_Temperature_Celsius)
			Global.systemSettings.volumeUnit.setValue(
					Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_CubicMeter
					? VenusOS.Units_Volume_Liter
					: Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_Liter
					  ? VenusOS.Units_Volume_GallonUS
					  : Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_GallonUS
						? VenusOS.Units_Volume_GallonImperial
						: VenusOS.Units_Volume_CubicMeter)

			demoConfigTitle.text = "Units: "
					+ (Global.systemSettings.energyUnit.value === VenusOS.Units_Energy_Watt
					   ? "Watts"
					   : "Amps") + " | "
					+ (Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Celsius
					   ? "Celsius"
					   : "Fahrenheit") + " | "
					+ (Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_CubicMeter
					   ? "Cubic meters"
					   : Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_Liter
						 ? "Liters"
						 : Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_GallonUS
						   ? "Gallons (US)"
						   : "Gallons (Imperial)")
			event.accepted = true
			break
		case Qt.Key_Space:
			Global.allPagesLoaded = true
			Global.splashScreenVisible = false
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

	BriefAndOverviewPageConfig {
		id: briefAndOverviewConfig

		property int configIndex: -1
	}

	LevelsPageConfig {
		id: levelsConfig

		property int configIndex: -1
	}

	NotificationsPageConfig {
		id: notificationsConfig
	}
}
