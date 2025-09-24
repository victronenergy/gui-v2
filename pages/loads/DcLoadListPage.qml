/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property FilteredDeviceModel model

	function _showSettingsPage(device) {
		if (BackendConnection.serviceTypeFromUid(device.serviceUid) === "dcdc") {
			Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcDcConverter.qml",
					{ "bindPrefix": device.serviceUid })
		} else {
			  Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcMeter.qml",
					{ "bindPrefix": device.serviceUid })
		}
	}

	Component.onCompleted: {
		console.log("test model count: " + systemDevices.count)
		console.log("test model count: " + JSON.stringify(systemDevices) )
	}

	FilteredDeviceModel {
		id: systemDevices
		serviceTypes: ["dcsystem"]
	}

	//% "DC Load"
	title: qsTrId("dcload")

	GradientListView {
		header: BaseListItem {
			readonly property alias columnWidth: loadSummary.fixedColumnWidth
			readonly property alias columnSpacing: loadSummary.columnSpacing

			width: parent?.width ?? 0
			height: dcsystemTable.y + dcsystemTable.height + bottomInset
			bottomInset: Theme.geometry_gradientList_spacing

			QuantityTableSummary {
				id: loadSummary

				width: parent.width
				equalWidthColumns: true

				// rightPadding = 32px width of the sub-menu arrow icon in each list delegate, plus
				// margin, to align with the columns in the delegates.
				rightPadding: 32 + Theme.geometry_listItem_content_horizontalMargin
				summaryModel: [
					{ text: "", unit: VenusOS.Units_None },
					{ text: "", unit: VenusOS.Units_None },
					{ text: CommonWords.total_power, unit: VenusOS.Units_None },
				]
				bodyHeaderText: CommonWords.total
				bodyModel: QuantityObjectModel {
					// Add empty columns for volts/amps so that these columns align with those
					// in the QuantityTable.
					QuantityObject { unit: VenusOS.Units_Volt_DC; hidden: true }
					QuantityObject { unit: VenusOS.Units_Amp; hidden: true }
					QuantityObject { object: root.measurements; key: "power"; unit: VenusOS.Units_Watt }
				}
			}

			QuantityTable {
				id: dcsystemTable

				anchors.top: loadSummary.bottom
				rightPadding: loadSummary.rightPadding
				width: parent.width
				equalWidthColumns: true
				model: root.systemDevices
				delegate: QuantityTable.TableRow {
					id: tableRow

					required property string name
					//required property real power
					//required property real current

					headerText: name
					model: QuantityObjectModel {
						QuantityObject { object: voltageItem; unit: VenusOS.Units_Volt_AC }
						QuantityObject { object: tableRow; key: "current"; unit: VenusOS.Units_Amp }
						QuantityObject { object: tableRow; key: "power"; unit: VenusOS.Units_Watt }
					}

					// Get the active AC input phase voltage from /L<1-3>/V (for vebus/acsystem)
					// or /L<1-3>/Voltage (for grid/genset).
					// VeQuickItem {
					// 	id: voltageItem
					// 	uid: phaseTable.acInMeasurementsUid ? "%1/%2/%3"
					// 		   .arg(phaseTable.acInMeasurementsUid)
					// 		   .arg(tableRow.name)
					// 		   .arg(phaseTable.voltageKey)
					// 		 : ""
					// }

					// Get the active AC input phase frequency from /L<1-3>/F (for vebus/acsystem)
					// or /Ac/Frequency (for grid/genset). The frequency is the same for all phases.
					// VeQuickItem {
					// 	id: frequencyItem
					// 	uid: phaseTable.acInMeasurementsUid
					// 		? phaseTable.acInServiceType === "vebus" || phaseTable.acInServiceType === "acsystem"
					// 		   ? "%1/%2/F".arg(phaseTable.acInMeasurementsUid).arg(tableRow.name)
					// 		   : "%1/Frequency".arg(phaseTable.acInMeasurementsUid)
					// 		: ""
					// }
				}
			}
		}


		model: root.model
		delegate: LoadListDelegate {
			id: deviceDelegate

			required property var device

			name: device.name
			power: powerItem.value ?? NaN
			columnWidth: ListView.view.headerItem?.columnWidth ?? NaN
			columnSpacing: ListView.view.headerItem?.columnSpacing ?? 0
			// quantityModel: QuantityObjectModel {
			// 	QuantityObject { object: dcDevice; key: "power"; unit: VenusOS.Units_Watt }
			// }

			// Status depends on the service:
			// - acload, heatpump: /SwitchableOutput/Status
			// - evcharger: /Status
			statusText: !statusItem.valid ? ""
				: device.serviceType === "dcload" || device.serviceType === "dcdc" ? VenusOS.switchableOutput_statusToText(statusItem.value, outputTypeItem.value)
				: device.serviceType === "dcsystem" ? statusItem.value
				: ""

			onClicked: root._showSettingsPage(device)

			VeQuickItem {
				id: statusItem
				uid: device.serviceType === "dcload" || device.serviceType === "dcdc" ? device.serviceUid + "/SwitchableOutput/Status"
					: device.serviceType === "dcsystem" ? device.serviceUid + "/Status"
					: ""
			}

			DcDevice {
				id: dcDevice
				serviceUid: deviceDelegate.device.serviceUid
			}

			VeQuickItem {
				id: powerItem
				uid: device.serviceUid + "/Power"
			}
		}
	}
	// 	delegate: LoadListDelegate {
	// 		id: loadDelegate

	// 		required property Device device

	// 		name: device.name
	// 		power: powerItem.value ?? NaN
	// 		columnWidth: ListView.view.headerItem?.columnWidth ?? NaN
	// 		columnSpacing: ListView.view.headerItem?.columnSpacing ?? 0

	// 		// Status depends on the service:
	// 		// - acload, heatpump: /SwitchableOutput/Status
	// 		// - evcharger: /Status
	// 		statusText: !statusItem.valid ? ""
	// 			: device.serviceType === "acload" || device.serviceType === "heatpump" ? VenusOS.switchableOutput_statusToText(statusItem.value, outputTypeItem.value)
	// 			: device.serviceType === "evcharger" ? Global.evChargers.chargerStatusToText(statusItem.value)
	// 			: ""

	// 		onClicked: {
	// 			// TODO use a generic helper to open a page based on the service type/uid. See issue #1388
	// 			if (device.serviceType === "evcharger") {
	// 				Global.pageManager.pushPage("/pages/evcs/EvChargerPage.qml", {
	// 					bindPrefix : device.serviceUid
	// 				})
	// 			} else {
	// 				Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcIn.qml", {
	// 					"bindPrefix": device.serviceUid
	// 				})
	// 			}
	// 		}

	// 		VeQuickItem {
	// 			id: statusItem
	// 			uid: device.serviceType === "acload" || device.serviceType === "heatpump" ? device.serviceUid + "/SwitchableOutput/Status"
	// 				: device.serviceType === "evcharger" ? device.serviceUid + "/Status"
	// 				: ""
	// 		}

	// 		VeQuickItem {
	// 			id: outputTypeItem
	// 			uid: device.serviceType === "acload" || device.serviceType === "heatpump" ? device.serviceUid + "/SwitchableOutput/Type"
	// 				: ""
	// 		}

	// 		VeQuickItem {
	// 			id: powerItem
	// 			uid: device.serviceUid + "/Ac/Power"
	// 		}
	// 	}
	// }

	// GradientListView {
	// 	id: settingsListView

	// 	header: SettingsColumn {
	// 		width: parent.width
	// 		bottomPadding: settingsListView.spacing

	// 		BaseListItem {
	// 			width: parent.width
	// 			height: summary.height

	// 			QuantityTableSummary {
	// 				id: summary

	// 				width: parent.width
	// 				equalWidthColumns: true

	// 				// rightPadding = 32px width of the sub-menu arrow icon in each list delegate, plus
	// 				// margin, to align with the columns in the delegates.
	// 				rightPadding: 32 + Theme.geometry_listItem_content_horizontalMargin
	// 				summaryModel: [
	// 					{ text: "", unit: VenusOS.Units_None },
	// 					{ text: "", unit: VenusOS.Units_None },
	// 					{ text: CommonWords.total_power, unit: VenusOS.Units_Watt },
	// 				]
	// 				bodyHeaderText: CommonWords.total
	// 				bodyModel: QuantityObjectModel {
	// 					QuantityObject { unit: VenusOS.Units_Volt_DC; hidden: true }
	// 					QuantityObject { unit: VenusOS.Units_Amp; hidden: true }
	// 					QuantityObject { object: Global.system.dcload; key: "power"; unit: VenusOS.Units_Watt }
	// 				}
	// 			}
	// 		}

	// 		QuantityTable {
	// 			id: phaseTable

	// 			readonly property string acInMeasurementsUid: Global.acInputs.highlightedInput?.measurementsUid ?? ""
	// 			readonly property string acInServiceType: Global.acInputs.highlightedInput?.serviceType ?? ""
	// 			readonly property string voltageKey: acInServiceType === "vebus" || acInServiceType === "acsystem" ? "V" : "Voltage"

	// 			anchors.top: loadSummary.bottom
	// 			rightPadding: loadSummary.rightPadding
	// 			width: parent.width
	// 			equalWidthColumns: true
	// 			model: root.measurements.phaseCount > 1 ? root.measurements.phases : null
	// 			delegate: QuantityTable.TableRow {
	// 				id: tableRow

	// 				required property string name
	// 				required property real power
	// 				required property real current

	// 				headerText: name
	// 				model: QuantityObjectModel {
	// 					QuantityObject { object: voltageItem; unit: VenusOS.Units_Volt_AC }
	// 					QuantityObject { object: frequencyItem; unit: VenusOS.Units_Hertz }
	// 					QuantityObject { object: tableRow; key: "current"; unit: VenusOS.Units_Amp }
	// 					QuantityObject { object: tableRow; key: "power"; unit: VenusOS.Units_Watt }
	// 				}

	// 				// Get the active AC input phase voltage from /L<1-3>/V (for vebus/acsystem)
	// 				// or /L<1-3>/Voltage (for grid/genset).
	// 				VeQuickItem {
	// 					id: voltageItem
	// 					uid: phaseTable.acInMeasurementsUid ? "%1/%2/%3"
	// 						   .arg(phaseTable.acInMeasurementsUid)
	// 						   .arg(tableRow.name)
	// 						   .arg(phaseTable.voltageKey)
	// 						 : ""
	// 				}

	// 				// Get the active AC input phase frequency from /L<1-3>/F (for vebus/acsystem)
	// 				// or /Ac/Frequency (for grid/genset). The frequency is the same for all phases.
	// 				VeQuickItem {
	// 					id: frequencyItem
	// 					uid: phaseTable.acInMeasurementsUid
	// 						? phaseTable.acInServiceType === "vebus" || phaseTable.acInServiceType === "acsystem"
	// 						   ? "%1/%2/F".arg(phaseTable.acInMeasurementsUid).arg(tableRow.name)
	// 						   : "%1/Frequency".arg(phaseTable.acInMeasurementsUid)
	// 						: ""
	// 				}
	// 			}
	// 		}
	// 	}
	// }
}
