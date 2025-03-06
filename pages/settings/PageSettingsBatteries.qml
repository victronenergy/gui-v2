/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	title: CommonWords.batteries

	GradientListView {
		model: VisibleItemModel {
			ListRadioButtonGroup {
				id: batteryMonitorRadioButtons

				//% "Battery monitor"
				text: qsTrId("settings_system_battery_monitor")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/BatteryService"
				//% "Unavailable monitor, set another"
				defaultSecondaryText: qsTrId("settings_system_unavailable_monitor")

				VeQuickItem {
					id: availableBatteryServices

					uid: Global.system.serviceUid + "/AvailableBatteryServices"
					onValueChanged: {
						if (value === undefined) {
							return
						}
						const modelArray = Utils.jsonSettingsToModel(value)
						if (modelArray) {
							batteryMonitorRadioButtons.optionModel = modelArray
						} else {
							console.warn("Unable to parse data from", source)
						}
					}
				}
			}

			ListText {
				//% "Auto-selected"
				text: qsTrId("settings_system_auto_selected")
				dataItem.uid: Global.system.serviceUid + "/AutoSelectedBatteryService"
				preferredVisible: batteryMonitorRadioButtons.optionModel !== undefined
					&& batteryMonitorRadioButtons.currentIndex >= 0
					&& batteryMonitorRadioButtons.optionModel[batteryMonitorRadioButtons.currentIndex].value === "default"
			}

			SettingsColumn {
				width: parent ? parent.width : 0
				preferredVisible: batteryModel.count > 0

				Repeater {
					model: batteryModel
					width: parent.width
					delegate: ListItemBackground {
						id: batteryDelegate

						required property var device
						readonly property string serviceType: BackendConnection.serviceTypeFromUid(device.serviceUid)

						height: Theme.geometry_batteryListPage_item_height
						width: parent.width

						RowLayout {
							width: parent.width
							height: Theme.geometry_batteryListPage_item_height

							Column {
								id: leftColumn
								Layout.fillWidth: true
								Layout.leftMargin: Theme.geometry_listItem_content_horizontalMargin
								spacing: Theme.geometry_batteryListPage_item_verticalSpacing

								Label {
									id: nameLabel

									elide: Text.ElideRight
									text: batteryDelegate.device.customName
									font.pixelSize: Theme.font_size_body2
								}

								QuantityRow {
									id: measurementsRow

									readonly property real temperature: Global.systemSettings.convertFromCelsius(batteryDelegate.device.temperature)

									height: nameLabel.height
									showFirstSeparator: true    // otherwise this row does not align with the battery name
									tableMode: true
									model: QuantityObjectModel {
										filterType: QuantityObjectModel.HasValue

										QuantityObject { object: batteryDelegate.device; key: "voltage"; unit: VenusOS.Units_Volt_DC; defaultValue: "--" }
										QuantityObject { object: batteryDelegate.device; key: "current"; unit: VenusOS.Units_Amp }
										QuantityObject { object: batteryDelegate.device; key: "power"; unit: VenusOS.Units_Watt }
										QuantityObject { object: measurementsRow; key: "temperature"; unit: Global.systemSettings.temperatureUnit }
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
								spacing: Theme.geometry_batteryListPage_item_verticalSpacing

								QuantityLabel {
									id: socLabel

									readonly property int statusLevel: Theme.getValueStatus(value, VenusOS.Gauges_ValueType_FallingPercentage)

									width: parent.width
									height: nameLabel.height
									alignment: Text.AlignRight
									value: batteryDelegate.device.soc
									unit: VenusOS.Units_Percentage
									font.pixelSize: Theme.font_size_body2
									visible: !isNaN(batteryDelegate.device.soc)
									valueColor: batteryDelegate.device.mode === VenusOS.Battery_Mode_Idle ? Theme.color_font_primary
																										  : statusLevel === Theme.Critical ? Theme.color_red
																																		   : statusLevel === Theme.Warning ? Theme.color_orange
																																										   : Theme.color_green
									unitColor: batteryDelegate.device.mode === VenusOS.Battery_Mode_Idle ? Theme.color_font_secondary
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
									visible: !isNaN(batteryDelegate.device.power)
									text: {
										const modeText = VenusOS.battery_modeToText(batteryDelegate.device.mode)
										if (batteryDelegate.device.mode === VenusOS.Battery_Mode_Discharging
												&& batteryDelegate.device.timetogo > 0) {
											return modeText + " - " + Utils.formatBatteryTimeToGo(batteryDelegate.device.timetogo, VenusOS.Battery_TimeToGo_LongFormat)
										} else {
											return modeText
										}
									}
								}
							}

							CP.ColorImage {
								Layout.rightMargin: Theme.geometry_listItem_content_horizontalMargin
								source: "qrc:/images/icon_arrow_32.svg"
								rotation: 180
								color: pressArea.containsPress ? Theme.color_listItem_down_forwardIcon : Theme.color_listItem_forwardIcon
								opacity: pressArea.enabled ? 1 : 0
							}
						}

						ListPressArea {
							id: pressArea

							radius: parent.radius
							anchors.fill: parent
							enabled: batteryDelegate.device.instance >= 0
									 && ["vebus","genset","battery"].indexOf(batteryDelegate.serviceType) >= 0
							onClicked: {
								// TODO use a generic helper to open a page based on the service type/uid. See issue #1388
								if (batteryDelegate.serviceType === "vebus") {
									Global.pageManager.pushPage("/pages/vebusdevice/PageVeBus.qml", {
																	"bindPrefix": batteryDelegate.device.serviceUid
																})
								} else if (batteryDelegate.serviceType === "genset") {
									Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcIn.qml", {
																	"title": genericDevice.customName,
																	"bindPrefix": batteryDelegate.device.serviceUid
																})
								} else {
									Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBattery.qml", {
																	"bindPrefix": batteryDelegate.device.serviceUid,
																})
								}
							}
						}

						Device {
							id: genericDevice
							serviceUid: batteryDelegate.device.instance >= 0 ? batteryDelegate.device.serviceUid : ""
						}
					}
				}
			}

			ListNavigation {
				//% "Battery measurements"
				text: qsTrId("settings_system_battery_measurements")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsBatteryMeasurements.qml", { title: text })
			}
		}
	}

	SystemBatteryDeviceModel {
		id: batteryModel
	}
}
