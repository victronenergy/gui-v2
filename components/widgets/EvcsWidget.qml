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
	quantityLabel.dataObject: Global.evChargers

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
					: Global.evChargers.model.count > 0 && Global.evChargers.model.firstObject ? singleEvChargerComponent
					: null
		}
	]

	Component {
		id: singleEvChargerComponent

		Column {
			id: singleCharger

			readonly property string serviceUid: Global.evChargers.model.firstObject.serviceUid

			width: parent.width

			ElectricalQuantityLabel {
				height: chargingTimeLabel.height // use normal label height, instead of default baseline calculation
				value: energyItem.value ?? NaN
				valueColor: unitColor
				alignment: Qt.AlignLeft
				unit: VenusOS.Units_Energy_KiloWattHour

				VeQuickItem {
					id: energyItem
					uid: singleCharger.serviceUid + "/Session/Energy"
				}
			}

			Label {
				width: parent.width
				elide: Text.ElideRight
				text: Global.evChargers.chargerStatusToText(statusItem.value)
				color: Theme.color_font_secondary
				visible: statusItem.valid

				VeQuickItem {
					id: statusItem
					uid: singleCharger.serviceUid + "/Status"
				}
			}

			Row {
				width: parent.width
				spacing: Theme.geometry_overviewPage_widget_content_horizontalMargin / 2

				Label {
					width: parent.width - chargingTimeLabel.width - parent.spacing
					elide: Text.ElideRight
					text: Global.evChargers.chargerModeToText(modeItem.value)
					color: Theme.color_font_secondary

					VeQuickItem {
						id: modeItem
						uid: singleCharger.serviceUid + "/Mode"
					}
				}

				FixedWidthLabel {
					id: chargingTimeLabel

					text: chargingTimeItem.value > 60 ? Utils.formatAsHHMM(chargingTimeItem.value, true) : Utils.formatAsHHMMSS(chargingTimeItem.value, true)
					color: Theme.color_font_secondary
					// do not show value under a second
					visible: chargingTimeItem.value > 0

					VeQuickItem {
						id: chargingTimeItem
						uid: singleCharger.serviceUid + "/ChargingTime"
					}
				}
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
