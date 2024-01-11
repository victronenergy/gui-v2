/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

/*
 * These settings are regularly brought up to date with the settings from gui-v1.
 * Currently up to date with gui-v1 v5.6.6.
 */

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	function _deviceDisplayInfo(serviceType, device, sourceModel) {
		let summary = []
		let url = ""
		let params = ""

		if (!serviceType || !device || !sourceModel) {
			return null
		}

		switch(serviceType) {
		case "vebus":
			// vebus devices may also show up as AC inputs, so ensure they do not appear twice
			// in the list.
			if (sourceModel === Global.acInputs.model) {
				return null
			} else {
				url = "/pages/vebusdevice/PageVeBus.qml"
				params = { "veBusDevice" : device }
				summary = [ Global.system.systemStateToText(device.state) ]
			}
			break;

		case "multi":
			url = "/pages/settings/devicelist/PageNotYetImplemented.qml"
			params = { "bindPrefix" : device.serviceUid }
			summary = [ Global.system.systemStateToText(device.state) ]
			break;

		case "battery":
			url = "/pages/settings/devicelist/battery/PageBattery.qml"
			params = { "battery" : device }
			summary = [
				Units.getCombinedDisplayText(VenusOS.Units_Percentage, device.stateOfCharge),
				Units.getCombinedDisplayText(VenusOS.Units_Volt, device.voltage),
				Units.getCombinedDisplayText(VenusOS.Units_Amp, device.current),
			]
			break;

		case "solarcharger":
			url = "/pages/solar/SolarChargerPage.qml"
			params = { "solarCharger" : device }
			summary = [
				device.errorCode <= 0
						? Units.getCombinedDisplayText(VenusOS.Units_Watt, device.power)
						  //% "Error: %1"
						: qsTrId("devicelist_solarcharger_error").arg(Global.solarChargers.chargerErrorToText(device.errorCode))
			]
			break;

		case "charger":
			url = "/pages/settings/devicelist/PageNotYetImplemented.qml"
			params = { "bindPrefix" : device.serviceUid }
			summary = [ Global.system.systemStateToText(device.state) ]
			break;

		case "tank":
			url = "/pages/settings/devicelist/tank/PageTankSensor.qml"
			params = { "title": device.name, "bindPrefix" : device.serviceUid }

			if (device.status === VenusOS.Tank_Status_Ok) {
				const levelText = Units.getCombinedDisplayText(VenusOS.Units_Percentage, device.level)
				if (isNaN(device.temperature)) {
					summary = [ levelText ]
				} else {
					const tankTemp = Global.systemSettings.convertFromCelsius(device.temperature)
					summary = [
						Units.getCombinedDisplayText(Global.systemSettings.temperatureUnit, tankTemp),
						levelText
					]
				}
			} else {
				summary = [ device.status >= 0 ? Global.tanks.statusToText(device.status) : "--" ]
			}
			break;

		case "pvinverter":	// deliberate fall through
		case "grid":		// deliberate fall through
		case "genset":		// deliberate fall through
		case "acload":
			url = "/pages/settings/devicelist/ac-in/PageAcIn.qml"
			params = { "bindPrefix": device.serviceUid, "title": device.name }

			const acInputPowerText = Units.getCombinedDisplayText(VenusOS.Units_Watt, device.power)
			if (device.gensetStatusCode >= 0) {
				summary = [ Global.acInputs.gensetStatusCodeToText(device.gensetStatusCode), acInputPowerText ]
			} else {
				summary = [ acInputPowerText ]
			}
			break;

		case "motordrive":
			url = "/pages/settings/devicelist/PageNotYetImplemented.qml"
			params = { "bindPrefix" : device.serviceUid }
			summary = [ Units.getCombinedDisplayText(VenusOS.Units_RevolutionsPerMinute, device.motorRpm) ]
			break;

		case "inverter":
			url = "/pages/settings/devicelist/inverter/PageInverter.qml"
			params = { "bindPrefix" : device.serviceUid }
			summary = [ Units.getCombinedDisplayText(device.currentPhase.powerUnit, device.currentPhase.power) ]
			break;

		case "temperature":
			url = "/pages/settings/devicelist/temperature/PageTemperatureSensor.qml"
			params = { "bindPrefix" : device.serviceUid }

			const inputTemp = Global.systemSettings.convertFromCelsius(device.temperature_celsius)
			if (isNaN(device.humidity)) {
				summary = [
					Units.getCombinedDisplayText(Global.systemSettings.temperatureUnit, inputTemp),
				]
			} else {
				summary = [
					Units.getCombinedDisplayText(Global.systemSettings.temperatureUnit, inputTemp),
					Units.getCombinedDisplayText(VenusOS.Units_Percentage, device.humidity),
				]
			}
			break;

		case "digitalinput":
			url = "/pages/settings/devicelist/PageDigitalInput.qml"
			params = { "title": device.name, "bindPrefix": device.serviceUid }
			summary = [ Global.digitalInputs.inputStateToText(device.state) ]
			break;

		case "evcharger":
			url = "/pages/evcs/EvChargerPage.qml"
			params = { "evCharger" : device }

			const evChargerModeText = Global.evChargers.chargerModeToText(device.mode)
			if (device.status === VenusOS.Evcs_Status_Charging) {
				summary = [ evChargerModeText, Units.getCombinedDisplayText(VenusOS.Units_Watt, device.power) ]
			} else {
				summary = [ evChargerModeText, Global.evChargers.chargerStatusToText(device.status) ]
			}
			break;

		case "fuelcell":	// deliberate fall through
		case "dcsource":	// deliberate fall through
		case "dcload":		// deliberate fall through
		case "dcsystem":	// deliberate fall through
		case "alternator":
			url = serviceType === "alternator" ? "/pages/settings/devicelist/dc-in/PageAlternator.qml"
					: "/pages/settings/devicelist/dc-in/PageDcMeter.qml"
			params = { "title": device.name, "bindPrefix": device.serviceUid }
			summary = [
				Units.getCombinedDisplayText(VenusOS.Units_Volt, device.voltage),
				Units.getCombinedDisplayText(VenusOS.Units_Amp, device.current),
				Units.getCombinedDisplayText(VenusOS.Units_Watt, device.power),
			]
			break;

		case "pulsemeter":
			url = "/pages/settings/devicelist/pulsemeter/PagePulseCounter.qml"
			params = { "title": device.name, "bindPrefix": device.serviceUid }
			summary = [ Units.getCombinedDisplayText(Global.systemSettings.volumeUnit, device.aggregate) ]
			break;

		case "unsupported":
			//: Device is not supported
			//% "Unsupported"
			summary = [ qsTrId("devicelist_unsupported") ]
			url = "/pages/settings/devicelist/PageUnsupportedDevice.qml"
			params = { "bindPrefix": device.serviceUid }
			break;

		case "meteo":
			url = "/pages/settings/devicelist/PageMeteo.qml"
			params = { "title": device.name, "bindPrefix": device.serviceUid }
			summary = [ Units.getCombinedDisplayText(VenusOS.Units_WattsPerSquareMeter, device.irradiance) ]
			break;

		default:
			return null
		}

		return { "summary": summary, "url": url, "params": params }
	}

	GradientListView {
		model: AggregateDeviceModel {
			id: aggregateModel

			sourceModels: [
				Global.batteries.model,
				Global.chargers.model,
				Global.dcInputs.model,
				Global.dcLoads.model,
				Global.dcSystems.model,
				Global.digitalInputs.model,
				Global.environmentInputs.model,
				Global.evChargers.model,
				Global.inverters.model,
				Global.meteoDevices.model,
				Global.motorDrives.model,
				Global.multiRsDevices.model,
				Global.pulseMeters.model,
				Global.pvInverters.model,
				Global.solarChargers.model,
				Global.veBusDevices.model,
				Global.unsupportedDevices.model,

				// AC input models
				gridDeviceModel,
				gensetDeviceModel,
				acLoadDeviceModel,

			].concat(Global.tanks.allTankModels)
		}

		footer: ListButton {
			//% "Remove disconnected devices"
			text: qsTrId("devicelist_remove_disconnected_devices")
			secondaryText: CommonWords.remove
			visible: aggregateModel.disconnectedDeviceCount > 0
			onClicked: {
				aggregateModel.removeDisconnectedDevices()
			}
		}

		delegate: ListTextGroup {
			id: deviceDelegate

			readonly property string _serviceType: model.device
					? BackendConnection.type === BackendConnection.MqttSource
						? model.device.serviceUid.split("/")[1] || ""    // serviceUid = mqtt/<serviceType>/<path>
						: model.device.serviceUid.split(".")[2] || ""    // serviceUid = dbus/com.victronenergy.<serviceType>[.suffix]/<path>
					: ""
			readonly property var _displayInfo: model.connected
					? root._deviceDisplayInfo(_serviceType, model.device, model.sourceModel)
					: null

			text: model.cachedDeviceDescription
			textModel: _displayInfo ? _displayInfo.summary || [] : [ CommonWords.not_connected ]

			CP.ColorImage {
				parent: deviceDelegate.content
				anchors.verticalCenter: parent.verticalCenter
				source: "qrc:/images/icon_back_32.svg"
				rotation: 180
				color: deviceMouseArea.containsPress ? Theme.color_listItem_down_forwardIcon : Theme.color_listItem_forwardIcon
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

	AcInDeviceModel {
		id: gridDeviceModel
		serviceType: "grid"
	}

	AcInDeviceModel {
		id: gensetDeviceModel
		serviceType: "genset"
	}

	AcInDeviceModel {
		id: acLoadDeviceModel
		serviceType: "acload"
	}
}

