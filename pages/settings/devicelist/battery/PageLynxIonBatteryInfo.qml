/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
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

	VeQuickItem {
		id: temperatureItem
		uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Temperature"
	}
	VeQuickItem {
		id: currentItem
		uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Current"
	}
	VeQuickItem {
		id: voltageItem
		uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Voltage"
	}
	VeQuickItem {
		id: statusItem
		uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Status"
	}
	VeQuickItem {
		id: fwVersionItem
		uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/FwVersion"
	}
	VeQuickItem {
		id: capacityItem
		uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Capacity"
	}
	VeQuickItem {
		id: serialItem
		uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Serial"
	}

	function computeOptions() {
		const options = [];
		for (let i = 0; i < nrOfBatteries.value; i++) {
			const item = batterySerialInstantiator.objectAt(i);
			options.push({
				display: item && item.valid && item.value
					//: %1 = battery number, %2 = battery name
					//% "Battery #%1 [%2]"
					? qsTrId("lynxionbatteryinfo_battery_number_with_serial").arg(i + 1).arg(item.value)
					//: %1 = battery number
					//% "Battery #%1"
					: qsTrId("lynxionbatteryinfo_battery_number").arg(i + 1),
				value: i + 1
			});
		}

		batteryOptions = options;
	}

	Instantiator {
		id: batterySerialInstantiator
		model: nrOfBatteries.value

		delegate: VeQuickItem {
			uid: root.bindPrefix + "/Battery/" + (index + 1) + "/Serial"
			onValueChanged: computeOptions()
		}

		onObjectAdded: computeOptions()
		onObjectRemoved: computeOptions()
	}

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				ListRadioButtonGroup {
					text: CommonWords.battery
					dataItem.uid: batteryRequestId.uid
					optionModel: batteryOptions
				}
			}

			DelegateComponent {
				SectionHeader {
					//% "Battery Info"
					text: qsTrId("lynxionbatteryinfo_battery_info_section_header")
				}
			}

			DelegateComponent {
				preferredVisible: serialItem.valid
				ListText {
					text: CommonWords.serial_number
					secondaryText: dataItem.value || ""
					dataItem.uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Serial"
				}
			}

			DelegateComponent {
				preferredVisible: capacityItem.valid
				ListQuantity {
					//% "Capacity"
					text: qsTrId("lynxionsystem_capacity")
					dataItem.uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Capacity"
					unit: VenusOS.Units_AmpHour
				}
			}

			DelegateComponent {
				preferredVisible: fwVersionItem.valid
				ListText {
					text: CommonWords.firmware_version
					secondaryText: FirmwareVersion.versionText(dataItem.value)
					dataItem.uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/FwVersion"
				}
			}

			DelegateComponent {
				preferredVisible: statusItem.valid
				ListText {
					text: CommonWords.status
					secondaryText: VenusOS.battery_statusToText(dataItem.value)
					dataItem.uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Status"
				}
			}

			DelegateComponent {
				SectionHeader {
					//% "Battery Measurements"
					text: qsTrId("lynxionbatteryinfo_battery_measurements_section_header")
				}
			}

			DelegateComponent {
				preferredVisible: voltageItem.valid
				ListQuantity {
					text: CommonWords.voltage
					dataItem.uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Voltage"
					unit: VenusOS.Units_Volt_DC
				}
			}

			DelegateComponent {
				preferredVisible: currentItem.valid
				ListQuantity {
					text: CommonWords.current_amps
					dataItem.uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Current"
					unit: VenusOS.Units_Amp
				}
			}

			DelegateComponent {
				preferredVisible: temperatureItem.valid
				ListTemperature {
					text: CommonWords.temperature
					dataItem.uid: root.bindPrefix + "/Battery/" + batteryRequestId.value + "/Temperature"
				}
			}

			DelegateComponent {
				SectionHeader {
					//% "Cell Measurements"
					text: qsTrId("lynxionbatteryinfo_cell_measurements_section_header")
				}
			}

			DelegateComponent {
				SettingsFlow {
					width: parent ? parent.width : 0
					spacing: Theme.geometry_gradientList_spacing
					leftPadding: Theme.geometry_page_content_horizontalMargin
					rightPadding: Theme.geometry_page_content_horizontalMargin

					Repeater {
						model: nrOfCellsPerBattery.value

						delegate: ListQuantityGroup {
							required property int index
							property int cellIndex: index + 1

							width: Theme.screenSize === Theme.Portrait
								// In portrait, show all cells in a single column.
								? parent.width - (2 * Theme.geometry_page_content_horizontalMargin)
								// In landscape, show two cells per row.
								: (parent.width - 2*Theme.geometry_page_content_horizontalMargin - Theme.geometry_gradientList_spacing) / 2
							rightInset: 0
							leftInset: 0
							bottomInset: 0

							//% "Cell #%1"
							text: qsTrId("lynxionbatteryinfo_cell_number").arg(cellIndex)
							model: QuantityObjectModel {
								filterType: QuantityObjectModel.HasValue

								QuantityObject { object: cellVoltage; unit: VenusOS.Units_Volt_DC; decimals: 3 }
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