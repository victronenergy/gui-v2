/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	// The AC loads to be displayed, which should be one of Global.system.load.<ac|acIn|acOut>
	required property ObjectAcConnection measurements

	// The model of devices to be displayed
	// TODO make this a FilteredDeviceModel when #2371 is fixed.
	required property var model

	GradientListView {
		header: BaseListItem {
			width: parent?.width ?? 0
			height: phaseTable.y + phaseTable.height + bottomInset
			bottomInset: Theme.geometry_gradientList_spacing

			QuantityTableSummary {
				id: loadSummary

				width: parent.width
				equalWidthColumns: true

				// rightPadding = width of the sub-menu arrow icon, plus margin around it. Needed to
				// align the "Total power" column with the "Total power" in each list delegate.
				rightPadding: 32 + (Theme.geometry_listItem_content_horizontalMargin * 2)
				summaryModel: [
					{ text: "", unit: VenusOS.Units_None },
					{ text: "", unit: VenusOS.Units_None },
					{ text: "", unit: VenusOS.Units_None },
					{ text: CommonWords.total_power, unit: VenusOS.Units_None },
				]
				bodyHeaderText: CommonWords.total
				bodyModel: QuantityObjectModel {
					// Add empty columns for volts/hertz/amps so that these columns align with those
					// in the QuantityTable.
					QuantityObject { unit: VenusOS.Units_Volt_AC; hidden: true }
					QuantityObject { unit: VenusOS.Units_Hertz; hidden: true }
					QuantityObject { unit: VenusOS.Units_Amp; hidden: true }
					QuantityObject { object: root.measurements; key: "power"; unit: VenusOS.Units_Watt }
				}
			}

			QuantityTable {
				id: phaseTable

				readonly property string acInMeasurementsUid: Global.acInputs.highlightedInput?.measurementsUid ?? ""
				readonly property string acInServiceType: Global.acInputs.highlightedInput?.serviceType ?? ""
				readonly property string voltageKey: acInServiceType === "vebus" || acInServiceType === "acsystem" ? "V" : "Voltage"

				anchors.top: loadSummary.bottom
				rightPadding: loadSummary.rightPadding
				width: parent.width
				equalWidthColumns: true
				model: root.measurements.phaseCount > 1 ? root.measurements.phases : null
				delegate: QuantityTable.TableRow {
					id: tableRow

					required property string name
					required property real power
					required property real current

					headerText: name
					model: QuantityObjectModel {
						QuantityObject { object: voltageItem; unit: VenusOS.Units_Volt_AC }
						QuantityObject { object: frequencyItem; unit: VenusOS.Units_Hertz }
						QuantityObject { object: tableRow; key: "current"; unit: VenusOS.Units_Amp }
						QuantityObject { object: tableRow; key: "power"; unit: VenusOS.Units_Watt }
					}

					// Get the active AC input phase voltage from /L<1-3>/V (for vebus/acsystem)
					// or /L<1-3>/Voltage (for grid/genset).
					VeQuickItem {
						id: voltageItem
						uid: phaseTable.acInMeasurementsUid ? "%1/%2/%3"
							   .arg(phaseTable.acInMeasurementsUid)
							   .arg(tableRow.name)
							   .arg(phaseTable.voltageKey)
							 : ""
					}

					// Get the active AC input phase frequency from /L<1-3>/F (for vebus/acsystem)
					// or /Ac/Frequency (for grid/genset). The frequency is the same for all phases.
					VeQuickItem {
						id: frequencyItem
						uid: phaseTable.acInMeasurementsUid
							? phaseTable.acInServiceType === "vebus" || phaseTable.acInServiceType === "acsystem"
							   ? "%1/%2/F".arg(phaseTable.acInMeasurementsUid).arg(tableRow.name)
							   : "%1/Frequency".arg(phaseTable.acInMeasurementsUid)
							: ""
					}
				}
			}
		}

		model: root.model
		delegate: LoadListDelegate {
			id: loadDelegate

			required property Device device

			name: device.name
			power: powerItem.value ?? NaN

			// Status depends on the service:
			// - acload, heatpump: /SwitchableOutput/Status
			// - evcharger: /Status
			statusText: !statusItem.valid ? ""
				: device.serviceType === "acload" || device.serviceType === "heatpump" ? VenusOS.switchableOutput_statusToText(statusItem.value)
				: device.serviceType === "evcharger" ? Global.evChargers.chargerStatusToText(statusItem.value)
				: ""

			onClicked: {
				// TODO use a generic helper to open a page based on the service type/uid. See issue #1388
				if (device.serviceType === "evcharger") {
					Global.pageManager.pushPage("/pages/evcs/EvChargerPage.qml", {
						bindPrefix : device.serviceUid
					})
				} else {
					Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcIn.qml", {
						"bindPrefix": device.serviceUid
					})
				}
			}

			VeQuickItem {
				id: statusItem
				uid: device.serviceType === "acload" || device.serviceType === "heatpump" ? device.serviceUid + "/SwitchableOutput/Status"
					: device.serviceType === "evcharger" ? device.serviceUid + "/Status"
					: ""
			}

			VeQuickItem {
				id: powerItem
				uid: device.serviceUid + "/Ac/Power"
			}
		}
	}
}
