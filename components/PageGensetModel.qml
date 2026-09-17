/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

DelegateComponentModel {
	id: root

	property string bindPrefix
	property string settingsBindPrefix: Global.systemSettings.serviceUid + "/Settings/Generator1"
	property string startStopBindPrefix: _startStop1Finder.startStop1Uid
	readonly property string serviceType: BackendConnection.serviceTypeFromUid(bindPrefix)
	readonly property bool dcGenset: serviceType === "dcgenset"
	readonly property int nrOfPhases: phases.valid ? phases.value
												   : dcGenset ? 0
															  : 3

	readonly property VeQuickItem chargeVoltageItem: VeQuickItem {
		uid: root.bindPrefix + "/Settings/ChargeVoltage"
	}
	readonly property VeQuickItem chargeCurrentItem: VeQuickItem {
		uid: root.bindPrefix + "/Settings/ChargeCurrentLimit"
	}
	readonly property VeQuickItem bmsControlledItem: VeQuickItem {
		uid: root.bindPrefix + "/Settings/BmsPresent"
	}

	// In case of multiple gensets, startstop will control the one with the lowest device instance.
	// Check if this genset is controlled by startstop by checking if the instance and service type
	// are the same.
	// When not controlled by startstop, the genset can only be monitored, so hide some controls.
	readonly property bool isStartStopControlled: startStopGensetInstance.valid
			&& gensetInstance.valid
			&& startStopGensetInstance.value === gensetInstance.value
			&& startStopGensetServiceType.valid
			&& startStopGensetServiceType.value === serviceType

	readonly property bool isGensetEnabled: gensetEnabled.valid ? gensetEnabled.value === 1 : false

	readonly property VeQuickItem startStopGensetInstance: VeQuickItem {
		uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/GensetInstance" : ""
	}

	readonly property VeQuickItem startStopGensetServiceType: VeQuickItem {
		uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/GensetServiceType" : ""
	}

	readonly property VeQuickItem gensetInstance: VeQuickItem {
		uid: root.bindPrefix + "/DeviceInstance"
	}

	readonly property VeQuickItem phases: VeQuickItem {
		uid: root.bindPrefix + "/NrOfPhases"
	}

	readonly property VeQuickItem gensetEnabled: VeQuickItem {
		uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/Enabled" : ""
	}

	readonly property GensetStartStop1Finder _startStop1Finder: GensetStartStop1Finder {
		gensetServiceUid: root.bindPrefix
	}

	// Show when startstop controlled but not enabled (because the required helper relay is not configured) and only if the genset service is present.
	DelegateComponent {
		preferredVisible: gensetInstance.valid && root.isStartStopControlled && !root.isGensetEnabled
		PrimaryListLabel {
			//% "This genset controller requires a helper relay to be controlled but the helper relay is not configured. Please configure Relay 1 under Settings → Relay to \"Connected genset helper relay\"."
			text: qsTrId("genset_controller_requires_helper_relay")
		}
	}

	// Show when not startstop controlled, but only if the genset service is present.
	DelegateComponent {
		preferredVisible: gensetInstance.valid && !root.isStartStopControlled
		PrimaryListLabel {
			//% "Multiple genset controllers detected.\nThe GX device can only control one connected genset and takes the one with the lowest VRM instance number. To avoid unexpected behavior, make sure that only one unit is available to the GX device."
			text: qsTrId("genset_controller_multiple_genset_controllers")
		}
	}

	DelegateComponent {
		preferredVisible: root.isGensetEnabled && root.isStartStopControlled
		ListGeneratorAutoStartSwitch {
			id: autostartSwitch
			dataItem.uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/AutoStartEnabled" : ""
		}
	}

	DelegateComponent {
		preferredVisible: root.isGensetEnabled && root.isStartStopControlled
		ListGeneratorManualControlButton {
			generatorUid: root.startStopBindPrefix
			gensetUid: root.bindPrefix
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/Runtime" : "" }
		property VeQuickItem stateItem: VeQuickItem {
			uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/State" : ""
		}
		preferredVisible: stateItem.value >= 1 && stateItem.value <= 3 // Running, Warm-up, Cool-down
		ListText {
			//% "Current run time"
			text: qsTrId("settings_page_genset_generator_run_time")
			secondaryText: dataItem.valid ? Utils.secondsToString(dataItem.value, false) : "0"
			dataItem.uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/Runtime" : ""
		}
	}

	DelegateComponent {
		preferredVisible: root.isStartStopControlled
		ListGeneratorControlStatus {
			startStopBindPrefix: root.startStopBindPrefix
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/Error" : "" }
		preferredVisible: dataItem.valid && root.isStartStopControlled
		ListGeneratorError {
			//% "Control error code"
			text: qsTrId("ac-in-genset_control_error_code")
			dataItem.uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/Error" : ""
		}
	}

	DelegateComponent {
		ListText {
			//% "Genset status"
			text: qsTrId("ac-in-genset_status")
			secondaryText: Global.acInputs.gensetStatusCodeToText(gensetStatus.value)

			VeQuickItem {
				id: gensetStatus
				uid: root.bindPrefix + "/StatusCode"
			}
		}
	}

	DelegateComponent {
		dataItem: VeQuickItem { uid: root.bindPrefix + "/Error/0/Id" }
		preferredVisible: dataItem.valid
		ListNavigation {
			//% "Genset error codes"
			text: qsTrId("ac-in-genset_error")
			secondaryText: {
				let errorStrings = ""
				for (let i = 0; i < errorModel.count; ++i) {
					const errorCode = errorModel.get(i).errorCode
					if (errorCode) {
						errorStrings += (errorStrings.length ? " " : "") + GensetError.description(errorCode, root.nrOfPhases)
					}
				}
				return errorStrings.length ? errorStrings : CommonWords.none_errors
			}

			interactive: secondaryText !== CommonWords.none_errors

			onClicked: Global.mainView.goToNotificationsPage()

			GensetErrorModel {
				id: errorModel

				uidPrefix: root.bindPrefix
			}
		}
	}

	// Clear Error Button
	DelegateComponent {
		id: clearErrorItemDC
		dataItem: VeQuickItem { uid: root.bindPrefix + "/ClearError" }
		property VeQuickItem remoteStartModeEnabledItem: VeQuickItem {
			uid: root.bindPrefix + "/RemoteStartModeEnabled"
		}
		preferredVisible: dataItem.valid
		ListButton {
			readonly property bool hasGensetError: _gensetErrorId.valid && _gensetErrorId.value !== ""
			readonly property bool canClearGeneratorError: clearControlError.valid
					&& Number(clearControlError.value) === 2
			readonly property bool remoteStartModeIsEnabled: clearErrorItemDC.remoteStartModeEnabledItem.valid
					&& (clearErrorItemDC.remoteStartModeEnabledItem.value === 1
						|| clearErrorItemDC.remoteStartModeEnabledItem.value === true)

			//% "Clear generator error"
			text: qsTrId("clear-generator-error")
			secondaryText: CommonWords.clear_action
			interactive: hasGensetError && canClearGeneratorError && remoteStartModeIsEnabled
			onClicked: {
				clearErrorItemDC.dataItem.setValue(1)
			}
			VeQuickItem {
				id: clearControlError
				uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/Error" : ""
			}
			VeQuickItem {
				id: _gensetErrorId
				uid: root.bindPrefix + "/Error/0/Id"
			}
		}
	}

	DelegateComponent {
		preferredVisible: root.nrOfPhases > 0
		SettingsColumn {
			width: parent ? parent.width : 0

			Repeater {
				id: phaseRepeater

				model: root.nrOfPhases
				delegate: ListVoltageCurrentPower {
					required property int index

					bindPrefix: `${root.bindPrefix}/Ac/L${index + 1}`
					text: phaseRepeater.count === 1
										  ? CommonWords.ac
										  : CommonWords.ac_phase_x.arg(index + 1)
				}
			}
		}
	}

	DelegateComponent {
		ListButton {
			readonly property bool showReenableRemoteStartButton: remoteStartModeEnabled.valid
					&& (remoteStartModeEnabled.value === 0 || remoteStartModeEnabled.value === false)
					&& enableRemoteStartMode.valid
			readonly property bool canReenableRemoteStart: showReenableRemoteStartButton
					&& remoteStartStatusCode.valid
					&& remoteStartStatusCode.value === VenusOS.Genset_StatusCode_Standby

			readonly property string remoteStartSecondaryText: {
				if (canReenableRemoteStart) {
					//% "Re-enable remote start mode"
					return qsTrId("Re-enable_remote_start_mode")
				}
				if (showReenableRemoteStartButton) {
					return CommonWords.disabled
				}
				return CommonWords.enabledOrDisabled(remoteStartModeEnabled.value)
			}
			//% "Remote start mode"
			text: qsTrId("ac-in-genset_remote_start_mode")
			secondaryText: remoteStartSecondaryText
			interactive: canReenableRemoteStart
			writeAccessLevel: VenusOS.User_AccessType_User
			onClicked: enableRemoteStartMode.setValue(1)

			VeQuickItem {
				id: remoteStartModeEnabled
				uid: root.bindPrefix + "/RemoteStartModeEnabled"
			}

			VeQuickItem {
				id: enableRemoteStartMode
				uid: root.bindPrefix + "/EnableRemoteStartMode"
			}

			VeQuickItem {
				id: remoteStartStatusCode
				uid: root.bindPrefix + "/StatusCode"
			}
			VeQuickItem {
				id: controlError
				uid: root.startStopBindPrefix ? root.startStopBindPrefix + "/Error" : ""
			}
		}
	}

	DelegateComponent {
		preferredVisible: root.dcGenset
		ListDcOutputQuantityGroup {
			bindPrefix: root.bindPrefix
		}
	}

	DelegateComponent {
		ListNavigation {
			text: CommonWords.engine
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageEngine.qml",
											{
												title: text,
												bindPrefix: root.bindPrefix
											})
			}
		}
	}

	DelegateComponent {
		preferredVisible: root.isStartStopControlled
		ListNavigation {
			//% "Run time and service"
			text: qsTrId("page_settings_generator_run_time_and_service")
			onClicked: Global.pageManager.pushPage("/pages/settings/PageGeneratorRuntimeService.qml",
												   {
													   title: text,
													   settingsBindPrefix: root.settingsBindPrefix,
													   startStopBindPrefix: root.startStopBindPrefix,
													   gensetBindPrefix: root.bindPrefix
												   })
		}
	}

	DelegateComponent {
		preferredVisible: root.isStartStopControlled && (chargeVoltageItem.valid || chargeCurrentItem.valid || bmsControlledItem.valid)
		ListNavigation {
			//% "DC genset settings"
			text: qsTrId("page_genset_model_dc_genset_settings")
			onClicked: Global.pageManager.pushPage(settingsComponent, {"title": text})

			Component {
				id: settingsComponent

				Page {
					GradientListView {
						model: DelegateComponentModel {
								DelegateComponent {
									preferredVisible: chargeVoltageItem.valid
									ListSpinBox {
										//% "Charge voltage"
										text: qsTrId("genset_charge_voltage")
										dataItem.uid: root.bindPrefix + "/Settings/ChargeVoltage"
										decimals: 1
										stepSize: 0.1
										suffix: Units.defaultUnitString(VenusOS.Units_Volt_DC)
										interactive: dataItem.valid && bmsControlledItem.value === 0
									}
								}

								DelegateComponent {
									preferredVisible: bmsControlledItem.value === 1
									ListText {
										//% "The charge voltage is currently controlled by the BMS."
										text: qsTrId("genset_charge_voltage_controlled_by_bms")
									}
								}

								DelegateComponent {
									preferredVisible: chargeCurrentItem.valid
									ListSpinBox {
										//% "Charge current limit"
										text: qsTrId("genset_charge_current_limit")
										dataItem.uid: root.bindPrefix + "/Settings/ChargeCurrentLimit"
										suffix: Units.defaultUnitString(VenusOS.Units_Amp)
									}
								}

								DelegateComponent {
									preferredVisible: bmsControlledItem.valid
									ListText {
										text: CommonWords.bms_controlled
										secondaryText: CommonWords.yesOrNo(dataItem.value)
										dataItem.uid: root.bindPrefix + "/Settings/BmsPresent"
										caption: bmsControlledItem.value === 1 ? CommonWords.bms_control_info : ""
									}
								}

								DelegateComponent {
									preferredVisible: bmsControlledItem.value === 1
									ListButton {
										text: CommonWords.bms_control
										secondaryText: CommonWords.reset
										onClicked: bmsControlledItem.setValue(0)
									}
								}
							}
					}
				}
			}
		}
	}

	DelegateComponent {
		preferredVisible: root.isStartStopControlled
		ListNavigation { // to test, use the 'gdh' simulation. Not visible with the 'gdf' simulation.
			text: CommonWords.settings
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageSettingsGenerator.qml",
											{ title: text, settingsBindPrefix: root.settingsBindPrefix, startStopBindPrefix: root.startStopBindPrefix })
			}
		}
	}
}
