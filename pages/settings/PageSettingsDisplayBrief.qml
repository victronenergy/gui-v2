/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

Page {
	id: root

	readonly property string activeBatteryName: availableBatteryServices.mapObject[activeBatteryService.value] ?? ""

	function _levelOptionModel(selectedCenterGaugeType, selectedCenterGaugeValue) {
		let optionModel = [ { display: CommonWords.none_option, value: "" + VenusOS.Tank_Type_None, section: "" } ]
		let tankModel

		// Add tank aggregate options for all tank types on the system, or for the currently
		// selected tank type, if one is selected.
		for (tankModel of Global.tanks.allTankModels) {
			if (tankModel.count > 0
					|| (selectedCenterGaugeType === VenusOS.BriefView_CentralGauge_TankAggregate &&
						parseInt(selectedCenterGaugeValue) === tankModel.type)) {
				optionModel.push({
					display: Gauges.tankProperties(tankModel.type).name,
					value: "" + tankModel.type,
					//% "Tank totals"
					section: qsTrId("settings_briefview_totals")
				})
			}
		}

		// Add individual battery options.
		const batteryList = batteriesItem.value ?? []
		let foundSelectedBattery = false
		for (const battery of batteryList) {
			_addBatteryGaugeOption(optionModel, battery.id, battery.name || battery.id, "")
			if (!foundSelectedBattery
					&& selectedCenterGaugeType === VenusOS.BriefView_CentralGauge_BatteryId
					&& selectedCenterGaugeValue === battery.id) {
				foundSelectedBattery = true
			}
		}
		if (!foundSelectedBattery
				&& selectedCenterGaugeType === VenusOS.BriefView_CentralGauge_BatteryId) {
			// Add the selected battery as an option, even if it is not in the /Batteries list.
			const batteryId = selectedCenterGaugeValue
			//% "Battery is not connected."
			_addBatteryGaugeOption(optionModel, batteryId, batteryId, qsTrId("settings_briefview_battery_not_connected"))
		}

		// Add individual tank options
		let foundSelectedTank = false
		for (tankModel of Global.tanks.allTankModels) {
			for (let i = 0; i < tankModel.count; ++i) {
				const tank = tankModel.deviceAt(i)
				const portableId = BackendConnection.serviceUidToPortableId(tank.serviceUid, tank.deviceInstance)
				_addTankGaugeOption(optionModel, `${tank.name} [${tank.deviceInstance}]`, portableId, "")
				if (!foundSelectedTank
						&& selectedCenterGaugeType === VenusOS.BriefView_CentralGauge_TankId
						&& selectedCenterGaugeValue === portableId) {
					foundSelectedTank = true
				}
			}
		}
		if (!foundSelectedTank
				&& selectedCenterGaugeType === VenusOS.BriefView_CentralGauge_TankId) {
			const tankId = selectedCenterGaugeValue
			//% "Tank is not connected."
			_addTankGaugeOption(optionModel, tankId, tankId, qsTrId("settings_briefview_tank_not_connected"))
		}

		return optionModel
	}

	function _addBatteryGaugeOption(levelOptionModel, batteryId, name, caption) {
		const isActiveBattery = batteryId === activeBatteryService.value
		levelOptionModel.push({
			display: name,
			value: isActiveBattery ? VenusOS.Tank_Type_Battery : batteryId,
			//% "Active battery monitor"
			secondaryText: isActiveBattery ? qsTrId("settings_briefview_active_battery_monitor") : "",
			caption: caption,
			//% "Individual batteries"
			section: qsTrId("settings_briefview_individual_batteries")
		})
	}

	function _addTankGaugeOption(levelOptionModel, tankName, serviceId, caption) {
		levelOptionModel.push({
			display: tankName,
			value: serviceId,
			caption: caption,
			//% "Individual tanks"
			section: qsTrId("settings_briefview_individual_tanks")
		})
	}

	function _findSelectedLevel(levelOptionModel, selectedCenterGaugeType, selectedCenterGaugeValue) {
		for (let i = 0; i < levelOptionModel.length; ++i) {
			switch (selectedCenterGaugeType) {
			case VenusOS.BriefView_CentralGauge_None:
				return 0 // "None" is the first item in the option model
			case VenusOS.BriefView_CentralGauge_BatteryId:
				const batteryId = selectedCenterGaugeValue
				if (levelOptionModel[i].value === batteryId) {
					return i
				}
				break
			case VenusOS.BriefView_CentralGauge_SystemBattery:
				if (levelOptionModel[i].value === VenusOS.Tank_Type_Battery) {
					return i
				}
				break
			case VenusOS.BriefView_CentralGauge_TankAggregate:
				const tankTypeAsString = "" + selectedCenterGaugeValue
				if (levelOptionModel[i].value === tankTypeAsString) {
					return i
				}
				break
			case VenusOS.BriefView_CentralGauge_TankId:
				const tankServiceId = selectedCenterGaugeValue
				if (levelOptionModel[i].value === tankServiceId) {
					return i
				}
				break
			default:
				// No option has been selected
				return -1
			}
		}
		return -1
	}

	GradientListView {
		model: Theme.geometry_briefPage_centerGauge_maximumGaugeCount
		delegate: ListNavigation {
			id: levelDelegate

			required property int index
			readonly property var modelData: Global.systemSettings.briefView.centralGauges[index]
			readonly property int centerGaugeType: modelData?.centerGaugeType ?? -1
			readonly property var centerGaugeValue: modelData?.value ?? ""

			readonly property Tank _device: {
				if (centerGaugeType === VenusOS.BriefView_CentralGauge_TankId) {
					const tankIdInfo = BackendConnection.portableIdInfo(levelDelegate.centerGaugeValue)
					for (const tankModel of Global.tanks.allTankModels) {
						const tank = tankModel.deviceForDeviceInstance(tankIdInfo.instance)
						if (tank) {
							return tank
						}
					}
				}
				return null
			}

			readonly property string batteryName: {
				if (levelDelegate.centerGaugeType === VenusOS.BriefView_CentralGauge_BatteryId) {
					if (batteriesItem.valid) {
						const batteryList = batteriesItem.value
						const batteryId = levelDelegate.centerGaugeValue
						for (const battery of batteryList) {
							if (battery.id === batteryId) {
								return battery.name || ""
							}
						}
					}
				}
				return ""
			}

			//: Level number
			//% "Level %1"
			text: qsTrId("settings_briefview_level").arg(index + 1)
			secondaryText: {
				switch (centerGaugeType) {
				case VenusOS.BriefView_CentralGauge_None:
					return CommonWords.none_option
				case VenusOS.BriefView_CentralGauge_BatteryId:
					//% "Battery not connected"
					return batteryName || qsTrId("settings_briefview_unconnected_battery")
				case VenusOS.BriefView_CentralGauge_SystemBattery:
					return root.activeBatteryName
				case VenusOS.BriefView_CentralGauge_TankAggregate:
					return Gauges.tankProperties(parseInt(centerGaugeValue))?.name ?? ""
				case VenusOS.BriefView_CentralGauge_TankId:
					return _device
						? _device.name
						  //% "Tank not connected"
						: qsTrId("settings_briefview_unconnected_tank")
				default:
					//: No option has been selected
					//% "Not configured"
					return qsTrId("settings_briefview_not_configured")
				}
			}
			secondaryLabel.color: (centerGaugeType === VenusOS.BriefView_CentralGauge_BatteryId && batteryName.length === 0)
					|| (centerGaugeType === VenusOS.BriefView_CentralGauge_TankId && !_device)
				? Theme.color_red
				: Theme.color_listItem_secondaryText

			onClicked: {
				const optionModel = root._levelOptionModel(centerGaugeType, centerGaugeValue)
				Global.pageManager.pushPage(deviceOptionsComponent, {
					levelIndex: index,
					title: text,
					optionModel: optionModel,
					currentIndex: root._findSelectedLevel(optionModel, centerGaugeType, centerGaugeValue),
				})
			}
		}

		footer: SettingsColumn {
			topPadding: Theme.geometry_gradientList_spacing
			width: parent.width

			ListRadioButtonGroup {
				//% "Tank details"
				text: qsTrId("settings_briefview_tank_details")
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

			ListBriefCenterDetails {
				activeBatteryName: root.activeBatteryName
			}
		}
	}

	Component {
		id: deviceOptionsComponent

		RadioButtonListPage {
			id: deviceOptionsPage

			required property int levelIndex

			optionView.section.property: "section"
			optionView.section.delegate: SettingsListHeader {
				required property string section

				bottomPadding: Theme.geometry_gradientList_spacing
				text: section
			}

			onOptionClicked: (index, value) => {
				levelItem.setValue(value)
			}

			VeQuickItem {
				id: levelItem
				uid: Global.systemSettings.serviceUid + "/Settings/Gui2/BriefView/Level/" + deviceOptionsPage.levelIndex
			}
		}
	}

	VeQuickItem {
		id: activeBatteryService
		uid: Global.system.serviceUid + "/ActiveBatteryService"
	}

	VeQuickItem {
		id: availableBatteryServices

		property var mapObject: ({})

		uid: Global.system.serviceUid + "/AvailableBatteryServices"
		onValueChanged: {
			try {
				mapObject = JSON.parse(value)
			} catch (e) {
				console.warn("Unable to parse JSON:", value, "exception:", e)
			}
		}
	}

	VeQuickItem {
		id: batteriesItem
		uid: Global.system.serviceUid + "/Batteries"
	}
}
