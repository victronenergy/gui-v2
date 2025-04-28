/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property bool timersActive: !Global.splashScreenVisible
	property int deviceCount
	property bool levelsEnabled: true
	property bool animationEnabled: true

	signal setBatteryRequested(config : var)
	signal setAcInputsRequested(config : var)
	signal setDcInputsRequested(config : var)
	signal setEnvironmentInputsRequested(config : var)
	signal setEvChargersRequested(config : var)
	signal setGeneratorsRequested(config : var)
	signal setGpsRequested(config : var)
	signal setSolarRequested(config : var)
	signal setSystemRequested(config : var)
	signal setTanksRequested(config : var)
	signal setShowInputLoadsRequested(split: bool)
	signal addDummyNotification(isAlarm : bool)

	readonly property var _configs: ({
		"qrc:/qt/qml/Victron/VenusOS/pages/BriefPage.qml": briefAndOverviewConfig,
		"qrc:/qt/qml/Victron/VenusOS/pages/OverviewPage.qml": briefAndOverviewConfig,
		"qrc:/qt/qml/Victron/VenusOS/pages/LevelsPage.qml": levelsConfig,
		"qrc:/qt/qml/Victron/BoatPageComponents/BoatPage.qml": boatPageConfig,
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
		const pageConfig = _configs[currentNavBarUrl()]
		const nextIndex = Utils.modulo(pageConfig.configIndex + 1, pageConfig.configCount())
		setConfigIndex(pageConfig, nextIndex)
	}

	function previousConfig() {
		const pageConfig = _configs[currentNavBarUrl()]
		if (pageConfig.configIndex === -1) pageConfig.configIndex = 0
		const prevIndex = Utils.modulo(pageConfig.configIndex - 1, pageConfig.configCount())
		setConfigIndex(pageConfig, prevIndex)
	}

	function currentNavBarUrl() {
		const data = Global.pageManager.navBar.model.get(Global.pageManager.navBar.currentIndex)
		return data.url
	}

	function keyPressed(key, modifiers) {
		if (Global.main.activeFocusItem?.hasOwnProperty("placeholderText")) {
			// Very simplistic way of guessing whether the key was pressed inside a text input, to
			// avoid triggering events in this case.
			return
		}
		switch (key) {
		case Qt.Key_1:
		case Qt.Key_2:
		case Qt.Key_3:
		case Qt.Key_4:
		case Qt.Key_5:
		case Qt.Key_6:
			if (!!Global.pageManager) {
				const newIndex = key - Qt.Key_1
				Global.pageManager.navBar.setCurrentIndex(newIndex)
			}
			break
		case Qt.Key_Comma:
			if (!!Global.pageManager && (currentNavBarUrl() in root._configs)) {
				previousConfig()
			}
			break
		case Qt.Key_Period:
			if (!!Global.pageManager && (currentNavBarUrl() in root._configs)) {
				nextConfig()
			}
			break
		case Qt.Key_Plus:
			if (Theme.screenSize !== Theme.SevenInch) {
				Theme.screenSize = Theme.SevenInch
			}
			break
		case Qt.Key_Minus:
			if (Theme.screenSize !== Theme.FiveInch) {
				Theme.screenSize = Theme.FiveInch
			}
			break
		case Qt.Key_A:
			root.animationEnabled = !root.animationEnabled
			break
		case Qt.Key_B:
			root.setMockValue(Global.systemSettings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/Enabled",
				root.mockValue(Global.systemSettings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/Enabled") == 0 ? 1 : 0)
			event.accepted = true
			break
		case Qt.Key_C:
			Theme.colorScheme = Theme.colorScheme == Theme.Dark ? Theme.Light : Theme.Dark
			break
		case Qt.Key_D:
			Global.pageManager.pushPage(Global.pageManager.pushPage("/pages/settings/debug/PageDebugVeQItems.qml"))
			break
		case Qt.Key_E:
			Global.isGxDevice = !Global.isGxDevice
			break
		case Qt.Key_F:
			root.setMockValue(Global.system.serviceUid + "/Ac/ActiveIn/FeedbackEnabled", Global.system.feedbackEnabled ? 0 : 1)
			break
		case Qt.Key_G:
			let oldValue
			let newValue
			if (modifiers & Qt.ShiftModifier) {
				newValue = root.mockValue("com.victronenergy.modem/SignalStrength") + 5
				if (newValue > 25) {
					newValue = 0
				}
				root.setMockValue("com.victronenergy.modem/SignalStrength", newValue)
			} else if (modifiers & Qt.ControlModifier) {
				oldValue = root.mockValue("com.victronenergy.modem/Roaming")
				root.setMockValue("com.victronenergy.modem/Roaming", !oldValue)
			} else if (modifiers & Qt.AltModifier) {
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
			} else if (modifiers & Qt.MetaModifier) {
				oldValue = root.mockValue("com.victronenergy.modem/SimStatus")
				root.setMockValue("com.victronenergy.modem/SimStatus", oldValue === 1000 ? 11 : 1000)
			} else {
				oldValue = root.mockValue("com.victronenergy.modem/Connected")
				root.setMockValue("com.victronenergy.modem/Connected", oldValue === 1 ? 0 : 1)
			}
			break
		case Qt.Key_L:
			Language.setCurrentLanguage((Language.current === Language.English ? Language.French : Language.English))
			pageConfigTitle.text = "Language: " + Language.toString(Language.current)
			break
		case Qt.Key_N:
			if (modifiers & Qt.ShiftModifier) {
				root.addDummyNotification(true)
			} else {
				root.addDummyNotification(false)
			}
			break
		case Qt.Key_O:
			const notifType = (modifiers & Qt.ShiftModifier)
				? VenusOS.Notification_Warning
				: (modifiers & Qt.ControlModifier)
				  ? VenusOS.Notification_Alarm
				  : VenusOS.Notification_Info
			notificationsConfig.showToastNotification(notifType)
			break
		case Qt.Key_P:
		{
			const phases = Global.acInputs.highlightedInput.phases
			for (let i = 0; i < phases.count; ++i) {
				const phaseCurrent = phases.get(i).current
				const phasePower = phases.get(i).power
				if (modifiers & Qt.ControlModifier) {
					phases.setValue(i, PhaseModel.CurrentRole, 0)
					phases.setValue(i, PhaseModel.PowerRole, 0)
				} else if (modifiers & Qt.ShiftModifier) {
					phases.setValue(i, PhaseModel.CurrentRole, phaseCurrent + 5)
					phases.setValue(i, PhaseModel.PowerRole, phasePower + 100)
				} else {
					phases.setValue(i, PhaseModel.CurrentRole, phaseCurrent - 5)
					phases.setValue(i, PhaseModel.PowerRole, phasePower - 100)
				}
			}
			break
		}
		case Qt.Key_Q:
			root.setShowInputLoadsRequested(!Global.system.showInputLoads)
			break
		case Qt.Key_S:
		{
			if (modifiers & Qt.ShiftModifier) {
				var g = Global.generators.model.firstObject
				g._runningBy.setValue(g._runningBy.value + 1)
				break
			}
			if (modifiers & Qt.ControlModifier) {
				var g = Global.generators.model.firstObject
				g._runningBy.setValue(g._runningBy.value - 1)
				break
			}

			Global.system.load._l2L1OutSummed.setValue(!!Global.system.load._l2L1OutSummed.value ? 0 : 1)
			break
		}
		case Qt.Key_T:
			if (modifiers & Qt.ShiftModifier) {
				var g = Global.generators.model.firstObject
				g._state.setValue(g._state.value + 1)
				break
			}
			if (modifiers & Qt.ControlModifier) {
				var g = Global.generators.model.firstObject
				g._state.setValue(g._state.value - 1)
				break
			}
			root.timersActive = !root.timersActive
			pageConfigTitle.text = "Timers on: " + root.timersActive
			break
		case Qt.Key_U:
			// Change the unit display of the Brief view center gauges
			if (modifiers & Qt.ControlModifier) {
				const v = root.mockValue(Global.systemSettings.serviceUid + "/Settings/Gui/BriefView/Unit")
				let newBriefUnit = ""
				if (v === VenusOS.BriefView_Unit_None) {
					newBriefUnit = VenusOS.BriefView_Unit_Absolute
				} else if (v === VenusOS.BriefView_Unit_Absolute) {
					newBriefUnit = VenusOS.BriefView_Unit_Percentage
				} else {
					newBriefUnit = VenusOS.BriefView_Unit_None
				}
				root.setMockValue(Global.systemSettings.serviceUid + "/Settings/Gui/BriefView/Unit", newBriefUnit)
				return
			}

			// Change the system unit
			Global.systemSettings.setElectricalQuantity(
					Global.systemSettings.electricalQuantity === VenusOS.Units_Watt
					? VenusOS.Units_Amp
					: VenusOS.Units_Watt)
			Global.systemSettings.setTemperatureUnit(
					Global.systemSettings.temperatureUnit === VenusOS.Units_Temperature_Celsius
					? VenusOS.Units_Temperature_Fahrenheit
					: VenusOS.Units_Temperature_Celsius)
			Global.systemSettings.setVolumeUnit(
					Global.systemSettings.volumeUnit === VenusOS.Units_Volume_CubicMeter
					? VenusOS.Units_Volume_Liter
					: Global.systemSettings.volumeUnit === VenusOS.Units_Volume_Liter
					  ? VenusOS.Units_Volume_GallonUS
					  : Global.systemSettings.volumeUnit === VenusOS.Units_Volume_GallonUS
						? VenusOS.Units_Volume_GallonImperial
						: VenusOS.Units_Volume_CubicMeter)

			pageConfigTitle.text = "Units: "
					+ (Global.systemSettings.electricalQuantity === VenusOS.Units_Watt
					   ? "Watts"
					   : "Amps") + " | "
					+ (Global.systemSettings.temperatureUnit === VenusOS.Units_Temperature_Celsius
					   ? "Celsius"
					   : "Fahrenheit") + " | "
					+ (Global.systemSettings.volumeUnit === VenusOS.Units_Volume_CubicMeter
					   ? "Cubic meters"
					   : Global.systemSettings.volumeUnit === VenusOS.Units_Volume_Liter
						 ? "Liters"
						 : Global.systemSettings.volumeUnit === VenusOS.Units_Volume_GallonUS
						   ? "Gallons (US)"
						   : "Gallons (Imperial)")
			break
		case Qt.Key_V:
			levelsEnabled = !levelsEnabled
			break
		case Qt.Key_W:
			Global.mainView.loadStartPage()
			break
		case Qt.Key_Space:
			Global.splashScreenVisible = false
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

	property BoatPageConfig boatPageConfig: BoatPageConfig {
		property int configIndex: -1
	}

	property KeyEventFilter keyEventFilter: KeyEventFilter {
		window: Global.main
		onKeyPressed: (key, modifiers) => {
			root.keyPressed(key, modifiers)
		}
	}

	property Binding _pageAnimationsBinding: Binding {
		when: !animationEnabled
		target: !!Global.mainView ? Global.mainView : null
		property: "allowPageAnimations"
		value: false
	}

	property Binding _statusBarAnimationsBinding: Binding {
		when: !animationEnabled
		target: !!Global.pageManager ? Global.pageManager.statusBar : null
		property: "animationEnabled"
		value: false
	}
}
