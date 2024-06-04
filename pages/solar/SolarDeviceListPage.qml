/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	// A list of all PV arrays. For solar chargers, each tracker for the charger is an individual
	// entry in the list. For PV inverters, each inverter is an entry in the list, since inverters
	// do not have multiple trackers.
	GradientListView {
		id: chargerListView

		// If there are both PV chargers and PV inverters, the ListView headerItem will be the
		// 'PV chargers' header, and one of the list delegates will be the 'PV inverters' header
		// row instead of a row containing the quantity measurements.
		// If there are only PV chargers or only PV inverters, only the ListView headerItem is
		// required, and no additional header is needed.
		readonly property int extraHeaderCount: Global.solarChargers.model.count > 0 && Global.pvInverters.model.count > 0 ? 1 : 0

		header: listHeaderComponent
		model: Global.solarChargers.model.count + Global.pvInverters.model.count + extraHeaderCount

		delegate: Loader {
			width: parent ? parent.width : 0
			height: Math.max(item ? item.implicitHeight : 0, Theme.geometry_listItem_height)
			sourceComponent: {
				if (Global.solarChargers.model.count > 0
						&& Global.pvInverters.model.count > 0
						&& model.index === Global.solarChargers.model.count) {
					return listHeaderComponent
				}
				if (model.index < Global.solarChargers.model.count) {
					return solarChargerRowComponent
				}
				return pvInverterRowComponent
			}

			onLoaded: {
				if (sourceComponent === listHeaderComponent) {
					item.chargerMode = false
				}
			}

			Component {
				id: solarChargerRowComponent

				Column {
					readonly property QtObject solarCharger: Global.solarChargers.model.deviceAt(model.index)

					width: parent.width

					Repeater {
						model: solarCharger.trackers
						delegate: ListQuantityGroupNavigationItem {
							readonly property real yieldToday: {
								const historyToday = solarCharger.trackers.count > 1
										? solarCharger.dailyTrackerHistory(0, model.index)
										: solarCharger.dailyHistory(0)
								return historyToday ? historyToday.yieldKwh : NaN
							}

							text: solarCharger.trackerName(model.index)
							quantityModel: [
								{ value: yieldToday, unit: VenusOS.Units_Energy_KiloWattHour },
								{ value: modelData.voltage, unit: VenusOS.Units_Volt_DC },
								{ value: modelData.current, unit: VenusOS.Units_Amp },
								{ value: modelData.power, unit: VenusOS.Units_Watt },
							]

							onClicked: {
								Global.pageManager.pushPage("/pages/solar/SolarChargerPage.qml", { "solarCharger": solarCharger })
							}
						}
					}
				}
			}

			Component {
				id: pvInverterRowComponent

				ListQuantityGroupNavigationItem {
					readonly property QtObject pvInverter: {
						let pvInverterIndex = model.index - Global.solarChargers.model.count - chargerListView.extraHeaderCount
						return Global.pvInverters.model.deviceAt(pvInverterIndex)
					}

					text: pvInverter.name
					quantityModel: [
						{ value: pvInverter.energy, unit: VenusOS.Units_Energy_KiloWattHour },
						{ value: pvInverter.voltage, unit: VenusOS.Units_Volt_AC },
						{ value: pvInverter.current, unit: VenusOS.Units_Amp },
						{ value: pvInverter.power, unit: VenusOS.Units_Watt },
					]

					onClicked: {
						Global.pageManager.pushPage("/pages/solar/PvInverterPage.qml", { "pvInverter": pvInverter })
					}
				}
			}
		}
	}

	Component {
		id: listHeaderComponent

		QuantityGroupListHeader {
			property bool chargerMode: Global.solarChargers.model.count > 0

			firstColumnText: chargerMode
					//% "PV Charger"
				  ? qsTrId("solardevices_pv_charger")
				  : CommonWords.pv_inverter
			quantityTitleModel: [
				{ text: chargerMode ? CommonWords.yield_today : CommonWords.energy, unit: VenusOS.Units_Energy_KiloWattHour },
				{ text: CommonWords.voltage, unit: chargerMode ? VenusOS.Units_Volt_DC : VenusOS.Units_Volt_AC },
				{ text: CommonWords.current_amps, unit: VenusOS.Units_Amp },
				{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt },
			]
		}
	}
}
