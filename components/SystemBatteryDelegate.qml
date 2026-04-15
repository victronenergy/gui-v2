/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ListItem {
	id: root

	required property SystemBatteryDeviceModel.Battery device
	readonly property string serviceType: BackendConnection.serviceTypeFromUid(device.serviceUid)

	readonly property bool _clickable: root.device.deviceInstance >= 0
			&& ["vebus","genset","battery"].indexOf(root.serviceType) >= 0

	function click() {
		if (!_clickable) {
			return
		}

		// TODO use a generic helper to open a page based on the service type/uid. See issue #1388
		if (root.serviceType === "vebus") {
			Global.pageManager.pushPage("/pages/vebusdevice/PageVeBus.qml", {
				"bindPrefix": root.device.serviceUid
			})
		} else if (root.serviceType === "genset") {
			Global.pageManager.pushPage("/pages/settings/devicelist/PageGenset.qml", {
				"bindPrefix": root.device.serviceUid
			})
		} else {
			Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBattery.qml", {
				"bindPrefix": root.device.serviceUid,
			})
		}
	}

	hasSubMenu: _clickable

	// Landscape layout:
	// | Primary label            SOC | Arrow |
	// | Quantity row | Charging mode | icon |
	//
	// Portrait layout:
	// | Primary label   SOC |            |
	// | Quantity row        | Arrow icon |
	// | Charging mode       |            |
	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: contentLayout.height

		GridLayout {
			id: contentLayout

			anchors.verticalCenter: parent.verticalCenter
			width: parent.width - arrowIcon.width - Theme.geometry_listItem_arrow_leftMargin
			columns: Theme.screenSize === Theme.Portrait ? 1 : 2
			rowSpacing: Theme.geometry_listItem_content_verticalSpacing
			columnSpacing: root.spacing

			RowLayout {
				Layout.columnSpan: Theme.screenSize === Theme.Portrait ? 1 : 2

				Label {
					elide: Text.ElideRight
					text: root.device.customName
					font: root.font
					wrapMode: Text.Wrap

					Layout.fillWidth: true
				}

				QuantityLabel {
					readonly property int statusLevel: Theme.getValueStatus(value, VenusOS.Gauges_ValueType_FallingPercentage)

					value: root.device.stateOfCharge
					unit: VenusOS.Units_Percentage
					font: root.font
					visible: !isNaN(root.device.stateOfCharge)
					valueColor: root.device.mode === VenusOS.Battery_Mode_Idle ? Theme.color_font_primary
							: statusLevel === Theme.Critical ? Theme.color_red
							: statusLevel === Theme.Warning ? Theme.color_orange
							: Theme.color_green
					unitColor: root.device.mode === VenusOS.Battery_Mode_Idle ? Theme.color_font_secondary
							: statusLevel === Theme.Critical ? Theme.color_red
							: statusLevel === Theme.Warning ? Theme.color_orange
							: Theme.color_green

					Layout.alignment: Qt.AlignTop
				}
			}

			QuantityRow {
				model: QuantityObjectModel {
					filterType: QuantityObjectModel.HasValue

					QuantityObject { object: root.device; key: "voltage"; unit: VenusOS.Units_Volt_DC; defaultValue: "--" }
					QuantityObject { object: root.device; key: "current"; unit: VenusOS.Units_Amp }
					QuantityObject { object: root.device; key: "power"; unit: VenusOS.Units_Watt }
					QuantityObject { object: root.device; key: "temperature"; unit: Global.systemSettings.temperatureUnit }
				}
				Layout.fillWidth: true
			}

			Label {
				elide: Text.ElideRight
				font: root.font
				color: Theme.color_listItem_secondaryText
				visible: !isNaN(root.device.power)
				text: {
					const modeText = VenusOS.battery_modeToText(root.device.mode)
					if (root.device.mode === VenusOS.Battery_Mode_Discharging
							&& root.device.timeToGo > 0) {
						return modeText + " - " + Utils.formatBatteryTimeToGo(root.device.timeToGo, VenusOS.Battery_TimeToGo_LongFormat)
					} else {
						return modeText
					}
				}
			}
		}

		ForwardIcon {
			id: arrowIcon

			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			opacity: root._clickable ? 1 : 0
		}
	}

	background: ListItemBackground {
		ListPressArea {
			anchors.fill: parent
			enabled: root._clickable
			onClicked: root.click()
		}
	}

	Keys.onSpacePressed: click()
	Keys.onRightPressed: click()
	Keys.enabled: Global.keyNavigationEnabled && _clickable
}
