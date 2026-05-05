/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property SwitchableOutput switchableOutput

	readonly property bool _writeable: !(settingsAdjustable.valid && settingsAdjustable.value === 0)

	GradientListView {
		model: VisibleItemModel {
			ListIOChannelNameField {
				dataItem.uid: root.switchableOutput.uid + "/Settings/CustomName"
				interactive: _writeable
			}

			ListIOChannelGroupField {
				dataItem.uid: root.switchableOutput.uid + "/Settings/Group"
				interactive: _writeable
			}

			ListRadioButtonGroup {
				//% "Switch mode"
				text: qsTrId("page_switchable_output_switch_mode")
				dataItem.uid: root.switchableOutput.uid + "/Settings/SwitchMode"
				preferredVisible: dataItem.valid
				interactive: _writeable
				optionModel: [
					//% "Disabled"
					{ display: qsTrId("page_switchable_output_switch_mode_disabled"), value: 0 },
					//% "Permanent on"
					{ display: qsTrId("page_switchable_output_switch_mode_linear"), value: 1 },
					//% "Switching"
					{ display: qsTrId("page_switchable_output_switch_mode_optical"), value: 2 }
				]
			}

			ListRadioButtonGroup {
				//% "Dim mode"
				text: qsTrId("page_switchable_output_dim_mode")
				dataItem.uid: root.switchableOutput.uid + "/Settings/DimMode"
				preferredVisible: dataItem.valid
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

			ListRadioButtonGroup {
				//% "Fuse detection mode"
				text: qsTrId("page_switchable_output_fuse_detection_mode")
				dataItem.uid: root.switchableOutput.uid + "/Settings/FuseDetection"
				preferredVisible: dataItem.valid
				interactive: _writeable
				optionModel: [
					{ display: CommonWords.disabled, value: 0 },
					{ display: CommonWords.enabled, value: 1 },
					//% "Only when the output is off"
					{ display: qsTrId("page_switchable_output_fuse_detection_mode_only_when_off"), value: 2 }
				]
			}

			ListSpinBox {
				//% "Fuse rating"
				text:  qsTrId("page_switchable_output_fuse_rating")
				dataItem.uid: root.switchableOutput.uid + "/Settings/FuseRating"
				decimals: 0 // backend does not allow for decimal precision
				suffix: Units.defaultUnitString(VenusOS.Units_Amp)
				preferredVisible: dataItem.valid
				interactive: _writeable
			}

			ListIOChannelTypeRadioButtonGroup {
				ioChannel: root.switchableOutput
				interactive: _writeable
			}

			ListRadioButtonGroup {
				//% "Function"
				text: qsTrId("page_switchable_output_function")
				dataItem.uid: root.switchableOutput.uid + "/Settings/Function"
				preferredVisible: dataItem.valid
						&& (root.switchableOutput.validFunctions !== (1 << VenusOS.SwitchableOutput_Function_Manual))
				secondaryTextColor: root.switchableOutput.hasValidFunction ? Theme.color_listItem_secondaryText : Theme.color_critical
				optionModel: {
					let options = []
					for (let i = 0; i <= VenusOS.SwitchableOutput_Function_MaxSupportedType; i++) {
						if (root.switchableOutput.validFunctions & (1 << i)) {
							options.push({ display: VenusOS.switchableOutput_functionToText(i), value: i })
						}
					}
					return options
				}
				interactive: _writeable && (optionModel.length > 1 || !root.switchableOutput.hasValidFunction)

				// Set the fallback text explicitly, in case the output Function is not supported by its
				// ValidFunctions, which means the current Function is not one of the listed options and
				// thus cannot be displayed by ListRadioButtonGroup.
				defaultSecondaryText: VenusOS.switchableOutput_functionToText(root.switchableOutput.function)
			}

			ListIOChannelShowRadioButtonGroup {
				dataItem.uid: root.switchableOutput.uid + "/Settings/ShowUIControl"
				interactive: _writeable
			}

			ListQuantity {
				text: CommonWords.voltage
				dataItem.uid: root.switchableOutput.uid + "/Voltage"
				preferredVisible: dataItem.valid
				interactive: _writeable
				unit: VenusOS.Units_Volt_DC
			}

			ListQuantity {
				text: CommonWords.current_amps
				dataItem.uid: root.switchableOutput.uid + "/Current"
				preferredVisible: dataItem.valid
				interactive: _writeable
				unit: VenusOS.Units_Amp
			}

			ListRadioButtonGroup {
				//% "Startup switch state"
				text: qsTrId("page_switchable_output_startup_state")
				dataItem.uid: root.switchableOutput.uid + "/Settings/StartupState"
				preferredVisible: dataItem.valid
				interactive: _writeable
				optionModel: [
					{ display: CommonWords.off, value: 0 },
					{ display: CommonWords.on, value: 1 },
					//% "Restore from memory"
					{ display: qsTrId("page_switchable_output_startup_state_restore_from_memory"), value: -1 }
				]
			}

			ListNavigation {
				//% "Startup dim level"
				text: qsTrId("page_switchable_output_startup_dim_level")
				secondaryText: startupDimLevel.valid ? startupDimLevel.value === -1 ? qsTrId("page_switchable_output_startup_state_restore_from_memory") : startupDimLevel.value + "%" : ""
				preferredVisible: startupDimLevel.valid
				interactive: _writeable
				onClicked: Global.pageManager.pushPage(dimStartupStateComponent, { title: text })

				VeQuickItem {
					id: startupDimLevel
					uid: root.switchableOutput.uid + "/Settings/StartupDimming"
				}

				Component {
					id: dimStartupStateComponent
					Page {
						GradientListView {
							id: settingsListView

							model: VisibleItemModel {
								ListSwitch {
									id: restoreDimLevelSwitch
									//% "Restore dim level from memory"
									text: qsTrId("page_switchable_output_restore_dim_level")
									checked: startupDimLevel.valid && startupDimLevel.value === -1
									interactive: _writeable
									onClicked: {
										startupDimLevel.setValue(startupDimLevel.value === -1 ? 0 : -1)
									}
								}

								ListSwitch {
									id: setDimLevelManuallySwitch
									//% "Set startup dim level manually"
									text: qsTrId("page_switchable_output_set_dim_level_manually")
									checked: startupDimLevel.valid && startupDimLevel.value !== -1
									interactive: _writeable
									onClicked: {
										startupDimLevel.setValue(-2)
									}
								}

								ListSpinBox {

									//% "Startup dim level"
									text: qsTrId("settings_dvcc_startup_dim_level")
									preferredVisible: setDimLevelManuallySwitch.visible && !setDimLevelManuallySwitch.checked
									from: 0
									to: 100
									suffix: "%"
									dataItem.uid: startupDimLevel.uid
								}
							}
						}
					}
				}
			}

			ListRadioButtonGroup {
				//% "Polarity"
				text: qsTrId("page_switchable_output_polarity")
				dataItem.uid: root.switchableOutput.uid + "/Settings/Polarity"
				preferredVisible: dataItem.valid
				interactive: _writeable
				optionModel: [
					//% "Active high / Normally open"
					{ display: qsTrId("page_switchable_output_polarity_active_high"), value: 0 },
					//% "Active low / Normally closed"
					{ display: qsTrId("page_switchable_output_polarity_active_low"), value: 1 }
				]
			}

			ListSpinBox {
				//% "Output limit min"
				text: qsTrId("settings_dvcc_output_limit_min")
				preferredVisible: dataItem.valid
				interactive: _writeable
				from: 0
				to: 100
				decimals: 2
				suffix: "%"
				dataItem.uid: root.switchableOutput.uid + "/Settings/OutputLimitMin"
			}

			ListSpinBox {
				//% "Output limit max"
				text: qsTrId("settings_dvcc_output_limit_max")
				preferredVisible: dataItem.valid
				interactive: _writeable
				from: 0
				to: 100
				decimals: 2
				suffix: "%"
				dataItem.uid: root.switchableOutput.uid + "/Settings/OutputLimitMax"
			}
		}
	}

	VeQuickItem {
		id: settingsAdjustable
		uid: root.switchableOutput.uid + "/Settings/Adjustable"
	}
}
