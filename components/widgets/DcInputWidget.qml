/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	required property string serviceType
	required property int inputType
	readonly property string detailUrl: inputType === VenusOS.DcMeter_Type_Alternator ? "/pages/settings/devicelist/dc-in/PageAlternator.qml"
			: inputDeviceModel.firstObject?.serviceType === "dcgenset" ? "/pages/settings/devicelist/PageGenset.qml"
			: "/pages/settings/devicelist/dc-in/PageDcMeter.qml"

	title: VenusOS.dcMeter_typeToText(inputType)
	quantityLabel.dataObject: QtObject {
		readonly property real power: inputDeviceModel.totalPower
		readonly property real current: inputDeviceModel.totalCurrent
	}
	icon.source: VenusOS.dcMeter_iconForType(inputType)
	enabled: true

	onClicked: {
		if (inputDeviceModel.count === 1) {
			Global.pageManager.pushPage(root.detailUrl, {
				"bindPrefix": inputDeviceModel.firstObject.serviceUid
			})
		} else {
			Global.pageManager.pushPage(listPageComponent)
		}
	}

	DcMeterDeviceModel {
		id: inputDeviceModel
		serviceTypes: [ root.serviceType ]
		meterType: root.inputType
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

				model: inputDeviceModel
				delegate: ListQuantityGroupNavigation {
					required property BaseDevice device

					text: device.name
					tableMode: true
					quantityModel: QuantityObjectModel {
						QuantityObject { object: dcInput; key: "voltage"; unit: VenusOS.Units_Volt_DC }
						QuantityObject { object: dcInput; key: "current"; unit: VenusOS.Units_Amp }
						QuantityObject { object: dcInput; key: "power"; unit: VenusOS.Units_Watt }
					}

					onClicked: {
						Global.pageManager.pushPage(root.detailUrl, {
							"bindPrefix": device.serviceUid
						})
					}

					DcDevice {
						id: dcInput
						serviceUid: device.serviceUid
					}
				}
			}
		}
	}
}
