/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string cgwacsPath: Global.systemSettings.serviceUid + "/Settings/CGwacs"

	VeQuickItem {
		id: stateItem
		uid: root.cgwacsPath + "/BatteryLife/State"
	}

	VeQuickItem {
		id: withoutGridMeterItem
		uid: root.cgwacsPath + "/RunWithoutGridMeter"
	}

	VeQuickItem {
		id: peakshaveItem
		uid: root.cgwacsPath + "/AlwaysPeakShave"
	}

	VeQuickItem {
		id: systemAcExportLimit
		uid: root.cgwacsPath + "/AcExportLimit"
	}

	VeQuickItem {
		id: systemAcInputLimit
		uid: root.cgwacsPath + "/AcInputLimit"
	}

	VeQuickItem {
		id: overruledShoreLimit
		uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Hub4/L1/OverruledShoreLimit" : ""
	}

	GradientListView {
		model: VisibleItemModel {
			ListRadioButtonGroup {
				//% "Peak shaving"
				text: qsTrId("settings_ess_peak_shaving")
				interactive: !(stateItem.value === VenusOS.Ess_BatteryLifeState_KeepCharged && withoutGridMeterItem.value === 1)
				optionModel: [
					{
						//% "Above minimum SOC only"
						display: qsTrId("settings_ess_above_minimum_soc_only"),
						value: 0,
						//% "Use this option in systems that do not perform peak shaving."
						caption: qsTrId("settings_ess_use_this_option_for_systems_no_peak_shaving")
					},
					{
						//% "Always"
						display: qsTrId("settings_ess_always"),
						value: 1,
						//% "Use this option for peak shaving."
						caption: qsTrId("settings_ess_use_this_option_for_peak_shaving")
					}
				]
				currentIndex: !enabled ? 1 : peakshaveItem.value || 0
				onOptionClicked: function(index) {
					const newValue = optionModel[index].value
					peakshaveItem.setValue(newValue)
					if (newValue === 1) {
						if (withoutGridMeterItem.value == 1) {
							//% "The peak shaving threshold is set using the AC input current limit setting. See documentation for further information."
							Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_ess_use_this_option_for_peak_shaving_no_grid_meter"), 10000)
						} else {
							//% "The peak shaving thresholds for import and export can be changed on this screen. See documentation for further information."
							Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_ess_use_this_option_for_peak_shaving_with_grid_meter"), 10000)
						}
					}
				}
			}

			ListSwitch {
				id: maxSystemAcInputCurrentSwitch

				//% "Limit system AC import current"
				text: qsTrId("settings_ess_limit_system_ac_import_current")
				checkable: true
				checked: systemAcInputLimit.value >= 0
				interactive: withoutGridMeterItem.value === 0 && overruledShoreLimit.seen
				onCheckedChanged: {
					if (checked && systemAcInputLimit.value < 0) {
						systemAcInputLimit.setValue(40)
					} else if (!checked && systemAcInputLimit.value >= 0) {
						systemAcInputLimit.setValue(-1)
					}
				}
				caption: maxSystemAcInputCurrentSwitch.enabled
							  ? ""
								//% "To use this feature, Grid metering must be set to External meter, and an up to date ESS assistant must be installed."
							  : qsTrId("settings_ess_limit_ac_import_restrictions")
			}

			ListSpinBox {
				//% "Maximum system import current (per phase)"
				text: qsTrId("settings_ess_max_system_import_current")
				preferredVisible: maxSystemAcInputCurrentSwitch.enabled && maxSystemAcInputCurrentSwitch.checked
				dataItem.uid: systemAcInputLimit.uid
				suffix: Units.defaultUnitString(VenusOS.Units_Amp)
				decimals: 0
				from: 5
				to: 5000
				stepSize: 1
			}

			ListSwitch {
				id: maxSystemAcExportCurrentSwitch

				//% "Limit system AC export current"
				text: qsTrId("settings_ess_limit_system_ac_export_current")
				checkable: true
				checked: systemAcExportLimit.value >= 0
				interactive: withoutGridMeterItem.value === 0
				onCheckedChanged: {
					if (checked && systemAcExportLimit.value < 0) {
						systemAcExportLimit.setValue(40)
					} else if (!checked && systemAcExportLimit.value >= 0) {
						systemAcExportLimit.setValue(-1)
					}
				}
				caption: maxSystemAcExportCurrentSwitch.enabled
							  ? ""
								//% "Grid metering must be set to External meter to use this feature."
							  : qsTrId("settings_ess_limit_ac_export_restrictions")
			}

			ListSpinBox {
				//% "Maximum system export current (per phase)"
				text: qsTrId("settings_ess_max_system_export_current")
				preferredVisible: maxSystemAcExportCurrentSwitch.enabled && maxSystemAcExportCurrentSwitch.checked
				dataItem.uid: systemAcExportLimit.uid
				suffix: Units.defaultUnitString(VenusOS.Units_Amp)
				decimals: 0
				from: 5
				to: 5000
				stepSize: 1
			}
		}
	}
}
