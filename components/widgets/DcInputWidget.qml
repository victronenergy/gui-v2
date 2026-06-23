/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

OverviewWidget {
	id: root

	required property string serviceType
	property int inputTypeFilter: -1
	readonly property real totalPower: inputDeviceModel.totalPower

	readonly property int inputType: inputDeviceModel.commonMeterType >= 0 ? inputDeviceModel.commonMeterType
			: serviceType === "dcsource" ? VenusOS.DcMeter_Type_GenericSource
			: VenusOS.DcMeter_Type_GenericMeter
	readonly property string detailUrl: serviceType === "alternator" ? "/pages/settings/devicelist/dc-in/PageAlternator.qml"
			: _widgetOnlyPresentsDcGensets ? "/pages/settings/devicelist/PageGenset.qml"
			: "/pages/settings/devicelist/dc-in/PageDcMeter.qml"
	readonly property bool _widgetOnlyPresentsDcGensets: root.serviceType === "dcgenset" && inputDeviceModel.commonMeterType !== -1

	title: VenusOS.dcMeter_typeToText(inputType)
	enabled: true

	contentItem: ColumnLayout {
		spacing: Theme.geometry_overviewPage_widget_content_spacing

		WidgetHeader {
			text: root.title
			icon.source: VenusOS.dcMeter_iconForType(root.inputType)
			Layout.fillWidth: true
		}

		OverviewElectricalQuantityLabel {
			widgetSize: root.size
			dataObject: QtObject {
				readonly property real power: inputDeviceModel.totalPower
				readonly property real current: inputDeviceModel.totalCurrent
			}
			sourceType: VenusOS.ElectricalQuantity_Source_Dc
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
	}

	onClicked: {
		if (inputDeviceModel.count === 1) {
			Global.pageManager.pushPage(
						root.detailUrl,
						{ "bindPrefix": inputDeviceModel.firstObject.serviceUid })
		} else {
			Global.pageManager.pushPage(root._widgetOnlyPresentsDcGensets && Global.generators.multipleDcGensetsSupported
										? "/pages/settings/PageDcGensets.qml" : listPageComponent)
		}
	}

	DcMeterDeviceModel {
		id: inputDeviceModel
		serviceTypes: [ root.serviceType ]
		meterTypeFilter: root.inputTypeFilter
	}

	Component {
		id: listPageComponent

		Page {
			title: root.title

			GradientListView {
				header: QuantityGroupListHeader {
					width: parent.width
					metricsFontSize: Theme.font_listItem_secondary_size // align columns with those in the delegate
					rightPadding: Theme.geometry_page_content_horizontalMargin // list item right inset
							+ Theme.geometry_listItem_content_horizontalMargin // list item right padding
							+ Theme.geometry_icon_size_medium // arrow icon width
					textHorizontalAlignment: Text.AlignHCenter
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
