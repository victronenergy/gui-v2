/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property var _pvChargerHeaderModel: [
		{ text: CommonWords.yield_today, unit: VenusOS.Units_Energy_KiloWattHour },
		{ text: CommonWords.voltage, unit: VenusOS.Units_Volt_DC },
		{ text: CommonWords.current_amps, unit: VenusOS.Units_Amp },
		{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt },
	]
	readonly property var _pvInverterLandscapeHeaderModel: [
		{ text: "", unit: VenusOS.Units_Energy_KiloWattHour },
		{ text: CommonWords.voltage, unit: VenusOS.Units_Volt_AC },
		{ text: CommonWords.current_amps, unit: VenusOS.Units_Amp },
		{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt },
	]
	readonly property var _pvInverterPortraitHeaderModel: [
		{ text: CommonWords.voltage, unit: VenusOS.Units_Volt_AC },
		{ text: CommonWords.current_amps, unit: VenusOS.Units_Amp },
		{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt },
	]

	// A list of all solar inputs. For solarcharger, multi and inverter services, each tracker is
	// an individual entry in the list. For PV inverters, each inverter is an entry in the list,
	// since PV inverters do not have multiple trackers.
	GradientListView {
		model: SortedSolarInputModel {
			sourceModel: SolarInputModel {}
		}
		delegate: ListQuantityGroupNavigation {
			id: solarInputDelegate

			required property string serviceUid
			required property string serviceType
			required property string name
			required property real todaysYield
			required property real power
			required property real voltage
			required property real current

			text: name
			quantityModel: quantityModelLoader.item

			// For PV inverters, the yield is not displayed.
			// In landscape, hide the yield field while maintaining the UI space, so that the other
			// power/voltage/current align with the same columns for the PV chargers.
			// In portrait, remove the UI space for the yield altogether, so that the other columns
			// shift to the left edge of the page.
			forceColumnLayout: solarInputDelegate.serviceType === "pvinverter"
					&& Theme.screenSize === Theme.Portrait

			onClicked: {
				if (serviceType === "pvinverter") {
					Global.pageManager.pushPage("/pages/solar/PvInverterPage.qml", { serviceUid: serviceUid })
				} else {
					Global.pageManager.pushPage("/pages/solar/SolarDevicePage.qml", { serviceUid: serviceUid })
				}
			}

			Loader {
				id: quantityModelLoader

				sourceComponent: solarInputDelegate.serviceType === "pvinverter"
						&& Theme.screenSize === Theme.Portrait ? noYieldModel : allQuantitiesModel

				Component {
					id: allQuantitiesModel

					QuantityObjectModel {
						QuantityObject {
							object: solarInputDelegate.serviceType === "pvinverter" ? null : solarInputDelegate
							key: "todaysYield"
							unit: VenusOS.Units_Energy_KiloWattHour
							hidden: solarInputDelegate.serviceType === "pvinverter"
						}
						QuantityObject {
							object: solarInputDelegate
							key: "voltage"
							unit: solarInputDelegate.serviceType ? VenusOS.Units_Volt_AC : VenusOS.Units_Volt_DC
						}
						QuantityObject { object: solarInputDelegate; key: "current"; unit: VenusOS.Units_Amp }
						QuantityObject { object: solarInputDelegate; key: "power"; unit: VenusOS.Units_Watt }
					}
				}

				Component {
					id: noYieldModel

					QuantityObjectModel {
						QuantityObject { object: solarInputDelegate; key: "voltage"; unit: VenusOS.Units_Volt_AC }
						QuantityObject { object: solarInputDelegate; key: "current"; unit: VenusOS.Units_Amp }
						QuantityObject { object: solarInputDelegate; key: "power"; unit: VenusOS.Units_Watt }
					}
				}
			}
		}

		section.property: "group"
		section.delegate: QuantityGroupListHeader {
			required property string section

			width: parent.width
			metricsFontSize: Theme.font_listItem_secondary_size // align columns with those in the delegate
			headerVisible: Theme.screenSize !== Theme.Portrait
			rightPadding: Theme.screenSize === Theme.Portrait ? 0
				: (Theme.geometry_page_content_horizontalMargin // list item right inset
					+ Theme.geometry_listItem_content_horizontalMargin // list item right padding
					+ Theme.geometry_icon_size_medium // arrow icon width
					+ Theme.geometry_listItem_arrow_leftMargin) // arrow icon padding
			textHorizontalAlignment: Text.AlignHCenter
			headerText: section === "pvinverter" ? CommonWords.pv_inverter : ""
			model: section === "pvinverter"
				   ? (Theme.screenSize === Theme.Portrait ? root._pvInverterPortraitHeaderModel : root._pvInverterLandscapeHeaderModel)
				   : root._pvChargerHeaderModel
		}
	}
}
