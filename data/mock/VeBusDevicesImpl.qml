/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

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

			serviceUid: "mock/com.victronenergy.vebus.ttyUSB" + deviceInstance
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
