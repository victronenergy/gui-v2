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
		model: AllowedItemModel {
			ListItemBackground {
				height: phaseTable.y + phaseTable.height

				QuantityTableSummary {
					id: phaseSummary

					model: [
						{
							title: root.pvInverter.statusCode >= 0 ? CommonWords.status : "",
							text: VenusOS.pvInverter_statusCodeToText(root.pvInverter.statusCode),
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
							unit: VenusOS.Units_Volt_AC
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
						topMargin: Theme.geometry_gradientList_spacing
					}
					visible: root.pvInverter.phases.count > 1
					headerVisible: false

					rowCount: root.pvInverter.phases.count
					units: [
						{ title: CommonWords.phase, unit: VenusOS.Units_None },
						{ title: CommonWords.energy, unit: VenusOS.Units_Energy_KiloWattHour },
						{ title: CommonWords.voltage, unit: VenusOS.Units_Volt_AC },
						{ title: CommonWords.current_amps, unit: VenusOS.Units_Amp },
						{ title: CommonWords.power_watts, unit: VenusOS.Units_Watt }
					]
					valueForModelIndex: function(phaseIndex, column) {
						const phase = root.pvInverter.phases.getPhase(phaseIndex)
						const columnProperties = ["name", "energy", "voltage", "current", "power"]
						return phase[columnProperties[column]]
					}
				}
			}

			Item {
				width: 1
				height: Theme.geometry_gradientList_spacing
			}

			ListPvInverterPositionRadioButtonGroup {
				dataItem.uid: root.pvInverter.serviceUid + "/Position"
			}

			ListText {
				text: CommonWords.zero_feed_in_power_limit
				dataItem.uid: root.pvInverter.serviceUid + "/Ac/PowerLimit"
				allowed: dataItem.isValid
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
