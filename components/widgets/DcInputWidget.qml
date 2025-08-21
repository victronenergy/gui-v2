/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	property DeviceModel inputs: DeviceModel {}
	readonly property int inputType: !!inputs.firstObject
			? VenusOS.dcMeter_type(inputs.firstObject.serviceType, inputs.firstObject.monitorMode)
			: -1
	readonly property string detailUrl: inputType === VenusOS.DcMeter_Type_Alternator ? "/pages/settings/devicelist/dc-in/PageAlternator.qml"
			: inputs.firstObject?.serviceType === "dcgenset" ? "/pages/settings/devicelist/PageGenset.qml"
			: "/pages/settings/devicelist/dc-in/PageDcMeter.qml"

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

	title: VenusOS.dcMeter_typeToText(inputType)
	quantityLabel.dataObject: QtObject {
		property real power: NaN
		property real current: NaN
	}
	icon.source: VenusOS.dcMeter_iconForType(inputType)
	enabled: true

	onClicked: {
		if (root.inputs.count === 1) {
			Global.pageManager.pushPage(root.detailUrl, {
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
					width: parent.width
					metricsFontSize: Theme.font_size_body2 // align columns with those in the delegate
					rightPadding: Theme.geometry_listItem_content_horizontalMargin + Theme.geometry_icon_size_medium
					model: [
						{ text: CommonWords.voltage, unit: VenusOS.Units_Volt_DC },
						{ text: CommonWords.current_amps, unit: VenusOS.Units_Amp },
						{ text: CommonWords.power_watts, unit: VenusOS.Units_Watt },
					]
				}

				model: root.inputs
				delegate: ListQuantityGroupNavigation {
					text: model.device.name
					tableMode: true
					quantityModel: QuantityObjectModel {
						QuantityObject { object: model.device; key: "voltage"; unit: VenusOS.Units_Volt_DC }
						QuantityObject { object: model.device; key: "current"; unit: VenusOS.Units_Amp }
						QuantityObject { object: model.device; key: "power"; unit: VenusOS.Units_Watt }
					}

					onClicked: {
						Global.pageManager.pushPage(root.detailUrl, {
							"bindPrefix": model.device.serviceUid
						})
					}
				}
			}
		}
	}
}
