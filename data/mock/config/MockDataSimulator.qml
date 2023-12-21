/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

QtObject {
	id: root

	property bool timersActive: !Global.splashScreenVisible
	property int deviceCount

	signal setBatteryRequested(var config)
	signal setAcInputsRequested(var config)
	signal setDcInputsRequested(var config)
	signal setEnvironmentInputsRequested(var config)
	signal setEvChargersRequested(var config)
	signal setGeneratorsRequested(var config)
	signal setSolarRequested(var config)
	signal setSystemRequested(var config)
	signal setTanksRequested(var config)
	signal deactivateSingleAlarm()

	readonly property var _configs: ({
		"qrc:/qt/qml/Victron/VenusOS/pages/BriefPage.qml": briefAndOverviewConfig,
		"qrc:/qt/qml/Victron/VenusOS/pages/OverviewPage.qml": briefAndOverviewConfig,
		"qrc:/qt/qml/Victron/VenusOS/pages/LevelsPage.qml": levelsConfig,
		"qrc:/qt/qml/Victron/VenusOS/pages/SettingsPage.qml": settingsConfig,
	})

	function setMockValue(uid, value) {
		BackendConnection.setMockValue(uid, value)
	}

	function mockValue(uid) {
		return BackendConnection.mockValue(uid)
	}

	function setConfigIndex(pageConfig, configIndex) {
		const configName = pageConfig.loadConfig(configIndex)
		if (configName) {
			pageConfig.configIndex = configIndex
			pageConfigTitle.text = configIndex+1 + ". " + configName || ""
		} else {
			pageConfigTitle.text = ""
		}
	}

	function nextConfig() {
		const pageConfig = _configs[!!Global.pageManager ? Global.pageManager.navBar.currentUrl : 0]
		const nextIndex = Utils.modulo(pageConfig.configIndex + 1, pageConfig.configCount())
		setConfigIndex(pageConfig, nextIndex)
	}

	function previousConfig() {
		const pageConfig = _configs[!!Global.pageManager ? Global.pageManager.navBar.currentUrl : 0]
		const prevIndex = Utils.modulo(pageConfig.configIndex - 1, pageConfig.configCount())
		setConfigIndex(pageConfig, prevIndex)
	}

	function keyPressed(event) {
		switch (event.key) {
		case Qt.Key_Escape:
			if (!!Global.pageManager) {
				Global.pageManager.popPage()
			}
			break
		case Qt.Key_1:
		case Qt.Key_2:
		case Qt.Key_3:
		case Qt.Key_4:
		case Qt.Key_5:
			if (!!Global.pageManager) {
				const newIndex = event.key - Qt.Key_1
				Global.pageManager.navBar.currentIndex = newIndex
				Global.pageManager.navBar.currentUrl = Global.pageManager.navBar.model.get(newIndex).url
				event.accepted = true
			}
			break
		case Qt.Key_Left:
			if (!!Global.pageManager && (Global.pageManager.navBar.currentUrl in root._configs)) {
				previousConfig()
				event.accepted = true
			}
			break
		case Qt.Key_Right:
			if (!!Global.pageManager && (Global.pageManager.navBar.currentUrl in root._configs)) {
				nextConfig()
				event.accepted = true
			}
			break
		case Qt.Key_Plus:
			if (Theme.screenSize !== Theme.SevenInch) {
				Theme.screenSize = Theme.SevenInch
				event.accepted = true
			}
			break
		case Qt.Key_Minus:
			if (Theme.screenSize !== Theme.FiveInch) {
				Theme.screenSize = Theme.FiveInch
				event.accepted = true
			}
			break
		case Qt.Key_C:
			Theme.colorScheme = Theme.colorScheme == Theme.Dark ? Theme.Light : Theme.Dark
			event.accepted = true
			break
		case Qt.Key_G:
			let oldValue
			let newValue
			if (event.modifiers & Qt.ShiftModifier) {
				newValue = root.mockValue("com.victronenergy.modem/SignalStrength") + 5
				if (newValue > 25) {
					newValue = 0
				}
				root.setMockValue("com.victronenergy.modem/SignalStrength", newValue)
			} else if (event.modifiers & Qt.ControlModifier) {
				oldValue = root.mockValue("com.victronenergy.modem/Roaming")
				root.setMockValue("com.victronenergy.modem/Roaming", !oldValue)
			} else if (event.modifiers & Qt.AltModifier) {
				oldValue = root.mockValue("com.victronenergy.modem/NetworkType")
				switch (oldValue) {
				case "NONE":
					newValue = "GSM"
					break
				case "GSM":
					newValue = "EDGE"
					break
				case "EDGE":
					newValue = "CDMA"
					break
				case "CDMA":
					newValue = "HSPAP"
					break
				case "HSPAP":
					newValue = "LTE"
					break
				case "LTE":
					newValue = "NONE"
					break
				}
				root.setMockValue("com.victronenergy.modem/NetworkType", newValue)
			} else if (event.modifiers & Qt.MetaModifier) {
				oldValue = root.mockValue("com.victronenergy.modem/SimStatus")
				root.setMockValue("com.victronenergy.modem/SimStatus", oldValue === 1000 ? 11 : 1000)
			} else {
				oldValue = root.mockValue("com.victronenergy.modem/Connected")
				root.setMockValue("com.victronenergy.modem/Connected", oldValue === 1 ? 0 : 1)
			}
			event.accepted = true
			break
		case Qt.Key_L:
			Language.current = (Language.current === Language.English ? Language.French : Language.English)
			pageConfigTitle.text = "Language: " + Language.toString(Language.current)
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
			const notifType = (event.modifiers & Qt.ShiftModifier)
				? VenusOS.Notification_Confirm
				: (event.modifiers & Qt.AltModifier)
				  ? VenusOS.Notification_Warning
				  : (event.modifiers & Qt.ControlModifier)
					? VenusOS.Notification_Alarm
					: VenusOS.Notification_Info
			notificationsConfig.showToastNotification(notifType)
			event.accepted = true
			break
		case Qt.Key_P:
			Global.dcInputs.power = 0
			Global.acInputs.generatorInput = null
			if (event.modifiers & Qt.ControlModifier) {
				Global.acInputs.power = 0
			} else if (event.modifiers & Qt.ShiftModifier) {
				Global.acInputs.power += 200
			} else {
				Global.acInputs.power -= 200
			}
			event.accepted = true
			break
		case Qt.Key_T:
			root.timersActive = !root.timersActive
			pageConfigTitle.text = "Timers on: " + root.timersActive
			event.accepted = true
			break
		case Qt.Key_U:
			Global.systemSettings.electricalQuantity.setValue(
					Global.systemSettings.electricalQuantity.value === VenusOS.Units_Watt
					? VenusOS.Units_Amp
					: VenusOS.Units_Watt)
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

			pageConfigTitle.text = "Units: "
					+ (Global.systemSettings.electricalQuantity.value === VenusOS.Units_Watt
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

	property Rectangle _configLabel: Rectangle {
		parent: !!Global.pageManager ? Global.pageManager.statusBar : null
		width: pageConfigTitle.width * 1.1
		height: pageConfigTitle.implicitHeight * 1.1
		color: "white"
		opacity: 0.9
		visible: pageConfigTitleTimer.running

		Label {
			id: pageConfigTitle
			anchors.centerIn: parent
			color: "black"
			onTextChanged: pageConfigTitleTimer.restart()
		}

		Timer {
			id: pageConfigTitleTimer
			interval: 3000
		}
	}

	property BriefAndOverviewPageConfig briefAndOverviewConfig: BriefAndOverviewPageConfig {
		property int configIndex: -1
	}

	property LevelsPageConfig levelsConfig: LevelsPageConfig {
		property int configIndex: -1
	}

	property NotificationsPageConfig notificationsConfig: NotificationsPageConfig {
		id: notificationsConfig
	}

	property SettingsPageConfig settingsConfig: SettingsPageConfig {
		property int configIndex: -1
	}

	property Connections _globalConn: Connections {
		target: Global
		function onKeyPressed(event) {
			root.keyPressed(event)
		}
	}
}
