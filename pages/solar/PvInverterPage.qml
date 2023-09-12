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
		model: ObjectModel {
			ListItemBackground {
				height: phaseTable.y + phaseTable.height

				QuantityTableSummary {
					id: phaseSummary

					x: Theme.geometry.listItem.content.horizontalMargin
					width: parent.width - Theme.geometry.listItem.content.horizontalMargin

					model: [
						{
							title: root.pvInverter.statusCode >= 0 ? CommonWords.status : "",
							text: Global.pvInverters.statusCodeToText(root.pvInverter.statusCode),
							unit: VenusOS.Units_None,
						},
						{
							title: CommonWords.energy,
							value: root.pvInverter.energy,
							unit: VenusOS.Units_Energy_KiloWattHour
						},
						{
							title: CommonWords.voltage,
							value: root.pvInverter.voltage,
							unit: VenusOS.Units_Volt
						},
						{
							title: CommonWords.current_amps,
							value: root.pvInverter.current,
							unit: VenusOS.Units_Amp
						},
						{
							title: CommonWords.power_watts,
							value: root.pvInverter.power,
							unit: VenusOS.Units_Watt
						},
					]
				}

				QuantityTable {
					id: phaseTable

					anchors {
						top: phaseSummary.bottom
						topMargin: Theme.geometry.gradientList.spacing
					}
					visible: root.pvInverter.phases.count > 1
					headerVisible: false

					rowCount: root.pvInverter.phases.count
					units: [
						{ title: CommonWords.phase, unit: VenusOS.Units_None },
						{ title: CommonWords.energy, unit: VenusOS.Units_Energy_KiloWattHour },
						{ title: CommonWords.voltage, unit: VenusOS.Units_Volt },
						{ title: CommonWords.current_amps, unit: VenusOS.Units_Amp },
						{ title: CommonWords.power_watts, unit: VenusOS.Units_Watt }
					]
					valueForModelIndex: function(phaseIndex, column) {
						const phase = root.pvInverter.phases.get(phaseIndex)
						const columnProperties = ["name", "energy", "voltage", "current", "power"]
						return phase[columnProperties[column]]
					}
				}
			}

			Item {
				width: 1
				height: Theme.geometry.gradientList.spacing
			}

			PvInverterPositionRadioButtonGroup {
				dataSource: root.pvInverter.serviceUid + "/Position"
			}

			ListTextItem {
				text: CommonWords.zero_feed_in_power_limit
				dataSource: root.pvInverter.serviceUid + "/Ac/PowerLimit"
				visible: dataValid
			}

			ListTextItem {
				text: CommonWords.error
				secondaryText: root.pvInverter.errorCode > 0 ? root.pvInverter.errorCode : CommonWords.none_errors
				secondaryLabel.color: root.pvInverter.errorCode > 0 ? Theme.color.critical : Theme.color.font.secondary
			}

			ListNavigationItem {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("qrc:/qt/qml/Victron/VenusOS/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.pvInverter.serviceUid })
				}
			}
		}
	}
}
