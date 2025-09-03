/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	// A list of all solar inputs. For solarcharger, multi and inverter services, each tracker is
	// an individual entry in the list. For PV inverters, each inverter is an entry in the list,
	// since PV inverters do not have multiple trackers.
	GradientListView {
		model: SortedSolarInputModel {
			sourceModel: SolarInputModel {
				id: solarInputModel
			}
		}
		delegate: ListQuantityGroupNavigation {
			id: solarInputDelegate

			required property int index
			required property string serviceUid
			required property string serviceType
			required property string name
			required property real todaysYield
			required property real power
			required property real voltage
			required property real current

			text: name
			tableMode: true
			quantityModel: QuantityObjectModel {
				QuantityObject {
					// The Yield column is not shown for PV inverters.
					object: solarInputDelegate.serviceType === "pvinverter" ? null : solarInputDelegate
					key: "todaysYield"
					unit: solarInputDelegate.serviceType === "pvinverter" ? VenusOS.Units_None : VenusOS.Units_Energy_KiloWattHour
					hidden: solarInputDelegate.serviceType === "pvinverter"
				}
				QuantityObject { object: solarInputDelegate; key: "voltage"; unit: VenusOS.Units_Volt_DC }
				QuantityObject { object: solarInputDelegate; key: "current"; unit: VenusOS.Units_Amp }
				QuantityObject { object: solarInputDelegate; key: "power"; unit: VenusOS.Units_Watt }
			}

			onClicked: {
				if (serviceType === "pvinverter") {
					Global.pageManager.pushPage("/pages/solar/PvInverterPage.qml", { serviceUid: serviceUid })
				} else {
					Global.pageManager.pushPage("/pages/solar/SolarDevicePage.qml", { serviceUid: serviceUid })
				}
			}
		}

		section.property: "group"
		section.delegate: QuantityGroupListHeader {
			required property string section

			width: parent.width
			metricsFontSize: Theme.font_size_body2 // align columns with those in the delegate
			rightPadding: Theme.geometry_listItem_content_horizontalMargin + Theme.geometry_icon_size_medium
			headerText: section === "pvinverter" ? CommonWords.pv_inverter : ""
			model: [
				{ text: section === "pvinverter" ? "" : CommonWords.yield_today, unit: VenusOS.Units_Energy_KiloWattHour },
				{ text: CommonWords.voltage, unit: section === "pvinverter" ? VenusOS.Units_Volt_AC : VenusOS.Units_Volt_DC },
				{ text: CommonWords.current_amps, unit: VenusOS.Units_Amp },
				{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt },
			]
		}
	}
}
