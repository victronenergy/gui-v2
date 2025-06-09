/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property var pvInverter

	title: pvInverter.name

	GradientListView {
		model: VisibleItemModel {
			BaseListItem {
				width: parent ? parent.width : 0
				height: phaseTable.y + phaseTable.height

				QuantityTableSummary {
					id: phaseSummary

					width: parent.width
					columnSpacing: Theme.geometry_quantityTable_horizontalSpacing_small
					summaryHeaderText: root.pvInverter.statusCode >= 0 ? CommonWords.status : ""
					summaryModel: [
						{ text: CommonWords.energy, unit: VenusOS.Units_Energy_KiloWattHour },
						{ text: CommonWords.voltage, unit: VenusOS.Units_Volt_AC },
						{ text: CommonWords.current_amps, unit: VenusOS.Units_Amp },
						{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt }
					]
					bodyHeaderText: VenusOS.pvInverter_statusCodeToText(root.pvInverter.statusCode)
					bodyModel: QuantityObjectModel {
						QuantityObject { object: root.pvInverter; key: "energy"; unit: VenusOS.Units_Energy_KiloWattHour }
						QuantityObject { object: root.pvInverter; key: "voltage"; unit: VenusOS.Units_Volt_AC }
						QuantityObject { object: root.pvInverter; key: "current"; unit: VenusOS.Units_Amp }
						QuantityObject { object: root.pvInverter; key: "power"; unit: VenusOS.Units_Watt }
					}
				}

				QuantityTable {
					id: phaseTable

					anchors {
						top: phaseSummary.bottom
						topMargin: Theme.geometry_gradientList_spacing
					}
					width: phaseSummary.width
					visible: root.pvInverter.phases.count > 1
					metricsFontSize: phaseSummary.metricsFontSize
					columnSpacing: phaseSummary.columnSpacing
					model: root.pvInverter.phases.count > 1 ? root.pvInverter.phases : 0

					delegate: QuantityTable.TableRow {
						id: tableRow

						required property string name
						required property real energy
						required property real voltage
						required property real current
						required property real power

						headerText: name
						model: QuantityObjectModel {
							QuantityObject { object: tableRow; key: "energy"; unit: VenusOS.Units_Energy_KiloWattHour }
							QuantityObject { object: tableRow; key: "voltage"; unit: VenusOS.Units_Volt_AC }
							QuantityObject { object: tableRow; key: "current"; unit: VenusOS.Units_Amp }
							QuantityObject { object: tableRow; key: "power"; unit: VenusOS.Units_Watt }
						}
					}
				}
			}

			ListPvInverterPositionRadioButtonGroup {
				dataItem.uid: root.pvInverter.serviceUid + "/Position"
				preferredVisible: (!positionIsAdjustable.valid || positionIsAdjustable.value === 1) ? dataItem.valid : false

				// Datapoint will exist in VM-3P75CT energy meters, but usually will not exist.
				// In cases where the data point does not exist, assume position IS adjustable.
				// Value will be zero if the position setting is not adjustable via gui-v2.
				VeQuickItem {
					id: positionIsAdjustable
					uid: root.pvInverter.serviceUid + "/PositionIsAdjustable"
				}
			}

			ListQuantity {
				text: CommonWords.dynamic_power_limit
				unit: VenusOS.Units_Watt
				dataItem.uid: root.pvInverter.serviceUid + "/Ac/PowerLimit"
				preferredVisible: dataItem.valid
			}

			ListAcInError {
				text: CommonWords.error
				bindPrefix: root.pvInverter.serviceUid
				secondaryLabel.color: root.pvInverter.errorCode > 0 ? Theme.color_critical : Theme.color_font_secondary
			}

			ListNavigation {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.pvInverter.serviceUid })
				}
			}
		}
	}
}
