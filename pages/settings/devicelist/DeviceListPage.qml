/*
** Copyright (C) 2021 Victron Energy B.V.
*
* These settings are regularly brought up to date with the settings from gui-v1.
* Currently up to date with gui-v1 v5.6.6.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import "/components/Units.js" as Units

Page {
	id: root

	function _deviceDisplayInfo(serviceType, device, sourceModel) {
		let summary = []
		let url = ""
		let params = ""

		if (!serviceType || !device || !sourceModel) {
			return null
		}

		if (serviceType === "vebus"
				// vebus devices may also show up as AC inputs, so ensure they do not appear twice
				// in the list.
				&& sourceModel !== Global.acInputs.model) {
			summary = [ Global.system.systemStateToText(device.state) ]

		} else if (serviceType === "battery") {
			summary = [
				Units.getCombinedDisplayText(VenusOS.Units_Percentage, device.stateOfCharge),
				Units.getCombinedDisplayText(VenusOS.Units_Volt, device.voltage),
				Units.getCombinedDisplayText(VenusOS.Units_Amp, device.current),
			]

		} else if (serviceType === "solarcharger") {
			url = "/pages/solar/SolarChargerPage.qml"
			params = { "solarCharger" : device }
			summary = [
				device.errorCode <= 0
						? Units.getCombinedDisplayText(VenusOS.Units_Watt, device.power)
						  //% "Error: %1"
						: qsTrId("devicelist_solarcharger_error").arg(Global.solarChargers.chargerErrorToText(device.errorCode))
			]

		} else if (serviceType === "pvinverter") {
			url = "/pages/solar/PvInverterPage.qml"
			params = { "pvInverter" : device }
			summary = [ Units.getCombinedDisplayText(VenusOS.Units_Watt, device.power) ]

		} else if (serviceType === "charger") {
			url = "/pages/settings/devicelist/PageNotYetImplemented.qml"
			params = { "bindPrefix" : device.serviceUid }
			summary = [ Global.system.systemStateToText(device.state) ]

		} else if (serviceType === "tank") {
			if (device.status === VenusOS.Tank_Status_Ok) {
				const levelText = Units.getCombinedDisplayText(VenusOS.Units_Percentage, device.level)
				if (isNaN(device.temperature)) {
					summary = [ levelText ]
				} else {
					const tankTemp = Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Celsius
							? device.temperature
							: Units.celsiusToFahrenheit(device.temperature)
					summary = [
						Units.getCombinedDisplayText(Global.systemSettings.temperatureUnit.value, tankTemp),
						levelText
					]
				}
			} else {
				summary = [ device.status >= 0 ? Global.tanks.statusToText(device.status) : "--" ]
			}

		} else if (serviceType === "grid"
				   || serviceType === "genset"
				   || serviceType === "acload") {
			if (device.connected) {
				const acInputPowerText = Units.getCombinedDisplayText(VenusOS.Units_Watt, device.power)
				if (device.gensetStatusCode >= 0) {
					summary = [ Global.acInputs.gensetStatusCodeToText(device.gensetStatusCode), acInputPowerText ]
				} else {
					summary = [ acInputPowerText ]
				}
			} else {
				summary = [ CommonWords.not_connected ]
			}

		} else if (serviceType === "motordrive") {
			url = "/pages/settings/devicelist/PageNotYetImplemented.qml"
			params = { "bindPrefix" : device.serviceUid }
			summary = [ Units.getCombinedDisplayText(VenusOS.Units_RevolutionsPerMinute, device.motorRpm) ]

		} else if (serviceType === "inverter") {
			summary = [ Units.getCombinedDisplayText(device.currentPhase.powerUnit, device.currentPhase.power) ]

		} else if (serviceType === "temperature") {
			const inputTemp = Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Celsius
					? device.temperature_celsius
					: Units.celsiusToFahrenheit(device.temperature_celsius)
			if (isNaN(device.humidity)) {
				summary = [
					Units.getCombinedDisplayText(Global.systemSettings.temperatureUnit.value, inputTemp),
				]
			} else {
				summary = [
					Units.getCombinedDisplayText(Global.systemSettings.temperatureUnit.value, inputTemp),
					Units.getCombinedDisplayText(VenusOS.Units_Percentage, device.humidity),
				]
			}

		} else if (serviceType === "digitalinput") {
			summary = [ Global.digitalInputs.inputStateToText(device.state) ]

		} else if (serviceType === "evcharger") {
			url = "/pages/evcs/EvChargerPage.qml"
			params = { "evCharger" : device }

			const evChargerModeText = Global.evChargers.chargerModeToText(device.mode)
			if (device.status === VenusOS.Evcs_Status_Charging) {
				summary = [ evChargerModeText, Units.getCombinedDisplayText(VenusOS.Units_Watt, device.power) ]
			} else {
				summary = [ evChargerModeText, Global.evChargers.chargerStatusToText(device.status) ]
			}

		} else if (sourceModel === Global.dcInputs.model) {
			summary = [
				Units.getCombinedDisplayText(VenusOS.Units_Volt, device.voltage),
				Units.getCombinedDisplayText(VenusOS.Units_Amp, device.current),
				Units.getCombinedDisplayText(VenusOS.Units_Watt, device.power),
			]

		} else if (serviceType === "pulsemeter") {
			summary = [ Units.getCombinedDisplayText(Global.systemSettings.volumeUnit.value, device.aggregate) ]

		} else if (serviceType === "unsupported") {
			//: Device is not supported
			//% "Unsupported"
			summary = [ qsTrId("devicelist_unsupported") ]
			url = "/pages/settings/devicelist/PageUnsupportedDevice.qml"
			params = { "bindPrefix": device.serviceUid }

		} else if (serviceType === "meteo") {
			summary = [ Units.getCombinedDisplayText(VenusOS.Units_WattsPerSquareMeter, device.irradiance) ]

		} else {
			return null
		}

		return { "summary": summary, "url": url, "params": params }
	}

	GradientListView {
		model: AggregateDeviceModel {
			sourceModels: [
				Global.acInputs.model,
				Global.batteries.model,
				Global.chargers.model,
				Global.dcInputs.model,
				Global.digitalInputs.model,
				Global.environmentInputs.model,
				Global.evChargers.model,
				Global.inverters.model,
				Global.meteoDevices.model,
				Global.motorDrives.model,
				Global.pulseMeters.model,
				Global.pvInverters.model,
				Global.solarChargers.model,
				Global.veBusDevices.model,
				Global.unsupportedDevices.model,
			].concat(Global.tanks.allTankModels)
		}
		delegate: ListTextGroup {
			id: deviceDelegate

			readonly property string _serviceType: model.device
					? BackendConnection.type === BackendConnection.MqttSource
						? model.device.serviceUid.split("/")[1] || ""    // serviceUid = mqtt/<serviceType>/<path>
						: model.device.serviceUid.split(".")[2] || ""    // serviceUid = dbus/com.victronenergy.<serviceType>[.suffix]/<path>
					: ""
			readonly property var _displayInfo: root._deviceDisplayInfo(_serviceType, model.device, model.sourceModel)

			text: model.device ? model.device.description : ""
			textModel: _displayInfo ? _displayInfo.summary || [] : []
			visible: !!_displayInfo

			CP.ColorImage {
				parent: deviceDelegate.content
				anchors.verticalCenter: parent.verticalCenter
				source: "/images/icon_back_32.svg"
				rotation: 180
				color: deviceMouseArea.containsPress ? Theme.color.listItem.down.forwardIcon : Theme.color.listItem.forwardIcon
				fillMode: Image.PreserveAspectFit
				visible: deviceMouseArea.enabled
			}

			MouseArea {
				id: deviceMouseArea

				anchors.fill: parent
				enabled: !!_displayInfo && _displayInfo.url.length > 0
				onClicked: {
					Global.pageManager.pushPage(_displayInfo.url, _displayInfo.params)
				}
			}
		}
	}
}

