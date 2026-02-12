/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property FilteredDeviceModel systemModel
	required property FilteredDeviceModel nonSystemModel

	function _showSettingsPage(device) {
		if (BackendConnection.serviceTypeFromUid(device.serviceUid) === "dcdc") {
			Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcDcConverter.qml",
					{ "bindPrefix": device.serviceUid })
		} else {
			  Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcMeter.qml",
					{ "bindPrefix": device.serviceUid })
		}
	}

	Component {
		id: headerComponent

		ListItemControl {
			bottomInset: Theme.geometry_gradientList_spacing
			topPadding: 0
			bottomPadding: bottomInset
			leftPadding: 0
			contentItem: Item {
				readonly property real columnWidth: loadSummary.fixedColumnWidth
				readonly property real columnSpacing: loadSummary.columnSpacing

				implicitWidth: loadSummary.width
				implicitHeight: dcsystemTable.y + dcsystemTable.height

				QuantityTableSummary {
					id: loadSummary

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
						QuantityObject { object: Global.system.dc; key: "power"; unit: VenusOS.Units_Watt }
					}
				}

				QuantityTable {
					id: dcsystemTable

					anchors.top: loadSummary.bottom
					rightPadding: loadSummary.rightPadding
					equalWidthColumns: true
					model: root.systemModel.count > 1 ? root.systemModel : null
					delegate: QuantityTable.TableRow {
						id: dcsystemTableRow

						required property Device device

						headerText: dcSystemDevice.name
						model: QuantityObjectModel {
							QuantityObject { object: dcSystemDevice; key: "voltage"; unit: VenusOS.Units_Volt_DC }
							QuantityObject { object: dcSystemDevice; key: "current"; unit: VenusOS.Units_Amp }
							QuantityObject { object: dcSystemDevice; key: "power"; unit: VenusOS.Units_Watt }
						}

						DcDevice {
							id: dcSystemDevice
							serviceUid: dcsystemTableRow.device.serviceUid
						}
					}
				}
			}
		}
	}

	GradientListView {
		header: root.systemModel.count > 1 ? headerComponent: null
		model: root.nonSystemModel
		delegate: LoadListDelegate {
			id: deviceDelegate

			required property var device

			name: device.name
			power: dcDevice.power ?? NaN
			current: dcDevice.current ?? NaN
			temperature: temperatureItem.value ?? NaN
			columnWidth: ListView.view.headerItem?.contentItem?.columnWidth ?? NaN
			columnSpacing: ListView.view.headerItem?.contentItem?.columnSpacing ?? 0

			// this is a DC device, so prefer Amps in Mixed display mode,
			// but only if we are not displaying the multiple-dcsystems table above
			// (as we want to remain consistent with the units we show, and we
			// always display power in watts in the table above).
			unitAmps: root.systemModel.count <= 1 && !isNaN(current)
				&& (Global.systemSettings.electricalPowerDisplay === VenusOS.ElectricalPowerDisplay_PreferAmps
				 || Global.systemSettings.electricalPowerDisplay === VenusOS.ElectricalPowerDisplay_Mixed)

			// Status depends on the service:
			// - dcdc: /State
			statusText: !statusItem.valid ? ""
				: device.serviceType === "dcdc" ? Global.system.systemStateToText(statusItem.value)
				: ""

			onClicked: root._showSettingsPage(device)

			VeQuickItem {
				id: temperatureItem
				uid: device.serviceUid + "/Dc/0/Temperature"
			}

			VeQuickItem {
				id: statusItem
				uid: device.serviceType === "dcdc" ? device.serviceUid + "/State"
					: ""
			}

			DcDevice {
				id: dcDevice
				serviceUid: deviceDelegate.device.serviceUid
			}
		}
	}
}
