/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string outputUid

	readonly property bool _writeable: !(settingsAdjustable.valid && settingsAdjustable.value === 0)

	VeQuickItem {
		id: outputLimitMaxItem
		uid: switchableOutput.uid + "/Settings/OutputLimitMax"
	}
	VeQuickItem {
		id: outputLimitMinItem
		uid: switchableOutput.uid + "/Settings/OutputLimitMin"
	}
	VeQuickItem {
		id: polarityItem
		uid: switchableOutput.uid + "/Settings/Polarity"
	}
	VeQuickItem {
		id: startupStateItem
		uid: switchableOutput.uid + "/Settings/StartupState"
	}
	VeQuickItem {
		id: currentItem
		uid: switchableOutput.uid + "/Current"
	}
	VeQuickItem {
		id: voltageItem
		uid: switchableOutput.uid + "/Voltage"
	}
	VeQuickItem {
		id: functionItem
		uid: switchableOutput.uid + "/Settings/Function"
	}
	VeQuickItem {
		id: fuseRatingItem
		uid: switchableOutput.uid + "/Settings/FuseRating"
	}
	VeQuickItem {
		id: fuseDetectionItem
		uid: switchableOutput.uid + "/Settings/FuseDetection"
	}
	VeQuickItem {
		id: dimModeItem
		uid: switchableOutput.uid + "/Settings/DimMode"
	}
	VeQuickItem {
		id: switchModeItem
		uid: switchableOutput.uid + "/Settings/SwitchMode"
	}
	VeQuickItem {
		id: productId

		readonly property bool isAurelia: valid && (value === ProductInfo.ProductId_Dcdb_Aurelia)

		uid: switchableOutput.serviceUid + "/ProductId"
	}
	VeQuickItem {
		id: startupDimLevelItem
		uid: switchableOutput.uid + "/Settings/StartupDimming"
	}
	VeQuickItem {
		id: settingsAdjustable
		uid: switchableOutput.uid + "/Settings/Adjustable"
	}

	SwitchableOutput {
		id: switchableOutput
		uid: root.outputUid
	}

	// For Aurelia products, some settings are not visible at the user-access level. For now, hard
	// code this configuration in gui-v2, but later on we will generalise this to configure the
	// setting visibility in the backend data values instead. See #2941.
	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				ListIOChannelNameField {
					dataItem.uid: switchableOutput.uid + "/Settings/CustomName"
					interactive: _writeable
				}
			}

			DelegateComponent {
				ListIOChannelGroupField {
					dataItem.uid: switchableOutput.uid + "/Settings/Group"
					interactive: _writeable
				}
			}

			DelegateComponent {
				preferredVisible: switchModeItem.valid
				ListRadioButtonGroup {
					id: switchMode

					//% "Switch mode"
					text: qsTrId("page_switchable_output_switch_mode")
					dataItem.uid: switchableOutput.uid + "/Settings/SwitchMode"
					showAccessLevel: productId.isAurelia ? VenusOS.User_AccessType_Installer : VenusOS.User_AccessType_User
					interactive: _writeable
					optionModel: [
						//% "Disabled"
						{ display: qsTrId("page_switchable_output_switch_mode_disabled"), value: VenusOS.SwitchableOutput_SwitchMode_Disabled },
						//% "Permanent on"
						{ display: qsTrId("page_switchable_output_switch_mode_linear"), value: VenusOS.SwitchableOutput_SwitchMode_PermanentOn },
						//% "Switching"
						{ display: qsTrId("page_switchable_output_switch_mode_optical"), value: VenusOS.SwitchableOutput_SwitchMode_Switching }
					]
				}
			}

			DelegateComponent {
				preferredVisible: dimModeItem.valid
				ListRadioButtonGroup {
					//% "Dim mode"
					text: qsTrId("page_switchable_output_dim_mode")
					dataItem.uid: switchableOutput.uid + "/Settings/DimMode"
					showAccessLevel: productId.isAurelia ? VenusOS.User_AccessType_Installer : VenusOS.User_AccessType_User
					interactive: _writeable
					optionModel: [
						//% "Dimming disabled"
						{ display: qsTrId("page_switchable_output_dim_mode_disabled"), value: 0 },
						//% "Linear"
						{ display: qsTrId("page_switchable_output_dim_mode_linear"), value: 1 },
						//% "Optical curve"
						{ display: qsTrId("page_switchable_output_dim_mode_optical"), value: 2 }
					]
				}
			}

			DelegateComponent {
				preferredVisible: fuseDetectionItem.valid
				ListRadioButtonGroup {
					//% "Fuse detection mode"
					text: qsTrId("page_switchable_output_fuse_detection_mode")
					dataItem.uid: switchableOutput.uid + "/Settings/FuseDetection"
					showAccessLevel: productId.isAurelia ? VenusOS.User_AccessType_Installer : VenusOS.User_AccessType_User
					interactive: _writeable
					optionModel: [
						{ display: CommonWords.disabled, value: 0 },
						{ display: CommonWords.enabled, value: 1 },
						//% "Only when the output is off"
						{ display: qsTrId("page_switchable_output_fuse_detection_mode_only_when_off"), value: 2, readOnly: switchModeItem.value === VenusOS.SwitchableOutput_SwitchMode_PermanentOn }
					]
				}
			}

			DelegateComponent {
				preferredVisible: fuseRatingItem.valid
				ListSpinBox {
					//% "Fuse rating"
					text:  qsTrId("page_switchable_output_fuse_rating")
					dataItem.uid: switchableOutput.uid + "/Settings/FuseRating"
					decimals: 0 // backend does not allow for decimal precision
					suffix: Units.defaultUnitString(VenusOS.Units_Amp)
					showAccessLevel: productId.isAurelia ? VenusOS.User_AccessType_Installer : VenusOS.User_AccessType_User
					interactive: _writeable
				}
			}

			DelegateComponent {
				ListIOChannelTypeRadioButtonGroup {
					ioChannel: switchableOutput
					interactive: hasSelectableType && _writeable
				}
			}

			DelegateComponent {
				preferredVisible: functionItem.valid
						&& (switchableOutput.validFunctions !== (1 << VenusOS.SwitchableOutput_Function_Manual))
				ListRadioButtonGroup {
					//% "Function"
					text: qsTrId("page_switchable_output_function")
					dataItem.uid: switchableOutput.uid + "/Settings/Function"
					showAccessLevel: productId.isAurelia ? VenusOS.User_AccessType_Installer : VenusOS.User_AccessType_User
					secondaryTextColor: switchableOutput.hasValidFunction ? Theme.color_listItem_secondaryText : Theme.color_critical
					optionModel: {
						let options = []
						for (let i = 0; i <= VenusOS.SwitchableOutput_Function_MaxSupportedType; i++) {
							if (switchableOutput.validFunctions & (1 << i)) {
								options.push({ display: VenusOS.switchableOutput_functionToText(i), value: i })
							}
						}
						return options
					}
					interactive: _writeable && (optionModel.length > 1 || !switchableOutput.hasValidFunction)

					// Set the fallback text explicitly, in case the output Function is not supported by its
					// ValidFunctions, which means the current Function is not one of the listed options and
					// thus cannot be displayed by ListRadioButtonGroup.
					defaultSecondaryText: VenusOS.switchableOutput_functionToText(switchableOutput.function)
				}
			}

			DelegateComponent {
				ListIOChannelShowRadioButtonGroup {
					dataItem.uid: switchableOutput.uid + "/Settings/ShowUIControl"
					interactive: _writeable
				}
			}

			DelegateComponent {
				preferredVisible: voltageItem.valid
				ListQuantity {
					text: CommonWords.voltage
					dataItem.uid: switchableOutput.uid + "/Voltage"
					interactive: _writeable
					unit: VenusOS.Units_Volt_DC
				}
			}

			DelegateComponent {
				preferredVisible: currentItem.valid
				ListQuantity {
					text: CommonWords.current_amps
					dataItem.uid: switchableOutput.uid + "/Current"
					interactive: _writeable
					unit: VenusOS.Units_Amp
				}
			}

			DelegateComponent {
				preferredVisible: startupStateItem.valid
				ListRadioButtonGroup {
					//% "Startup switch state"
					text: qsTrId("page_switchable_output_startup_state")
					dataItem.uid: switchableOutput.uid + "/Settings/StartupState"
					showAccessLevel: productId.isAurelia ? VenusOS.User_AccessType_Installer : VenusOS.User_AccessType_User
					interactive: _writeable
					optionModel: [
						{ display: CommonWords.off, value: 0 },
						{ display: CommonWords.on, value: 1 },
						//% "Restore from memory"
						{ display: qsTrId("page_switchable_output_startup_state_restore_from_memory"), value: -1 }
					]
				}
			}

			DelegateComponent {
				id: startupDimLevelDC
				dataItem: startupDimLevelItem
				preferredVisible: startupDimLevelDC.dataItem.valid
				ListNavigation {
					//% "Startup dim level"
					text: qsTrId("page_switchable_output_startup_dim_level")
					secondaryText: startupDimLevelItem.valid
						? startupDimLevelItem.value === -1
							? qsTrId("page_switchable_output_startup_state_restore_from_memory")
							: startupDimLevelItem.value + "%"
						: ""
					showAccessLevel: productId.isAurelia ? VenusOS.User_AccessType_Installer : VenusOS.User_AccessType_User
					interactive: _writeable
					onClicked: Global.pageManager.pushPage(dimStartupStateComponent, { title: text })

					Component {
						id: dimStartupStateComponent
						Page {
							GradientListView {
								id: settingsListView

								model: DelegateComponentModel {
									DelegateComponent {
										ListSwitch {
											id: restoreDimLevelSwitch
											//% "Restore dim level from memory"
											text: qsTrId("page_switchable_output_restore_dim_level")
											checked: startupDimLevelItem.value === -1
											interactive: _writeable
											onClicked: {
												startupDimLevelItem.setValue(checked ? -2 : -1)
											}
										}
									}

									DelegateComponent {
										preferredVisible: startupDimLevelDC.dataItem.valid && startupDimLevelItem.value >= 0
										ListSpinBox {

											//% "Startup dim level"
											text: qsTrId("settings_dvcc_startup_dim_level")
											from: 0
											to: 100
											suffix: "%"
											decimals: 0
											dataItem.uid: startupDimLevelItem.uid
										}
									}
								}
							}
						}
					}
				}
			}

			DelegateComponent {
				preferredVisible: polarityItem.valid
				ListRadioButtonGroup {
					//% "Polarity"
					text: qsTrId("page_switchable_output_polarity")
					dataItem.uid: switchableOutput.uid + "/Settings/Polarity"
					showAccessLevel: productId.isAurelia ? VenusOS.User_AccessType_Installer : VenusOS.User_AccessType_User
					interactive: _writeable
					optionModel: [
						//% "Normal"
						{ display: qsTrId("page_switchable_output_polarity_normal"), value: 0 },
						//% "Inverted"
						{ display: qsTrId("page_switchable_output_polarity_inverted"), value: 1 }
					]
				}
			}

			DelegateComponent {
				preferredVisible: outputLimitMinItem.valid
				ListSpinBox {
					//% "Output limit min"
					text: qsTrId("settings_dvcc_output_limit_min")
					showAccessLevel: productId.isAurelia ? VenusOS.User_AccessType_Installer : VenusOS.User_AccessType_User
					interactive: _writeable
					from: 0
					to: 100
					decimals: 2
					suffix: "%"
					dataItem.uid: switchableOutput.uid + "/Settings/OutputLimitMin"
				}
			}

			DelegateComponent {
				preferredVisible: outputLimitMaxItem.valid
				ListSpinBox {
					//% "Output limit max"
					text: qsTrId("settings_dvcc_output_limit_max")
					showAccessLevel: productId.isAurelia ? VenusOS.User_AccessType_Installer : VenusOS.User_AccessType_User
					interactive: _writeable
					from: 0
					to: 100
					decimals: 2
					suffix: "%"
					dataItem.uid: switchableOutput.uid + "/Settings/OutputLimitMax"
				}
			}
		}
	}
}