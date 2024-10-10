/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	//% "Batteries"
	title: qsTrId("battery_list_page_title")

	GradientListView {
		model: batteryModel
		spacing: Theme.geometry_gradientList_spacing
		delegate: ListItemBackground {
			height: Theme.geometry_batteryListPage_item_height

			Column {
				anchors {
					left: parent.left
					leftMargin: Theme.geometry_listItem_content_horizontalMargin
					right: arrowIcon.left
					verticalCenter: parent.verticalCenter
				}
				spacing: Theme.geometry_batteryListPage_item_verticalSpacing

				Row {
					id: topRow
					width: parent.width

					Label {
						id: nameLabel

						width: parent.width - socLabel.width - Theme.geometry_listItem_content_spacing
						elide: Text.ElideRight
						text: modelData.name
						font.pixelSize: Theme.font_size_body2
					}

					QuantityLabel {
						id: socLabel

						height: nameLabel.height
						value: modelData.stateOfCharge
						unit: VenusOS.Units_Percentage
						font.pixelSize: Theme.font_size_body2
					}
				}

				Row {
					id: bottomRow
					width: parent.width

					QuantityRow {
						id: measurementsRow

						anchors.verticalCenter: parent.verticalCenter
						leftPadding: -(measurementsRow.quantityMetrics.spacing * 2) // align first quantity label with battery name
						height: parent.height

						model: [
							{ value: modelData.voltage, unit: VenusOS.Units_Volt_DC },
							{ value: modelData.current, unit: VenusOS.Units_Amp },
							{ value: modelData.power, unit: VenusOS.Units_Watt },
							{
								value: Global.systemSettings.convertFromCelsius(modelData.temperature),
								unit: Global.systemSettings.temperatureUnit
							}
						]
					}

					Label {
						anchors.verticalCenter: parent.verticalCenter
						width: parent.width - measurementsRow.width - Theme.geometry_listItem_content_spacing
						elide: Text.ElideRight
						font.pixelSize: Theme.font_size_body2
						color: Theme.color_listItem_secondaryText
						text: {
							const modeText = Global.batteries.modeToText(modelData.mode)
							if (modelData.mode === VenusOS.Battery_Mode_Discharging) {
								return modeText + " - " + Global.batteries.timeToGoText(modelData, VenusOS.Battery_TimeToGo_LongFormat)
							}
							return modeText
						}
						horizontalAlignment: Text.AlignRight
					}

				}
			}

			CP.ColorImage {
				id: arrowIcon

				anchors {
					right: parent.right
					rightMargin: Theme.geometry_listItem_content_horizontalMargin
					verticalCenter: parent.verticalCenter
				}
				source: "qrc:/images/icon_arrow_32.svg"
				rotation: 180
				color: mouseArea.containsPress ? Theme.color_listItem_down_forwardIcon : Theme.color_listItem_forwardIcon
			}

			ListPressArea {
				id: mouseArea

				radius: parent.radius
				anchors.fill: parent
				onClicked: {
					if (BackendConnection.serviceTypeFromUid(modelData.serviceUid) === "vebus") {
						const deviceIndex = Global.inverterChargers.veBusDevices.indexOf(modelData.serviceUid)
						if (deviceIndex >= 0) {
							const veBusDevice = Global.inverterChargers.veBusDevices.deviceAt(deviceIndex)
							Global.pageManager.pushPage( "/pages/vebusdevice/PageVeBus.qml", {
								"title": veBusDevice.name,
								"veBusDevice": veBusDevice
							})
						}
						return
					}

					Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBattery.qml",
							{ "title": modelData.name, "battery": modelData })
				}
			}
		}
	}

	// A model of Battery objects, generated from com.victronenergy.system/Batteries.
	DeviceModel {
		id: batteryModel
	}

	VeQuickItem {
		uid: Global.system.serviceUid + "/Batteries"
		onValueChanged: {
			let i
			if (!isValid) {
				batteryModel.deleteAllAndClear()
				return
			}
			// Value is a list of key-value pairs with info about each battery.
			const batteryUids = value.map((info) => BackendConnection.serviceUidFromName(info.id, info.instance))

			// Remove batteries that are not in this list
			batteryModel.intersect(batteryUids)

			// Add new battery objects
			for (i = 0; i < batteryUids.length; ++i) {
				if (batteryModel.indexOf(batteryUids[i]) < 0) {
					batteryComponent.createObject(batteryModel, { serviceUid: batteryUids[i] })
				}
			}
		}
	}

	Component {
		id: batteryComponent

		Battery {
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
