/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	property var batterySerialItems: []
	property var batteryOptions: []

	VeQuickItem {
		id: batteryRequestId
		uid: root.bindPrefix + "/Battery/Request/Id"
	}

	VeQuickItem {
		id: nrOfBatteries
		uid: root.bindPrefix + "/System/NrOfBatteries"
	}

	VeQuickItem {
		id: nrOfCellsPerBattery
		uid: root.bindPrefix + "/System/NrOfCellsPerBattery"
	}

	Component {
		id: serialItemComponent

		VeQuickItem {
			// uid set from createObject
		}
	}

	function computeSerialItems() {
		for (let i = 0; i < batterySerialItems.length; i++) {
			batterySerialItems[i].destroy();
		}
		batterySerialItems = [];

		for (let i = 0; i < nrOfBatteries.value; i++) {
			const item = serialItemComponent.createObject(root, {
				uid: root.bindPrefix + "/Battery/" + (i + 1) + "/Serial"
			});
			item.valueChanged.connect(computeOptions);
			batterySerialItems.push(item);
		}

		computeOptions();
	}

	function computeOptions() {
		const options = [];
		for (let i = 0; i < nrOfBatteries.value; i++) {
			const item = batterySerialItems[i];
			options.push({
				display: item && item.valid && item.value
					? /*% "Battery #%1 [%2]" */qsTrId("lynxionbatteryinfo_battery_number_with_serial").arg(i + 1).arg(item.value)
					: /*% "Battery #%1" */qsTrId("lynxionbatteryinfo_battery_number").arg(i + 1),
				value: i + 1
			});
		}

		batteryOptions = options;
	}

	Connections {
		target: nrOfBatteries
		function onValueChanged() {
			computeSerialItems();
		}
	}

	Component.onCompleted: computeSerialItems()

	GradientListView {
		model: VisibleItemModel {
			ListRadioButtonGroup {
				text: CommonWords.battery
				dataItem.uid: batteryRequestId.uid
				optionModel: batteryOptions
				popDestination: root
			}

			SectionHeader {
				//% "Battery Info"
				text: qsTrId("lynxionbatteryinfo_battery_info_section_header")
			}

			ListText {
				text: CommonWords.serial_number
				secondaryText: dataItem.value || ""
				dataItem.uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Serial"
				preferredVisible: dataItem.valid
			}

			ListQuantity {
				//% "Capacity"
				text: qsTrId("lynxionsystem_capacity")
				dataItem.uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Capacity"
				unit: VenusOS.Units_AmpHour
				preferredVisible: dataItem.valid
			}

			ListText {
				text: CommonWords.firmware_version
				secondaryText: FirmwareVersion.versionText(dataItem.value)
				dataItem.uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/FwVersion"
				preferredVisible: dataItem.valid
			}

			ListText {
				text: CommonWords.status
				secondaryText: VenusOS.battery_statusToText(dataItem.value)
				dataItem.uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Status"
				preferredVisible: dataItem.valid
			}

			SectionHeader {
				//% "Battery Measurements"
				text: qsTrId("lynxionbatteryinfo_battery_measurements_section_header")
			}

			ListQuantity {
				text: CommonWords.voltage
				dataItem.uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Voltage"
				unit: VenusOS.Units_Volt_DC
				preferredVisible: dataItem.valid
			}

			ListQuantity {
				text: CommonWords.current_amps
				dataItem.uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Current"
				unit: VenusOS.Units_Amp
				preferredVisible: dataItem.valid
			}

			ListTemperature {
				text: CommonWords.temperature
				dataItem.uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Temperature"
				preferredVisible: dataItem.valid
			}

			SectionHeader {
				//% "Cell Measurements"
				text: qsTrId("lynxionbatteryinfo_cell_measurements_section_header")
			}

			SettingsColumn {
				width: parent ? parent.width : 0

				Repeater {
					model: Math.ceil(nrOfCellsPerBattery.value / 2)

					delegate: Row {
						width: parent.width
						spacing: Theme.geometry_gradientList_spacing

						property int rowIndex: index * 2 + 1

						Repeater {
							model: 2

							delegate: ListQuantityGroup {
								width: parent.width / 2 - (Theme.geometry_gradientList_spacing / 2)

								property int cellIndex: rowIndex + index

								//% "Cell #%1"
								text: qsTrId("lynxionbatteryinfo_cell_number").arg(cellIndex)
								model: QuantityObjectModel {
									filterType: QuantityObjectModel.HasValue

									QuantityObject { object: cellVoltage; unit: VenusOS.Units_Volt_DC }
									QuantityObject { object: cellTemperature; unit: Global.systemSettings.temperatureUnit }
								}
								preferredVisible: cellVoltage.valid

								VeQuickItem {
									id: cellVoltage
									uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Cell/" + cellIndex + "/Voltage"
								}

								VeQuickItem {
									id: cellTemperature
									uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Cell/" + cellIndex + "/Temperature"
									sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
									displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
								}
							}
						}
					}
				}
			}
		}
	}
}
