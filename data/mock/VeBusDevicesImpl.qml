/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function populate() {
		let quattro = {
			state: VenusOS.System_State_Inverting,
			productId: 9816,
			name: "Quattro 48/5000/70-2x100",
			ampOptions: [ 3.0, 6.0, 10.0, 13.0, 16.0, 25.0, 32.0, 63.0 ].map(function(v) { return { value: v } }),   // EU amp options
			mode: VenusOS.VeBusDevice_Mode_On,
			modeAdjustable: true,
		}
		let quattroDevice = veBusDeviceComponent.createObject(root, quattro)
		addInputSettings(quattroDevice, [VenusOS.AcInputs_InputSource_Generator, VenusOS.AcInputs_InputSource_Shore])
		Global.veBusDevices.addVeBusDevice(quattroDevice)

		let multiPlus = {
			state: VenusOS.System_State_AbsorptionCharging,
			productId: 9728,
			name: "MultiPlus 12/3000/120-5",
			ampOptions: [ 10.0, 15.0, 20.0, 30.0, 50.0, 100.0 ].map(function(v) { return { value: v } }),   // US amp options
			mode: VenusOS.VeBusDevice_Mode_InverterOnly,
			modeAdjustable: true,
		}
		let multiPlusDevice = veBusDeviceComponent.createObject(root, multiPlus)
		addInputSettings(multiPlusDevice, [VenusOS.AcInputs_InputSource_Grid])
		Global.veBusDevices.addVeBusDevice(multiPlusDevice)
	}

	function addInputSettings(veBusDevice, inputTypes) {
		let settings = []
		for (let i = 0; i < inputTypes.length; ++i) {
			const settingData = {
				inputNumber: i+1,
				inputType: inputTypes[i],
				currentLimit: Math.floor(Math.random() * 50),
				currentLimitAdjustable: i === 0,
			}
			let settings = acInputSettingsComponent.createObject(root, settingData)
			veBusDevice.inputSettings.append({ inputSettings: settings })
		}
		return settings
	}

	property Component acInputSettingsComponent: Component {
		QtObject {
			property int inputNumber
			property int inputType
			property real currentLimit
			property bool currentLimitAdjustable

			function setCurrentLimit(limit) {
				currentLimit = limit
			}
		}
	}

	property Component veBusDeviceComponent: Component {
		MockDevice {
			id: veBusDevice

			property int state
			property int mode: -1
			property bool modeAdjustable
			property int numberOfPhases: 3

			property ListModel inputSettings: ListModel {}

			property int productId
			property int productType
			property var ampOptions

			property int acOutputPower: 100
			property int dcPower: 101
			property int dcVoltage: 102
			property int dcCurrent: 103
			property int stateOfCharge: 77

			property int acActiveInput: 1
			property int acActiveInputPower: 555
			property int bmsMode: 0
			property bool modeIsAdjustable: true
			property bool isMulti: false

			property var acOutput: {
				"phase1" : {
					"frequency" : 50.1,
					"current" : 20,
					"voltage" : 235,
					"power" : 4700
				},
				"phase2" : {
					"frequency" : 50.2,
					"current" : 20,
					"voltage" : 235,
					"power" : 4700
				},
				"phase3" : {
					"frequency" : 50.3,
					"current" : 20,
					"voltage" : 235,
					"power" : 4700
				}
			}

			function setMode(newMode) {
				mode = newMode
			}

			function setCurrentLimit(inputIndex, currentLimit) {
				inputSettings.get(inputIndex).inputSettings.setCurrentLimit(currentLimit)
			}

			function setMockVeBusDeviceValue(settingId, value) {
				Global.mockDataSimulator.mockDataValues["com.victronenergy.vebus.ttyUSB" + deviceInstance + settingId] = value
			}

			readonly property DataPoint _chargeState: DataPoint {
				property Timer subStateTimer : Timer {
					interval: 10000
					running: true
					onTriggered: _chargeState.setValue(VenusOS.VeBusDevice_ChargeState_Absorption)
				}
				source: veBusDevice.serviceUid + "/VebusChargeState"
			}

			readonly property DataPoint _setChargeState: DataPoint {
				source: veBusDevice.serviceUid + "/VebusSetChargeState"
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
					property DataPoint code: DataPoint {
						source: veBusDevice.serviceUid + "/Devices/" + index + "/ExtendStatus/GridRelayReport/Code"
						Component.onCompleted: setValue(index)
					}
					property DataPoint count: DataPoint {
						source: veBusDevice.serviceUid + "/Devices/" + index + "/ExtendStatus/GridRelayReport/Count"
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
				delegate: DataPoint {
					source: veBusDevice.serviceUid + "/Settings/Alarm/Vebus" + pathSuffix
					Component.onCompleted: setValue(2)
				}
			}

			readonly property Instantiator vebusAcSensors: Instantiator {

				model: 4

				delegate: Instantiator {

					property int sensorIndex: index

					model: VeBusAcSensorModel { }

					delegate: DataPoint {
						source: veBusDevice.serviceUid + "/AcSensor/" + sensorIndex + pathSuffix
						Component.onCompleted: setValue(sensorIndex)
					}

				}
			}

			readonly property Instantiator vebusDeviceKwhCounters: Instantiator {
				model: VeBusDeviceKwhCountersModel { }
				delegate: DataPoint {
					source: veBusDevice.serviceUid + "/Energy" + pathSuffix
					Component.onCompleted: setValue(4.39 + index * 0.1)
				}
			}

			readonly property DataPoint _powerMeasurementType: DataPoint {
				source: veBusDevice.serviceUid + "/Energy/Ac/PowerMeasurementType"
			}

			// PageVeBusAdvanced
			readonly property Instantiator vebusNetworkQualityCounters: Instantiator {
				model: 18
				delegate: DataPoint {
					source: veBusDevice.serviceUid + "/Devices/" + index + "/ExtendStatus/VeBusNetworkQualityCounter"
					Component.onCompleted: setValue(index * 2)
				}
			}

			// PageVeBusDebug
			readonly property Instantiator debugPageDataPoints: Instantiator {
				model: ["/Energy", "/Power", "/Voltage", "/Current", "/Location", "/Phase"]
				delegate: DataPoint {
					source: veBusDevice.serviceUid + modelData
					Component.onCompleted: {
						setValue(index * 1000)
					}
				}
			}

			// PageVeBusDeviceInfo
			readonly property Instantiator veBusDeviceInfoPageDataPoints: Instantiator {
				model: VeBusDeviceInfoModel { }
				delegate: DataPoint {
					source: veBusDevice.serviceUid + pathSuffix
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

			readonly property DataPoint _maxChargePower: DataPoint {
				source: BackendConnection.serviceUidForType("hub4") + "/MaxChargePower"
			}

			readonly property DataPoint _maxDischargePower: DataPoint {
				source: BackendConnection.serviceUidForType("hub4") + "/MaxDischargePower"
			}

			readonly property DataPoint _disableCharge: DataPoint {
				source: veBusDevice.serviceUid + "/Hub4/DisableCharge"
			}

			readonly property DataPoint _disableFeedIn: DataPoint {
				source: veBusDevice.serviceUid + "/Hub4/DisableFeedIn"
			}

			// PageVeBusSerialNumbers
			readonly property DataPoint _serialNumber1: DataPoint {
				source: veBusDevice.serviceUid + "/Devices/0/SerialNumber"
			}

			readonly property DataPoint _serialNumber2: DataPoint {
				source: "mqtt/vebus/276/Devices/1/SerialNumber"
			}

			readonly property DataPoint _serialNumber3: DataPoint {
				source: "mqtt/vebus/276/Devices/2/SerialNumber"
			}

			readonly property DataPoint _redetectSystem: DataPoint {
				source: veBusDevice.serviceUid + "/RedetectSystem"
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

			readonly property DataPoint _systemReset: DataPoint {
				source: veBusDevice.serviceUid + "/SystemReset"
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

			readonly property DataPoint _ignoreAcIn1: DataPoint {
				source: veBusDevice.serviceUid + "/Ac/State/IgnoreAcIn1"
			}

			readonly property DataPoint _ignoreAcIn2: DataPoint {
				source: veBusDevice.serviceUid + "/Ac/State/IgnoreAcIn2"
			}

			readonly property DataPoint _waitingForRelayTest: DataPoint {
				source: veBusDevice.serviceUid + "/Devices/0/ExtendStatus/WaitingForRelayTest"
			}

			readonly property DataPoint _numberOfPhases: DataPoint {
				source: veBusDevice.serviceUid + "/Ac/NumberOfPhases"
			}

			readonly property DataPoint _bmsMode: DataPoint {
				source: veBusDevice.serviceUid + "/Devices/Bms/Version"
			}

			readonly property DataPoint _bmsType: DataPoint {
				source: veBusDevice.serviceUid + "/Bms/BmsType"
			}

			readonly property DataPoint _bmsExpected: DataPoint {
				source: veBusDevice.serviceUid + "/Bms/BmsExpected"
			}

			readonly property DataPoint _bmsAllowToCharge: DataPoint {
				source: veBusDevice.serviceUid + "/Bms/AllowToCharge"
			}

			readonly property DataPoint _bmsAllowToDischarge: DataPoint {
				source: veBusDevice.serviceUid + "/Bms/AllowToDischarge"
			}

			readonly property DataPoint _bmsError: DataPoint {
				source: veBusDevice.serviceUid + "/Bms/Error"
			}

			readonly property DataPoint _vebusError: DataPoint {
				source: veBusDevice.serviceUid + "/VebusError"
			}

			// PageVeBus
			readonly property DataPoint _mk3Update: DataPoint {
				source: Global.systemSettings.serviceUid + "/Settings/Vebus/AllowMk3Fw212Update"
			}

			readonly property DataPoint _preferRenewableEnergy: DataPoint {
				source: veBusDevice.serviceUid + "/Dc/0/PreferRenewableEnergy"
			}

			readonly property DataPoint _dcVoltage: DataPoint {
				source: veBusDevice.serviceUid + "/Dc/0/Voltage"
			}

			readonly property DataPoint _l1Voltage: DataPoint {
				source: veBusDevice.serviceUid + "/Ac/ActiveIn/L1/V"
			}

			readonly property DataPoint _l1Current: DataPoint {
				source: veBusDevice.serviceUid + "/Ac/ActiveIn/L1/I"
			}

			readonly property DataPoint _l1Power: DataPoint {
				source: veBusDevice.serviceUid + "/Ac/ActiveIn/L1/P"
			}

			readonly property DataPoint _l1Frequency: DataPoint {
				source: veBusDevice.serviceUid + "/Ac/ActiveIn/L1/F"
			}

			readonly property DataPoint _currentLimitIsAdjustable: DataPoint {
				source: veBusDevice.serviceUid + "/Ac/ActiveIn/CurrentLimitIsAdjustable"
			}

			serviceUid: "com.victronenergy.vebus.ttyUSB" + deviceInstance
			name: "VeBusDevice" + deviceInstance

			Component.onCompleted: {
				_chargeState.setValue(VenusOS.VeBusDevice_ChargeState_InitializingCharger)
				_setChargeState.setValue(VenusOS.VeBusDevice_ChargeState_InitializingCharger)
				_redetectSystem.setValue(0)
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
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
