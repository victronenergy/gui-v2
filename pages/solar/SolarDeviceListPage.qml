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
						delegate: SolarDeviceNavigationItem {
							readonly property SolarDailyHistory historyToday: solarCharger.dailyHistory(0, model.index)

							text: solarCharger.trackerName(model.index)
							energy: historyToday ? historyToday.yieldKwh : NaN
							current: modelData.current
							power: modelData.power
							voltage: modelData.voltage

							onClicked: {
								Global.pageManager.pushPage("/pages/solar/SolarChargerPage.qml", { "solarCharger": solarCharger })
							}
						}
					}
				}
			}

			Component {
				id: pvInverterRowComponent

				SolarDeviceNavigationItem {
					readonly property QtObject pvInverter: {
						let pvInverterIndex = model.index - Global.solarChargers.model.count - chargerListView.extraHeaderCount
						return Global.pvInverters.model.deviceAt(pvInverterIndex)
					}

					text: pvInverter.name
					energy: pvInverter.energy
					current: pvInverter.current
					power: pvInverter.power
					voltage: pvInverter.voltage

					onClicked: {
						Global.pageManager.pushPage("/pages/solar/PvInverterPage.qml", { "pvInverter": pvInverter })
					}
				}
			}
		}
	}

	Component {
		id: listHeaderComponent

		Item {
			property bool chargerMode: Global.solarChargers.model.count > 0

			width: parent.width
			height: Theme.geometry_listItem_height

			Label {
				id: firstTitleLabel
				anchors {
					left: parent.left
					leftMargin: Theme.geometry_listItem_content_horizontalMargin
					right: quantityRow.left
					bottom: parent.bottom
					bottomMargin: Theme.geometry_quantityTableSummary_verticalMargin
				}
				text: chargerMode
						//% "PV Charger"
					  ? qsTrId("solardevices_pv_charger")
					  : CommonWords.pv_inverter
				font.pixelSize: Theme.font_size_caption
				color: Theme.color_solarListPage_header_text
				elide: Text.ElideRight
			}

			Row {
				id: quantityRow

				anchors {
					bottom: parent.bottom
					bottomMargin: Theme.geometry_quantityTableSummary_verticalMargin
					right: parent.right
					rightMargin: Theme.geometry_listItem_content_horizontalMargin + Theme.geometry_statusBar_button_icon_width
				}
				width: Theme.geometry_solarListPage_quantityRow_width

				Repeater {
					id: titleRepeater

					model: [chargerMode ? CommonWords.yield_today : CommonWords.energy, CommonWords.voltage, CommonWords.current_amps, CommonWords.power_watts]
					delegate: Label {
						width: (parent.width / titleRepeater.count) * (model.index === 0 ? 1.2 : 1) // kwh column needs more space as unit name is longer
						text: modelData
						font.pixelSize: Theme.font_size_caption
						color: Theme.color_solarListPage_header_text
					}
				}
			}
		}
	}
}
