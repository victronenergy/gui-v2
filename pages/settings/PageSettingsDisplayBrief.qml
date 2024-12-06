/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQml.Models
import Victron.VenusOS
import Victron.Gauges

Page {
	id: root

	ObjectModel {
		id: settingsModel
		ListRadioButtonGroup {
			//: Whether to show a value in the center of the circular gauges
			//% "Center value display"
			text: qsTrId("settings_briefview_centervalue_display")
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/BriefView/CenterValueDisplay"
			updateDataOnClick: false // don't update data automatically.
			optionModel: [
				//% "No center value displayed"
				{ "display": qsTrId("settings_briefview_centervalue_display_none"), "value": VenusOS.BriefView_CenterValue_NotDisplayed },
				//% "Display in single gauge mode"
				{ "display": qsTrId("settings_briefview_centervalue_display_singlegaugeonly"), "value": VenusOS.BriefView_CenterValue_SingleGaugeOnly },
				//% "Display in single or double gauge mode"
				{ "display": qsTrId("settings_briefview_centervalue_display_lessthanthreegauges"), "value": VenusOS.BriefView_CenterValue_SingleOrDoubleGauge },
				//% "Display in all except four-gauge mode"
				{ "display": qsTrId("settings_briefview_centervalue_display_lessthanfourgauges"), "value": VenusOS.BriefView_CenterValue_SingleDoubleOrTripleGauge }
			]
			defaultIndex: 3 // VenusOS.BriefView_CenterValue_SingleDoubleOrTripleGauge

			onOptionClicked: (index) => {
				dataItem.setValue(optionModel[index].value)
			}
		}

		ListRadioButtonGroup {
			//: Whether to show a descriptive label above the value in the center of the circular gauges
			//% "Center value label"
			text: qsTrId("settings_briefview_centervalue_labeldisplay")
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/BriefView/CenterValueLabelDisplay"
			updateDataOnClick: false // don't update data automatically.
			optionModel: [
				//% "No label displayed"
				{ "display": qsTrId("settings_briefview_centervalue_labeldisplay_none"), "value": VenusOS.BriefView_CenterValue_NotDisplayed },
				//% "Display in single gauge mode"
				{ "display": qsTrId("settings_briefview_centervalue_labeldisplay_singlegaugeonly"), "value": VenusOS.BriefView_CenterValue_SingleGaugeOnly },
				//% "Display in single or double gauge mode"
				{ "display": qsTrId("settings_briefview_centervalue_labeldisplay_lessthanthreegauges"), "value": VenusOS.BriefView_CenterValue_SingleOrDoubleGauge },
				//% "Always display label"
				{ "display": qsTrId("settings_briefview_centervalue_labeldisplay_lessthanfourgauges"), "value": VenusOS.BriefView_CenterValue_SingleDoubleOrTripleGauge }
			]
			defaultIndex: 3 // VenusOS.BriefView_CenterValue_SingleDoubleOrTripleGauge

			onOptionClicked: (index) => {
				dataItem.setValue(optionModel[index].value)
			}
		}

		ListRadioButtonGroup {
			id: centerValueDeviceGroup
			//: Which device value to show in the center of the circular gauges
			//% "Center value device"
			text: qsTrId("settings_briefview_centervalue_device")
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/BriefView/CenterValueDevice"
			updateDataOnClick: false // don't update data automatically.

			property var devices: []

			Instantiator {
				id: deviceInstantiator
				readonly property ServiceDeviceModel batteryDevicesModel: ServiceDeviceModel {
					id: batteryDevices
					serviceType: "battery"
					modelId: "battery"
				}
				model: AggregateDeviceModel {
					sourceModels: [
						batteryDevices,
						Global.environmentInputs.model
					]
				}
				delegate: QtObject {
					required property string cachedDeviceName
					required property BaseDevice device
					Component.onCompleted: {
						centerValueDeviceGroup.devices.push({"display": cachedDeviceName, "serviceUid": device.serviceUid})
					}
				}
			}

			VeQuickItem {
				id: activeBatteryService
				uid: Global.system.serviceUid + "/ActiveBatteryService"
			}

			onOptionClicked: (index) => {
				dataItem.setValue(devices[index].serviceUid)
			}

			currentIndex: {
				let systemBatteryIndex = -1
				let i
				for (i = 0; i < devices.length; ++i) {
					if (devices[i].serviceUid == dataItem.value) {
						return i
					}
					if (devices[i].serviceUid == activeBatteryService.value) {
						systemBatteryIndex = i
					}
				}
				return systemBatteryIndex
			}

			Component.onCompleted: {
				var tempDevices = devices
				devices = tempDevices // force update signal.
				optionModel = devices
			}
		}

		ListRadioButtonGroup {
			//: Show percentage values in Brief view
			//% "Level gauge units"
			text: qsTrId("settings_briefview_unit")
			optionModel: [
				//% "No labels"
				{ display: qsTrId("settings_briefview_unit_none"), value: VenusOS.BriefView_Unit_None },
				//% "Show tank volumes"
				{ display: qsTrId("settings_briefview_unit_absolute"), value: VenusOS.BriefView_Unit_Absolute },
				//% "Show percentages"
				{ display: qsTrId("settings_briefview_unit_percentages"), value: VenusOS.BriefView_Unit_Percentage },
			]
			dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Gui/BriefView/Unit"
		}
	}

	property var _gaugeOptionsModel: Gauges.briefCentralGauges.map(function(gaugeType) {
		const name = Gauges.tankProperties(gaugeType).name || ""
		return { display: name, value: gaugeType }
	})

	// Use this intermediate model that is built when the page loads, to avoid changing the model
	// while the radio button group sub-page is shown, as that causes the group options to be rebuilt.
	property var _gaugesModel
	onIsCurrentPageChanged: {
		if (isCurrentPage) {
			_gaugesModel = Global.systemSettings.briefView.centralGauges.value || []
		}
	}

	Instantiator {
		model: root._gaugesModel

		delegate: ListRadioButtonGroup {
			id: gaugeDelegate
			//: Level number
			//% "Level %1"
			text: qsTrId("settings_briefview_level").arg(model.index + 1)
			optionModel: root._gaugeOptionsModel
			currentIndex: {
				const savedGaugePrefs = Global.systemSettings.briefView.centralGauges.value || []
				const preferredGaugeForLevel = savedGaugePrefs[model.index]
				return Gauges.briefCentralGauges.indexOf(preferredGaugeForLevel)
			}

			onOptionClicked: function(index) {
				let savedGaugePrefs = Global.systemSettings.briefView.centralGauges.value
				if (savedGaugePrefs.length) {
					savedGaugePrefs[model.index] = optionModel[index].value
					Global.systemSettings.briefView.centralGauges.setValue(savedGaugePrefs)
				}
			}

			Component.onCompleted: settingsModel.append(gaugeDelegate)
		}
	}

	GradientListView {
		model: settingsModel
	}
}
