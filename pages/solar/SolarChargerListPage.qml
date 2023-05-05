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

	GradientListView {
		id: chargerListView

		header: Row {
			anchors {
				right: parent.right
				rightMargin: Theme.geometry.listItem.content.horizontalMargin + Theme.geometry.statusBar.button.icon.width
			}
			width: Theme.geometry.solarListPage.quantityRow.width
			height: implicitHeight + Theme.geometry.quantityTableSummary.verticalMargin

			Repeater {
				id: titleRepeater

				model: [CommonWords.yield_today, CommonWords.voltage, CommonWords.current_amps, CommonWords.pv_power]
				delegate: Label {
					width: (parent.width / titleRepeater.count) * (model.index === 0 ? 1.2 : 1) // kwh column needs more space as unit name is longer
					text: modelData
					font.pixelSize: Theme.font.size.caption
					color: Theme.color.solarListPage.header.text
				}
			}
		}
		model: Global.solarChargers.model
		delegate: ListNavigationItem {
			readonly property var solarCharger: model.solarCharger

			text: solarCharger.name
			primaryLabel.width: availableWidth - Theme.geometry.solarListPage.quantityRow.width - Theme.geometry.listItem.content.horizontalMargin

			onClicked: Global.pageManager.pushLayer("/pages/solar/SolarChargerPage.qml", { "solarCharger": solarCharger })

			Row {
				anchors {
					right: parent.right
					rightMargin: Theme.geometry.listItem.content.horizontalMargin + Theme.geometry.statusBar.button.icon.width
				}
				width: Theme.geometry.solarListPage.quantityRow.width
				height: parent.height

				Repeater {
					id: quantityRepeater

					model: [
						{
							value: root._yieldToday(solarCharger),
							unit: VenusOS.Units_Energy_KiloWattHour
						},
						{
							value: solarCharger.voltage,
							unit: VenusOS.Units_Volt
						},
						{
							value: solarCharger.current,
							unit: VenusOS.Units_Amp
						},
						{
							value: solarCharger.power,
							unit: VenusOS.Units_Watt
						},
					]

					delegate: QuantityLabel {
						anchors.verticalCenter: parent.verticalCenter
						width: (parent.width / quantityRepeater.count) * (model.index === 0 ? 1.2 : 1)
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
