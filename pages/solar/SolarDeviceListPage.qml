/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	function _yieldToday(charger) {
		const history = charger.dailyHistory(0)
		if (history && !isNaN(history.yieldKwh)) {
			return history.yieldKwh
		}
		return NaN
	}

	// A list of the quantity measurements for all PV chargers, followed by all PV inverters.
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
			height: Math.max(item ? item.implicitHeight : 0, Theme.geometry.listItem.height)
			sourceComponent: Global.solarChargers.model.count > 0
							 && Global.pvInverters.model.count > 0
							 && model.index === Global.solarChargers.model.count
							 ? listHeaderComponent
							 : contentRowComponent

			onLoaded: {
				if (sourceComponent === listHeaderComponent) {
					item.chargerMode = false
				}
			}

			Component {
				id: contentRowComponent

				ListNavigationItem {
					readonly property var solarCharger: model.index < Global.solarChargers.model.count
							? Global.solarChargers.model.objectAt(model.index)
							: null
					readonly property var pvInverter: {
						let pvInverterIndex = model.index
						if (Global.solarChargers.model.count > 0) {
							if (model.index <= Global.solarChargers.model.count) {
								// This is a row for a charger or for the 'PV inverters' header, not for
								// an inverter
								return null
							}
							// Offset the index by the number of items above it in the list
							pvInverterIndex = model.index - Global.solarChargers.model.count - chargerListView.extraHeaderCount
						}
						return Global.pvInverters.model.objectAt(pvInverterIndex)
					}

					text: solarCharger ? solarCharger.name : pvInverter.name
					primaryLabel.width: availableWidth - Theme.geometry.solarListPage.quantityRow.width - Theme.geometry.listItem.content.horizontalMargin

					onClicked: {
						if (solarCharger) {
							Global.pageManager.pushPage("/pages/solar/SolarChargerPage.qml", { "solarCharger": solarCharger })
						} else {
							Global.pageManager.pushPage("/pages/solar/PvInverterPage.qml", { "pvInverter": pvInverter })
						}
					}

					Row {
						id: quantityRow

						anchors {
							right: parent.right
							rightMargin: Theme.geometry.listItem.content.horizontalMargin + Theme.geometry.statusBar.button.icon.width
						}
						width: Theme.geometry.solarListPage.quantityRow.width
						height: parent.height - parent.spacing

						Repeater {
							id: quantityRepeater

							model: [
								{
									value: !!solarCharger ? root._yieldToday(solarCharger) : pvInverter.energy,
									unit: VenusOS.Units_Energy_KiloWattHour
								},
								{
									value: (solarCharger || pvInverter).voltage,
									unit: VenusOS.Units_Volt
								},
								{
									value: (solarCharger || pvInverter).current,
									unit: VenusOS.Units_Amp
								},
								{
									value: (solarCharger || pvInverter).power,
									unit: VenusOS.Units_Watt
								},
							]

							delegate: QuantityLabel {
								width: (quantityRow.width / quantityRepeater.count) * (model.index === 0 ? 1.2 : 1)
								height: quantityRow.height
								value: modelData.value
								unit: modelData.unit
								alignment: Qt.AlignLeft
								font.pixelSize: Theme.font.size.body2
								valueColor: Theme.color.quantityTable.quantityValue
								unitColor: Theme.color.quantityTable.quantityUnit
							}
						}
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
			height: Theme.geometry.listItem.height

			Label {
				id: firstTitleLabel
				anchors {
					left: parent.left
					leftMargin: Theme.geometry.listItem.content.horizontalMargin
					right: quantityRow.left
					bottom: parent.bottom
					bottomMargin: Theme.geometry.quantityTableSummary.verticalMargin
				}
				text: chargerMode
						//% "PV Charger"
					  ? qsTrId("solardevices_pv_charger")
						//% "PV Inverter"
					  : qsTrId("solardevices_pv_inverter")
				font.pixelSize: Theme.font.size.caption
				color: Theme.color.solarListPage.header.text
				elide: Text.ElideRight
			}

			Row {
				id: quantityRow

				anchors {
					bottom: parent.bottom
					bottomMargin: Theme.geometry.quantityTableSummary.verticalMargin
					right: parent.right
					rightMargin: Theme.geometry.listItem.content.horizontalMargin + Theme.geometry.statusBar.button.icon.width
				}
				width: Theme.geometry.solarListPage.quantityRow.width

				Repeater {
					id: titleRepeater

					model: [chargerMode ? CommonWords.yield_today : CommonWords.energy, CommonWords.voltage, CommonWords.current_amps, CommonWords.power_watts]
					delegate: Label {
						width: (parent.width / titleRepeater.count) * (model.index === 0 ? 1.2 : 1) // kwh column needs more space as unit name is longer
						text: modelData
						font.pixelSize: Theme.font.size.caption
						color: Theme.color.solarListPage.header.text
					}
				}
			}
		}
	}
}
