/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	property DeviceModel inputs: DeviceModel {}
	property string detailUrl: "/pages/settings/devicelist/dc-in/PageDcMeter.qml"

	function _refreshTotalPower() {
		let totalPower = NaN
		let totalCurrent = NaN
		for (let i = 0; i < inputs.count; ++i) {
			const input = inputs.deviceAt(i)
			totalPower = Units.sumRealNumbers(totalPower, input.power)
			totalCurrent = Units.sumRealNumbers(totalCurrent, input.current)
		}
		quantityLabel.dataObject.power = totalPower
		quantityLabel.dataObject.current = totalCurrent
	}

	title: !inputs.firstObject ? ""
		   : Global.dcInputs.inputTypeToText(Global.dcInputs.inputType(inputs.firstObject.serviceUid, inputs.firstObject.monitorMode))
	quantityLabel.dataObject: QtObject {
		property real power: NaN
		property real current: NaN
	}
	icon.source: "qrc:/images/icon_dc_24.svg"
	enabled: true

	onClicked: {
		if (root.inputs.count === 1) {
			Global.pageManager.pushPage(root.detailUrl, {
				"title": root.inputs.firstObject.name,
				"bindPrefix": root.inputs.firstObject.serviceUid
			})
		} else {
			Global.pageManager.pushPage(listPageComponent)
		}
	}

	Instantiator {
		model: root.inputs
		// Each object in the model should be a DcDevice object with a 'power' value.
		delegate: Connections {
			target: model.device
			function onPowerChanged() {
				Qt.callLater(root._refreshTotalPower)
			}
			Component.onCompleted: Qt.callLater(root._refreshTotalPower)
		}
	}

	Component {
		id: listPageComponent

		Page {
			title: root.title

			GradientListView {
				header: QuantityGroupListHeader {
					quantityTitleModel: [
						{ text: CommonWords.voltage, unit: VenusOS.Units_Volt },
						{ text: CommonWords.current_amps, unit: VenusOS.Units_Amp },
						{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt },
					]
				}

				model: root.inputs
				delegate: ListQuantityGroupNavigationItem {
					text: model.device.name
					quantityModel: [
						{ value: model.device.voltage, unit: VenusOS.Units_Volt },
						{ value: model.device.current, unit: VenusOS.Units_Amp },
						{ value: model.device.power, unit: VenusOS.Units_Watt },
					]
					onClicked: {
						Global.pageManager.pushPage(root.detailUrl, {
							"title": model.device.name,
							"bindPrefix": model.device.serviceUid
						})
					}
				}
			}
		}
	}
}
