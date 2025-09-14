/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	onClicked: {
		if (Global.evChargers.model.count === 1) {
			Global.pageManager.pushPage("/pages/evcs/EvChargerPage.qml",
					{ bindPrefix: Global.evChargers.model.firstObject.serviceUid })
		} else {
			Global.pageManager.pushPage("/pages/evcs/EvChargerListPage.qml")
		}
	}

	//: Abbreviation of Electric Vehicle Charging Station
	//% "EVCS"
	title: qsTrId("overview_widget_evcs_title")
	icon.source: "qrc:/images/icon_charging_station_24.svg"
	type: VenusOS.OverviewWidget_Type_Evcs
	preferredSize: VenusOS.OverviewWidget_PreferredSize_LargeOnly
	enabled: true
	quantityLabel.dataObject: { "power": Global.evChargers.power, "current": Global.evChargers.current }
	quantityLabel.font.pixelSize: Theme.font_size_body2
	quantityLabel.alignment: Qt.AlignLeft

	extraContentChildren: [
		Loader {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin + root.rightPadding
				bottom: parent.bottom
				bottomMargin: root.verticalMargin
			}
			active: root.size >= VenusOS.OverviewWidget_Size_M
			sourceComponent: Global.evChargers.model.count > 1 ? multiEvChargerComponent
					: Global.evChargers.model.count > 0 ? singleEvChargerComponent : null
		}
	]

	Component {
		id: singleEvChargerComponent

		Column {
			readonly property var evCharger: Global.evChargers.model.deviceAt(0)
			readonly property var evDevice: Global.allDevicesModel.evDevices.count > 0
											? Global.allDevicesModel.evDevices.deviceAt(0)
											: null
			width: parent.width
			spacing: 3

			// Row 1: Energy and charging time
			Row {
				width: parent.width
				spacing: Theme.geometry_overviewPage_widget_content_horizontalMargin / 2

				ElectricalQuantityLabel {
					width: parent.width - chargingTimeLabel.width - parent.spacing
					height: chargingTimeLabel.height
					value: evCharger.energy
					valueColor: unitColor
					alignment: Qt.AlignLeft
					unit: VenusOS.Units_Energy_KiloWattHour
				}

				Label {
					id: chargingTimeLabel
					text: {
						if (isNaN(evCharger.chargingTime) || evCharger.chargingTime < 0) {
							return "--h --m"
						}
						const duration = Utils.decomposeDuration(evCharger.chargingTime)
						return duration.h + "h " + Utils.pad(duration.m, 2) + "m"
					}
					color: Theme.color_font_secondary
					font.pixelSize: Theme.font_size_caption
					horizontalAlignment: Text.AlignRight
				}
			}

			// Row 2: Status and mode
			Row {
				width: parent.width
				spacing: Theme.geometry_overviewPage_widget_content_horizontalMargin / 2

				Label {
					width: parent.width - modeLabel.width - parent.spacing
					elide: Text.ElideRight
					text: Global.evChargers.chargerStatusToText(evCharger.status)
					color: Theme.color_font_secondary
					font.pixelSize: Theme.font_size_caption
				}

				Label {
					id: modeLabel
					text: Global.evChargers.chargerModeToText(evCharger.mode)
					color: Theme.color_font_secondary
					font.pixelSize: Theme.font_size_caption
					horizontalAlignment: Text.AlignRight
				}
			}

			// Separator line - only show when there's an EV device
			Rectangle {
				width: parent.width
				height: 1
				color: Theme.color_listItem_separator
				visible: evDevice !== null
			}

			// Row 3: EV info header with icon and model name
			Row {
				width: parent.width
				spacing: 4
				visible: evDevice !== null

				Label {
					text: "🚗"
					color: Theme.color_font_secondary
					font.pixelSize: 14
					anchors.verticalCenter: parent.verticalCenter
				}

				Label {
					text: evDevice && customNameItem.valid && customNameItem.value
						  ? customNameItem.value
						  : evDevice && evDevice.name
						  ? evDevice.name
						  : "EV"
					color: Theme.color_font_secondary
					font.pixelSize: Theme.font_size_caption
					anchors.verticalCenter: parent.verticalCenter
					elide: Text.ElideRight
					width: parent.width - parent.spacing - 16
				}
			}

			// Row 4: Range and SOC info
			Row {
				width: parent.width
				spacing: Theme.geometry_overviewPage_widget_content_horizontalMargin / 2
				visible: evDevice !== null

				Label {
					text: rangeItem.valid ? Math.round(rangeItem.value) + " km" : "-- km"
					color: Theme.color_font_secondary
					font.pixelSize: Theme.font_size_caption
				}

				Item {
					// Spacer to push SOC to the right
					width: parent.width - rangeLabel.width - socLabel.width - (2 * parent.spacing)
					height: 1
				}

				Label {
					id: socLabel
					text: {
						const soc = socItem.valid ? Math.round(socItem.value) : NaN
						const targetSoc = targetSocItem.valid ? Math.round(targetSocItem.value) : NaN

						if (!isNaN(soc) && !isNaN(targetSoc)) {
							return soc + "/" + targetSoc + " %"
						} else if (!isNaN(soc)) {
							return soc + " %"
						} else {
							return "-- %"
						}
					}
					color: Theme.color_font_secondary
					font.pixelSize: Theme.font_size_caption
					horizontalAlignment: Text.AlignRight
				}

				Label {
					id: rangeLabel
					visible: false
					text: rangeItem.valid ? Math.round(rangeItem.value) + " km" : "-- km"
					font.pixelSize: Theme.font_size_caption
				}
			}

			// VeQuickItems for EV data
			VeQuickItem {
				id: customNameItem
				uid: evDevice ? evDevice.serviceUid + "/CustomName" : ""
			}

			VeQuickItem {
				id: rangeItem
				uid: evDevice ? evDevice.serviceUid + "/RangeToGo" : ""
			}

			VeQuickItem {
				id: socItem
				uid: evDevice ? evDevice.serviceUid + "/Soc" : ""
			}

			VeQuickItem {
				id: targetSocItem
				uid: evDevice ? evDevice.serviceUid + "/TargetSoc" : ""
			}
		}
	}

	Component {
		id: multiEvChargerComponent

		Column {
			width: parent.width

			Repeater {
				model: EvChargerStatusModel {}

				delegate: Row {
					width: parent.width

					Label {
						width: parent.width - chargerCountLabel.implicitWidth
						elide: Text.ElideRight
						text: Global.evChargers.chargerStatusToText(model.status)
						color: Theme.color_font_secondary
					}

					Label {
						id: chargerCountLabel
						text: model.statusCount || "-"
						color: Theme.color_font_secondary
					}
				}
			}
		}
	}
}
