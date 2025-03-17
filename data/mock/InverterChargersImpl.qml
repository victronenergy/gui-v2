/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property int mockInverterChargerCount

	function populateInverterChargers() {
		let quattro = {
			state: VenusOS.System_State_Inverting,
			productId: 9816,    // will produce EU amp options
			productName: "Quattro 48/5000/70-2x100",
			mode: VenusOS.InverterCharger_Mode_On,
			modeAdjustable: true,
		}
		let quattroDevice = createInverterCharger(quattro)
		addInputSettings(quattroDevice, [VenusOS.AcInputs_InputSource_Generator, VenusOS.AcInputs_InputSource_Shore])
		Global.inverterChargers.veBusDevices.addDevice(quattroDevice)

		let multiPlus = {
			state: VenusOS.System_State_AbsorptionCharging,
			productId: 9728,    // will produce US amp options
			productName: "MultiPlus 12/3000/120-5",
			mode: VenusOS.InverterCharger_Mode_InverterOnly,
			modeAdjustable: true,
		}
		let multiPlusDevice = createInverterCharger(multiPlus)
		addInputSettings(multiPlusDevice, [VenusOS.AcInputs_InputSource_Grid])
		Global.inverterChargers.veBusDevices.addDevice(multiPlusDevice)
	}

	function createInverterCharger(config) {
		const deviceInstanceNum = mockInverterChargerCount++
		const inverterCharger = inverterChargerComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.vebus.ttyUSB" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum
		})
		for (const configProperty in config) {
			const configValue = config[configProperty]
			if (inverterCharger["_" + configProperty] !== undefined) {
				inverterCharger["_" + configProperty].setValue(configValue)
			}
		}
		return inverterCharger
	}

	function addInputSettings(inverterCharger, inputTypes) {
		for (let i = 0; i < inputTypes.length; ++i) {
			const inputNumber = i + 1
			const inputType = inputTypes[i]
			const currentLimit = Math.floor(Math.random() * 50)
			const currentLimitAdjustable = i === 0

			Global.mockDataSimulator.setMockValue(Global.systemSettings.serviceUid + "/Settings/SystemSetup/AcInput" + inputNumber, inputType)
			inverterCharger.setMockValue("/Ac/In/%1/CurrentLimit".arg(inputNumber), currentLimit)
			inverterCharger.setMockValue("/Ac/In/%1/CurrentLimitIsAdjustable".arg(inputNumber), currentLimitAdjustable)
		}
		inverterCharger.setMockValue("/Ac/NumberOfAcInputs", inputTypes.length)
	}

	property Component inverterChargerComponent: Component {
		InverterCharger {
			id: veBusDevice

			function setMockValue(path, value) {
				Global.mockDataSimulator.setMockValue(serviceUid + path, value)
			}

			readonly property VeQuickItem _modeAdjustable: VeQuickItem {
				uid: veBusDevice.serviceUid + "/ModeIsAdjustable"
			}

			readonly property VeQuickItem _chargeState: VeQuickItem {
				property Timer subStateTimer : Timer {
					interval: 10000
					running: true
					onTriggered: _chargeState.setValue(VenusOS.VeBusDevice_ChargeState_Absorption)
				}
				uid: veBusDevice.serviceUid + "/VebusChargeState"
			}

			readonly property VeQuickItem _setChargeState: VeQuickItem {
				uid: veBusDevice.serviceUid + "/VebusSetChargeState"
				onValueChanged: {
					if (value === 1) {
						equalizeTimer.start()
					}
				}

				property Timer equalizeTimer: Timer {
					interval: 5000
					repeat: true
					onTriggered: {
						switch (parent.value) {
						case VenusOS.VeBusDevice_ChargeState_Absorption:
							parent.setValue(VenusOS.VeBusDevice_ChargeState_Equalize)
							break
						default:
							parent.setValue(VenusOS.VeBusDevice_ChargeState_Absorption)
							stop()
							break
						}
					}
				}
			}

			property Instantiator vebusDevicesExtendedStatus: Instantiator {
				model: 18
				delegate: QtObject {
					property VeQuickItem code: VeQuickItem {
						uid: veBusDevice.serviceUid + "/Devices/" + index + "/ExtendStatus/GridRelayReport/Code"
						Component.onCompleted: setValue(index)
					}
					property VeQuickItem count: VeQuickItem {
						uid: veBusDevice.serviceUid + "/Devices/" + index + "/ExtendStatus/GridRelayReport/Count"
						Component.onCompleted: setValue(index + 1)
					}
				}
			}

			property Instantiator vebusDeviceAlarmStatus: Instantiator {
				model: VeBusDeviceAlarmStatusModel { }
				delegate: VeBusDeviceAlarmGroup {
					bindPrefix: veBusDevice.serviceUid
					alarmSuffix: pathSuffix
				}
				onObjectAdded: function(index, object) {
					for (var i = 0; i < object.alarms.length; ++i) {
						object.alarms[i].setValue(1)
					}
				}
			}

			property Instantiator vebusDeviceAlarmSettings: Instantiator {
				model: VeBusDeviceAlarmSettingsModel { }
				delegate: VeQuickItem {
					uid: veBusDevice.serviceUid + "/Settings/Alarm/Vebus" + pathSuffix
					Component.onCompleted: setValue(2)
				}
			}

			readonly property Instantiator vebusAcSensors: Instantiator {

				model: 4

				delegate: Instantiator {

					property int sensorIndex: index

					model: VeBusAcSensorModel { }

					delegate: VeQuickItem {
						uid: veBusDevice.serviceUid + "/AcSensor/" + sensorIndex + pathSuffix
						Component.onCompleted: setValue(sensorIndex)
					}

				}
			}

			readonly property Instantiator vebusDeviceKwhCounters: Instantiator {
				model: VeBusDeviceKwhCountersModel { }
				delegate: VeQuickItem {
					uid: veBusDevice.serviceUid + "/Energy" + pathSuffix
					Component.onCompleted: setValue(4.39 + index * 0.1)
				}
			}

			readonly property VeQuickItem _powerMeasurementType: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Energy/Ac/PowerMeasurementType"
			}

			// PageVeBusAdvanced
			readonly property Instantiator vebusNetworkQualityCounters: Instantiator {
				model: 18
				delegate: VeQuickItem {
					uid: veBusDevice.serviceUid + "/Devices/" + index + "/ExtendStatus/VeBusNetworkQualityCounter"
					Component.onCompleted: setValue(index * 2)
				}
			}

			// PageVeBusDebug
			readonly property Instantiator debugPageDataItems: Instantiator {
				model: ["/Energy", "/Power", "/Voltage", "/Current", "/Location", "/Phase"]
				delegate: VeQuickItem {
					uid: veBusDevice.serviceUid + modelData
					Component.onCompleted: {
						setValue(index * 1000)
					}
				}
			}

			// PageVeBusDeviceInfo
			readonly property Instantiator veBusDeviceInfoPageDataItems: Instantiator {
				model: VeBusDeviceInfoModel { }
				delegate: VeQuickItem {
					uid: veBusDevice.serviceUid + pathSuffix
					Component.onCompleted: {
						switch(displayText) {
						case "MK2 version":
							setValue(1170212)
							break
						case "Multi Control version":
							break
						case "VE.Bus BMS version":
							break
						default:
							setValue(index)
							break
						}
					}
				}
			}

			readonly property VeQuickItem _maxChargePower: VeQuickItem {
				uid: BackendConnection.serviceUidForType("hub4") + "/MaxChargePower"
			}

			readonly property VeQuickItem _maxDischargePower: VeQuickItem {
				uid: BackendConnection.serviceUidForType("hub4") + "/MaxDischargePower"
			}

			readonly property VeQuickItem _disableCharge: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Hub4/DisableCharge"
			}

			readonly property VeQuickItem _disableFeedIn: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Hub4/DisableFeedIn"
			}

			// PageVeBusSerialNumbers
			readonly property VeQuickItem _serialNumber1: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Devices/0/SerialNumber"
			}

			readonly property VeQuickItem _serialNumber2: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Devices/1/SerialNumber"
			}

			readonly property VeQuickItem _serialNumber3: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Devices/2/SerialNumber"
			}

			readonly property VeQuickItem _redetectSystem: VeQuickItem {
				uid: veBusDevice.serviceUid + "/RedetectSystem"
				onValueChanged: {
					if (value === 1) {
						redetectTimer.start()
					}
				}

				property Timer redetectTimer: Timer {
					interval: 1000
					onTriggered: parent.setValue(0)
				}
			}

			readonly property VeQuickItem _systemReset: VeQuickItem {
				uid: veBusDevice.serviceUid + "/SystemReset"
				onValueChanged: {
					if (value === 1) {
						resetSystemTimer.start()
					}
				}

				property Timer resetSystemTimer: Timer {
					interval: 1000
					onTriggered: parent.setValue(0)
				}
			}

			readonly property VeQuickItem _l2L1OutSummed: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Ac/State/SplitPhaseL2L1OutSummed"
			}

			readonly property VeQuickItem _ignoreAcIn1: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Ac/State/IgnoreAcIn1"
			}

			readonly property VeQuickItem _ignoreAcIn2: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Ac/State/IgnoreAcIn2"
			}

			readonly property VeQuickItem _waitingForRelayTest: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Devices/0/ExtendStatus/WaitingForRelayTest"
			}

			readonly property VeQuickItem _numberOfPhases: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Ac/NumberOfPhases"
			}

			readonly property VeQuickItem _bmsMode: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Devices/Bms/Version"
			}

			readonly property VeQuickItem _bmsType: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Bms/BmsType"
			}

			readonly property VeQuickItem _bmsExpected: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Bms/BmsExpected"
			}

			readonly property VeQuickItem _bmsAllowToCharge: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Bms/AllowToCharge"
			}

			readonly property VeQuickItem _bmsAllowToDischarge: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Bms/AllowToDischarge"
			}

			readonly property VeQuickItem _bmsError: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Bms/Error"
			}

			readonly property VeQuickItem _vebusError: VeQuickItem {
				uid: veBusDevice.serviceUid + "/VebusError"
			}

			// PageVeBus
			readonly property VeQuickItem _mk3Update: VeQuickItem {
				uid: Global.systemSettings.serviceUid + "/Settings/Vebus/AllowMk3Fw212Update"
			}

			readonly property VeQuickItem _preferRenewableEnergy: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Dc/0/PreferRenewableEnergy"
			}

			readonly property VeQuickItem _dcVoltage: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Dc/0/Voltage"
			}

			readonly property VeQuickItem _l1Voltage: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Ac/ActiveIn/L1/V"
			}

			readonly property VeQuickItem _l1Current: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Ac/ActiveIn/L1/I"
			}

			readonly property VeQuickItem _l1Power: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Ac/ActiveIn/L1/P"
			}

			readonly property VeQuickItem _l1Frequency: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Ac/ActiveIn/L1/F"
			}

			readonly property VeQuickItem _currentLimitIsAdjustable: VeQuickItem {
				uid: veBusDevice.serviceUid + "/Ac/ActiveIn/CurrentLimitIsAdjustable"
			}

			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_chargeState.setValue(VenusOS.VeBusDevice_ChargeState_InitializingCharger)
				_setChargeState.setValue(VenusOS.VeBusDevice_ChargeState_InitializingCharger)
				_redetectSystem.setValue(0)
				_l2L1OutSummed.setValue(1)
				_ignoreAcIn1.setValue(0)
				_ignoreAcIn2.setValue(0)
				_waitingForRelayTest.setValue(0)
				_numberOfPhases.setValue(3)
				_bmsMode.setValue(0)
				_bmsType.setValue(VenusOS.VeBusDevice_Bms_Type_VeBus)
				_bmsExpected.setValue(1)
				_bmsAllowToCharge.setValue(1)
				_bmsAllowToDischarge.setValue(1)
				_bmsError.setValue(0)
				_vebusError.setValue(0)
				_powerMeasurementType.setValue(0)
				_maxChargePower.setValue(1000)
				_maxDischargePower.setValue(2000)
				_disableCharge.setValue(0)
				_disableFeedIn.setValue(0)
				_serialNumber1.setValue("HQ192975QN3")
				_serialNumber2.setValue("HQ1928NS8QU")
				_serialNumber3.setValue("HQ1929ZTQLS")
				_mk3Update.setValue(0)
				_preferRenewableEnergy.setValue(0)
				_dcVoltage.setValue(12.1)
				_l1Voltage.setValue(235)
				_l1Current.setValue(23.4)
				_l1Power.setValue(99.9)
				_l1Frequency.setValue(49.9)
				_currentLimitIsAdjustable.setValue(1)
				setMockValue("/Interfaces/Mk2/Connection", "/ttyS2")
			}
		}
	}

	readonly property VeQuickItem _backupRestoreAction: VeQuickItem {
		uid: Global.venusPlatform.serviceUid + "/Vebus/Interface/ttyS2/Action"
		onValueChanged: {
			if (valid && value !== VenusOS.VeBusDevice_Backup_Restore_Action_None) {
				Global.mockDataSimulator.setMockValue(Global.venusPlatform.serviceUid + "/Vebus/Interface/ttyS2/Info", 10) // State = "Init"
				_actionResetTimer.restart()
			}
		}

		readonly property Timer _actionResetTimer: Timer {
			interval: 2000
			onTriggered: {
				let successCode = _backupRestoreAction.value
				switch (_backupRestoreAction.value) {
				case VenusOS.VeBusDevice_Backup_Restore_Action_Backup:
					successCode = 1
					break
				case VenusOS.VeBusDevice_Backup_Restore_Action_Restore:
					successCode = 2
					break
				case VenusOS.VeBusDevice_Backup_Restore_Action_Delete:
					successCode = 3
					break
				}
				_backupRestoreAction.setValue(VenusOS.VeBusDevice_Backup_Restore_Action_None)
				Global.mockDataSimulator.setMockValue(Global.venusPlatform.serviceUid + "/Vebus/Interface/ttyS2/Notify", successCode)
			}
		}
	}

	//--- inverters ---

	property int mockInverterCount

	property Component inverterComponent: Component {
		Inverter {
			id: inverter

			function setMockValue(path, value) {
				Global.mockDataSimulator.setMockValue(serviceUid + path, value)
			}

			function mockValue(path) {
				return Global.mockDataSimulator.mockValue(serviceUid + path)
			}

			property Timer _trackerUpdates: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 2000
				onTriggered: {
					acOutL1._voltage.setValue(Math.random() * 200)
					acOutL1._current.setValue(Math.random() * 10)
					acOutL1._reportedPower.setValue(Math.random() * 100)
					dcVoltage.setValue(Math.random() * 10)
					dcCurrent.setValue(Math.random())

					if (nrOfTrackers.valid) {
						setMockValue("/Pv/V", Math.random() * 0.5)
						setMockValue("/Yield/Power", 100 + (Math.random() * 100))
						setMockValue(mockValue("/Yield/System") + (Math.random() * 100))
						setMockValue(mockValue("/Yield/User") + (Math.random() * 100))
					}
				}
			}

			property VeQuickItem dcVoltage: VeQuickItem {
				uid: inverter.serviceUid + "/Dc/0/Voltage"
			}

			property VeQuickItem dcCurrent: VeQuickItem {
				uid: inverter.serviceUid + "/Dc/0/Current"
			}

			property VeQuickItem mode: VeQuickItem {
				uid: inverter.serviceUid + "/Mode"
			}

			property VeQuickItem isInverterCharger: VeQuickItem {
				uid: inverter.serviceUid + "/IsInverterCharger"
			}

			property VeQuickItem nrOfTrackers: VeQuickItem {
				uid: inverter.serviceUid + "/NrOfTrackers"
			}

			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_productName.setValue("Phoenix Inverter 12V 250VA 230V")
				_customName.setValue("My Inverter " + deviceInstance)
				_state.setValue(Math.floor(Math.random() * VenusOS.System_State_PassThrough))
				mode.setValue(VenusOS.Inverter_Mode_Off)
			}
		}
	}

	function populateInverters() {
		const inverterCount = (Math.random() * 3) + 1
		for (let i = 0; i < inverterCount; ++i) {
			const deviceInstanceNum = mockInverterCount++
			const inverterObj = inverterComponent.createObject(root, {
				serviceUid: "mock/com.victronenergy.inverter.ttyUSB" + deviceInstanceNum,
				deviceInstance: deviceInstanceNum,
			})
			if (i == 0) {
				inverterObj.isInverterCharger.setValue(1)
				inverterObj._customName.setValue("Inverter with IsInverterCharger=1")
			} else if (i == 1) {
				inverterObj.nrOfTrackers.setValue(1)
				inverterObj._customName.setValue("Inverter with solar")
				inverterObj.setMockValue("/History/Overall/DaysAvailable", 1)
				inverterObj.setMockValue("/History/Daily/0/Yield", Math.random())
			}
			Global.inverterChargers.inverterDevices.addDevice(inverterObj)
		}
	}

	//--- totals

	readonly property VeQuickItem inverterChargerPower: VeQuickItem {
		uid: Global.system.serviceUid + "/Dc/InverterCharger/Power"
	}

	readonly property int batteryMode: Global.system.battery.mode
	onBatteryModeChanged: {
		// Positive power when battery is charging, negative power when battery is discharging
		const randomPower = Math.round(100 + (Math.random() * 600))
		const batteryMode = Global.system.battery.mode
		const power = batteryMode === VenusOS.Battery_Mode_Charging ? randomPower
				: batteryMode === VenusOS.Battery_Mode_Discharging ? randomPower * -1
				: 0 // Battery_Mode_Idle
		root.inverterChargerPower.setValue(power)
	}


	Component.onCompleted: {
		populateInverterChargers()
		populateInverters()
	}
}
