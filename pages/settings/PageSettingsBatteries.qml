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
		model: AllowedItemModel {
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
				allowed: batteryMonitorRadioButtons.optionModel !== undefined
					&& batteryMonitorRadioButtons.currentIndex >= 0
					&& batteryMonitorRadioButtons.optionModel[batteryMonitorRadioButtons.currentIndex].value === "default"
			}

			Column {
				spacing: Theme.geometry_gradientList_spacing
				bottomPadding: Theme.geometry_gradientList_spacing
				width: parent ? parent.width : 0
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

									height: nameLabel.height
									showFirstSeparator: true    // otherwise this row does not align with the battery name

									model: [
										{ value: batteryDelegate.device.voltage, unit: VenusOS.Units_Volt_DC },
										{ value: batteryDelegate.device.current, unit: VenusOS.Units_Amp, visible: !isNaN(batteryDelegate.device.current) },
										{ value: batteryDelegate.device.power, unit: VenusOS.Units_Watt, visible: !isNaN(batteryDelegate.device.power) },
										{
											value: Global.systemSettings.convertFromCelsius(batteryDelegate.device.temperature),
											unit: Global.systemSettings.temperatureUnit,
											visible: !isNaN(batteryDelegate.device.temperature)
										}
									]

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
								color: mouseArea.containsPress ? Theme.color_listItem_down_forwardIcon : Theme.color_listItem_forwardIcon
								opacity: mouseArea.enabled ? 1 : 0
							}
						}

						ListPressArea {
							id: mouseArea

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

	// A model of Battery objects, generated from com.victronenergy.system/Batteries.
	DeviceModel {
		id: batteryModel
	}

	// The battery list is a list of JSON values like this:
	// [{'active_battery_service': 1,'current': 55,'id': com.victronenergy.battery.ttyO0,'instance': 256,'name': House battery,'power': 1337,'soc': 98.4,'state': 1,'timetogo': 38040,'voltage': 24.3}]
	// Only 'id', 'name' and 'active_battery_service' are guaranteed to be present for each battery.
	VeQuickItem {
		uid: Global.system.serviceUid + "/Batteries"
		onValueChanged: {
			if (!isValid) {
				batteryModel.deleteAllAndClear()
				return
			}

			const batteryList = value
			let batteryUids = []
			let i
			for (i = 0; i < batteryList.length; ++i) {
				const serviceName = batteryList[i].id
				if (batteryList[i].instance === undefined) {
					// This is a not a real battery; there is an id number on the end of the service
					// name, like com.victronenergy.battery.ttyUSB1:1, and there is no device
					// 'instance'. So, use the service name as the uid, else if we use a dummy
					// instance, it might be the same as the instance of a real battery, and they
					// would have the same uids within the device model.
					// (Normally the service name couldn't be used as the uid, but since the JSON
					// provides all data to be shown in the battery list, the uid won't be used to
					// fetch any other data.)
					batteryUids.push(serviceName)
				} else {
					// This is a real battery, with a valid (device) instance.
					batteryUids.push(BackendConnection.serviceUidFromName(serviceName, batteryList[i].instance))
				}
			}

			// Remove batteries that are not in this list
			batteryModel.intersect(batteryUids)

			// Add new battery objects, or update existing ones in the list.
			const propertyNames = [ "current", "instance", "power", "soc", "temperature", "timetogo", "voltage" ]
			for (i = 0; i < batteryUids.length; ++i) {
				const batteryInfo = batteryList[i]
				let batteryObject
				const batteryIndex = batteryModel.indexOf(batteryUids[i])
				if (batteryIndex < 0) {
					batteryObject = batteryComponent.createObject(batteryModel, {
																	  serviceUid: batteryUids[i],
																	  deviceInstance: batteryInfo.instance || 0,  // always provide an instance so that BaseDevice::valid, so device is added to model
																	  customName: batteryInfo.name || "",
																  })
				} else {
					batteryObject = batteryModel.deviceAt(batteryIndex)
				}
				for (const propertyName of propertyNames) {
					if (batteryInfo[propertyName] !== undefined) {
						batteryObject[propertyName] = batteryInfo[propertyName]
					}
				}
			}
		}
	}

	component BatteryListDevice : BaseDevice {
		id: battery

		property real current: NaN
		property int instance: -1
		property real power: NaN
		property real soc: NaN
		property real temperature: NaN
		property int timetogo: 0
		property real voltage: NaN
		readonly property int mode: VenusOS.battery_modeFromPower(power)

		name: customName
	}

	Component {
		id: batteryComponent

		BatteryListDevice {
			id: battery

			onValidChanged: {
				if (valid) {
					batteryModel.addDevice(battery)
				} else {
					batteryModel.removeDevice(battery.serviceUid)
					battery.destroy()
				}
			}
		}
	}
}
