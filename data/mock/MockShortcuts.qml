/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Mock

QtObject {
	id: root

	property bool useShortNotificationText: false

	readonly property var _configs: ({
		"qrc:/qt/qml/Victron/VenusOS/pages/BriefPage.qml": briefAndOverviewConfig,
		"qrc:/qt/qml/Victron/VenusOS/pages/OverviewPage.qml": briefAndOverviewConfig,
		"qrc:/qt/qml/Victron/VenusOS/pages/LevelsPage.qml": levelsConfig,
		"qrc:/qt/qml/Victron/Boat/BoatPage.qml": boatPageConfig,
	})

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
		return Global.pageManager.navBar.pages[Global.pageManager.navBar.currentIndex].url
	}

	function setShowInputLoads(showInputLoads) {
		MockManager.setValue(Services.system.serviceUid + "/Ac/Grid/DeviceType", showInputLoads ? 0 : undefined)
		MockManager.setValue(Services.settings.serviceUid + "/Settings/CGwacs/RunWithoutGridMeter", showInputLoads ? 0 : 1)
		MockManager.setValue(Services.settings.serviceUid + "/Settings/SystemSetup/HasAcOutSystem", showInputLoads ? 1 : 0)
	}

	function removeTanksAndTemperatures() {
		while (tanksAndTemperatureModel.count > 0) {
			const serviceUid = tanksAndTemperatureModel.deviceAt(tanksAndTemperatureModel.count - 1).serviceUid
			MockManager.setValue(serviceUid + "/DeviceInstance", -1)
			MockManager.removeValue(serviceUid)
		}
	}

	function showToastNotification(notifType) {
		//% "Mollitia quis est quas deleniti quibusdam explicabo quasi."
		const shortText = qsTrId("notifications_toast_short_text")
		//% "Mollitia quis est quas deleniti quibusdam explicabo quasi. Voluptatem qui quia et consequuntur."
		const longText = qsTrId("notifications_toast_long_text")

		if (notifType > VenusOS.Notification_Info) {
			useShortNotificationText = !useShortNotificationText
		}
		Global.showToastNotification(notifType, useShortNotificationText ? shortText : longText)
	}

	function keyPressed(key, modifiers) {
		let i
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
			MockManager.setValue(Services.settings.serviceUid + "/Settings/Gui2/UIAnimations", Services.settings.animationEnabled ? 0 : 1)
			break
		case Qt.Key_B:
			MockManager.setValue(Services.settings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/Enabled",
				MockManager.value(Services.settings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/Enabled") == 0 ? 1 : 0)
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
			MockManager.setValue(Services.system.serviceUid + "/Ac/ActiveIn/FeedbackEnabled", Services.system.feedbackEnabled ? 0 : 1)
			break
		case Qt.Key_G:
			let oldValue
			let newValue
			if (modifiers & Qt.ShiftModifier) {
				newValue = MockManager.value("com.victronenergy.modem/SignalStrength") + 5
				if (newValue > 25) {
					newValue = 0
				}
				MockManager.setValue("com.victronenergy.modem/SignalStrength", newValue)
			} else if (modifiers & Qt.ControlModifier) {
				oldValue = MockManager.value("com.victronenergy.modem/Roaming")
				MockManager.setValue("com.victronenergy.modem/Roaming", !oldValue)
			} else if (modifiers & Qt.AltModifier) {
				oldValue = MockManager.value("com.victronenergy.modem/NetworkType")
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
				MockManager.setValue("com.victronenergy.modem/NetworkType", newValue)
			} else if (modifiers & Qt.MetaModifier) {
				oldValue = MockManager.value("com.victronenergy.modem/SimStatus")
				MockManager.setValue("com.victronenergy.modem/SimStatus", oldValue === 1000 ? 11 : 1000)
			} else {
				oldValue = MockManager.value("com.victronenergy.modem/Connected")
				MockManager.setValue("com.victronenergy.modem/Connected", oldValue === 1 ? 0 : 1)
			}
			break
		case Qt.Key_H:
			const hasAcLoads = MockManager.value(Services.system.serviceUid + "/Ac/HasAcLoads")
			MockManager.setValue(Services.system.serviceUid + "/Ac/HasAcLoads", hasAcLoads === 1 ? 0 : 1)
			break
		case Qt.Key_L:
			Language.setCurrentLanguage((Language.current === Language.English ? Language.French : Language.English))
			pageConfigTitle.text = "Language: " + Language.toString(Language.current)
			break
		case Qt.Key_M:
			for (i = 0; i < Services.dcInputs.model.count; ++i) {
				const dcMeter = Services.dcInputs.model.deviceAt(i)
				const monitorMode = MockManager.value(dcMeter.serviceUid + "/Settings/MonitorMode")
				if (monitorMode !== undefined) {
					const newMonitorMode = monitorMode + ((modifiers & Qt.ShiftModifier) ? 1 : -1)
					pageConfigTitle.text = "Monitor mode: " + newMonitorMode
					MockManager.setValue(dcMeter.serviceUid + "/Settings/MonitorMode", newMonitorMode)
					break
				}
			}
			break
		case Qt.Key_N:
			if (modifiers & Qt.ShiftModifier && modifiers & Qt.ControlModifier) {
				showToastNotification(VenusOS.Notification_Alarm)
			} else if (modifiers & Qt.ShiftModifier && modifiers & Qt.AltModifier) {
				showToastNotification(VenusOS.Notification_Warning)
			} else if (modifiers & Qt.ShiftModifier) {
				showToastNotification(VenusOS.Notification_Info)
			} else if (modifiers & Qt.AltModifier) {
				MockManager.addDummyNotification(false)
			} else {
				MockManager.addDummyNotification(true)
			}
			break
		case Qt.Key_O:
			// change orientation
			if (Theme.screenSize !== Theme.Portrait) {
				Theme.screenSize = Theme.Portrait
			} else {
				Theme.screenSize = Theme.FiveInch
			}
			break
		case Qt.Key_P:
		{
			const phases = Services.acInputs.highlightedInput.phases
			for (i = 0; i < phases.count; ++i) {
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
			root.setShowInputLoads(!Services.system.showInputLoads)
			break
		case Qt.Key_S:
		{
			if (modifiers & Qt.ShiftModifier) {
				var g = Services.generators.model.firstObject
				g._runningBy.setValue(g._runningBy.value + 1)
				break
			}
			if (modifiers & Qt.ControlModifier) {
				var g = Services.generators.model.firstObject
				g._runningBy.setValue(g._runningBy.value - 1)
				break
			}

			Services.system.load._l2L1OutSummed.setValue(!!Services.system.load._l2L1OutSummed.value ? 0 : 1)
			break
		}
		case Qt.Key_T:
			if (modifiers & Qt.ShiftModifier) {
				var g = Services.generators.model.firstObject
				g._state.setValue(g._state.value + 1)
				break
			}
			if (modifiers & Qt.ControlModifier) {
				var g = Services.generators.model.firstObject
				g._state.setValue(g._state.value - 1)
				break
			}
			MockManager.timersActive = !MockManager.timersActive
			pageConfigTitle.text = "Timers on: " + MockManager.timersActive
			break
		case Qt.Key_U:
			// Change the unit display of the Brief view center gauges
			if (modifiers & Qt.ControlModifier) {
				const v = MockManager.value(Services.settings.serviceUid + "/Settings/Gui/BriefView/Unit")
				let newBriefUnit = ""
				if (v === VenusOS.BriefView_Unit_None) {
					newBriefUnit = VenusOS.BriefView_Unit_Absolute
				} else if (v === VenusOS.BriefView_Unit_Absolute) {
					newBriefUnit = VenusOS.BriefView_Unit_Percentage
				} else {
					newBriefUnit = VenusOS.BriefView_Unit_None
				}
				MockManager.setValue(Services.settings.serviceUid + "/Settings/Gui/BriefView/Unit", newBriefUnit)
				return
			}

			// Change the system unit
			Services.settings.setElectricalPowerDisplay(
					Services.settings.electricalPowerDisplay === VenusOS.ElectricalPowerDisplay_PreferWatts
					? VenusOS.ElectricalPowerDisplay_PreferAmps
					: Services.settings.electricalPowerDisplay === VenusOS.ElectricalPowerDisplay_PreferAmps
						? VenusOS.ElectricalPowerDisplay_Mixed
						: VenusOS.ElectricalPowerDisplay_PreferWatts)
			Services.settings.setTemperatureUnit(
					Services.settings.temperatureUnit === VenusOS.Units_Temperature_Celsius
					? VenusOS.Units_Temperature_Fahrenheit
					: VenusOS.Units_Temperature_Celsius)
			Services.settings.setVolumeUnit(
					Services.settings.volumeUnit === VenusOS.Units_Volume_CubicMetre
					? VenusOS.Units_Volume_Litre
					: Services.settings.volumeUnit === VenusOS.Units_Volume_Litre
					  ? VenusOS.Units_Volume_GallonUS
					  : Services.settings.volumeUnit === VenusOS.Units_Volume_GallonUS
						? VenusOS.Units_Volume_GallonImperial
						: VenusOS.Units_Volume_CubicMetre)
			Services.settings.setSpeedUnit(
					Services.settings.speedUnit === VenusOS.Units_Speed_KilometresPerHour
					? VenusOS.Units_Speed_MetresPerSecond
					: Services.settings.speedUnit === VenusOS.Units_Speed_MetresPerSecond
					  ? VenusOS.Units_Speed_Knots
					  : Services.settings.speedUnit === VenusOS.Units_Speed_Knots
						? VenusOS.Units_Speed_MilesPerHour
						: VenusOS.Units_Speed_KilometresPerHour)

			pageConfigTitle.text = "Units: "
					+ (Services.settings.electricalPowerDisplay === VenusOS.ElectricalPowerDisplay_PreferWatts ? "Watts"
					   : Services.settings.electricalPowerDisplay === VenusOS.ElectricalPowerDisplay_PreferAmps ? "Amps"
					   : "Mixed") + " | "
					+ (Services.settings.temperatureUnit === VenusOS.Units_Temperature_Celsius
					   ? "Celsius"
					   : "Fahrenheit") + " | "
					+ (Services.settings.volumeUnit === VenusOS.Units_Volume_CubicMetre
					   ? "Cubic metres"
					   : Services.settings.volumeUnit === VenusOS.Units_Volume_Litre
						 ? "Litres"
						 : Services.settings.volumeUnit === VenusOS.Units_Volume_GallonUS
						   ? "Gallons (US)"
						   : "Gallons (Imperial)") + " | "
					+ (Services.settings.speedUnit === VenusOS.Units_Speed_KilometresPerHour
					   ? "km/h"
					   : Services.settings.speedUnit === VenusOS.Units_Speed_MetresPerSecond
						 ? "m/s"
						 : Services.settings.speedUnit === VenusOS.Units_Speed_Knots
						   ? "kt"
						   : "mph")
			break
		case Qt.Key_V:
			pageConfigTitle.text = "Remove Levels page"
			root.removeTanksAndTemperatures()
			break
		case Qt.Key_W:
			pageConfigTitle.text = "Return to start page"
			Global.mainView.loadStartPage()
			break
		case Qt.Key_X:
			Services.settings.accessLevel.setValue(Utils.modulo(Services.settings.accessLevel.value + 1, VenusOS.User_AccessType_Service + 1))
			pageConfigTitle.text = "Access Level: " + Services.settings.accessLevel.value
			break
		case Qt.Key_Space:
			UiConfig.splashScreenVisible = false
			break
		default:
			break
		}
	}

	property Rectangle _configLabel: Rectangle {
		parent: Global.mainView
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

	property BoatPageConfig boatPageConfig: BoatPageConfig {
		property int configIndex: -1
	}

	property KeyEventFilter keyEventFilter: KeyEventFilter {
		window: Global.main
		onKeyPressed: (key, modifiers) => {
			root.keyPressed(key, modifiers)
		}
	}

	property FilteredDeviceModel tanksAndTemperatureModel: FilteredDeviceModel {
		serviceTypes: ["tank", "temperature"]
	}
}
