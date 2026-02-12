/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListItemControl {
	id: root

	required property SystemBatteryDeviceModel.Battery device
	readonly property string serviceType: BackendConnection.serviceTypeFromUid(device.serviceUid)

	readonly property bool _clickable: root.device.deviceInstance >= 0
			&& ["vebus","genset","battery"].indexOf(root.serviceType) >= 0

	function click() {
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

	contentItem: RowLayout {
		spacing: 0

		Column {
			id: leftColumn
			Layout.fillWidth: true
			spacing: Theme.geometry_listItem_content_verticalSpacing

			Label {
				id: nameLabel

				elide: Text.ElideRight
				text: root.device.customName
				font.pixelSize: Theme.font_size_body2
			}

			QuantityRow {
				showFirstSeparator: true    // otherwise this row does not align with the battery name
				model: QuantityObjectModel {
					filterType: QuantityObjectModel.HasValue

					QuantityObject { object: root.device; key: "voltage"; unit: VenusOS.Units_Volt_DC; defaultValue: "--" }
					QuantityObject { object: root.device; key: "current"; unit: VenusOS.Units_Amp }
					QuantityObject { object: root.device; key: "power"; unit: VenusOS.Units_Watt }
					QuantityObject { object: root.device; key: "temperature"; unit: Global.systemSettings.temperatureUnit }
				}

				// Show additional separator at the end, to balance with the first separator.
				Rectangle {
					width: Theme.geometry_listItem_separator_width
					height: nameLabel.height
					color: Theme.color_listItem_separator
				}
			}
		}

		Column {
			Layout.fillWidth: true
			spacing: Theme.geometry_listItem_content_verticalSpacing

			QuantityLabel {
				id: socLabel

				readonly property int statusLevel: Theme.getValueStatus(value, VenusOS.Gauges_ValueType_FallingPercentage)

				width: parent.width
				height: nameLabel.height
				alignment: Text.AlignRight
				value: root.device.stateOfCharge
				unit: VenusOS.Units_Percentage
				font.pixelSize: Theme.font_size_body2
				visible: !isNaN(root.device.stateOfCharge)
				valueColor: root.device.mode === VenusOS.Battery_Mode_Idle ? Theme.color_font_primary
						: statusLevel === Theme.Critical ? Theme.color_red
						: statusLevel === Theme.Warning ? Theme.color_orange
						: Theme.color_green
				unitColor: root.device.mode === VenusOS.Battery_Mode_Idle ? Theme.color_font_secondary
						: statusLevel === Theme.Critical ? Theme.color_red
						: statusLevel === Theme.Warning ? Theme.color_orange
						: Theme.color_green
			}

			Label {
				id: modeLabel
				width: parent.width
				horizontalAlignment: Text.AlignRight
				elide: Text.ElideRight
				font.pixelSize: Theme.font_size_body2
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

		CP.ColorImage {
			source: "qrc:/images/icon_arrow_32.svg"
			rotation: 180
			color: Theme.color_listItem_forwardIcon
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
