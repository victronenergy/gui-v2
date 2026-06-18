/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

OverviewWidget {
	id: root

	property bool stretchHorizontally

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
	type: VenusOS.OverviewWidget_Type_Evcs
	preferredSize: VenusOS.OverviewWidget_PreferredSize_LargeOnly
	enabled: true

	contentItem: GridLayout {
		columnSpacing: 0
		rowSpacing: Theme.geometry_overviewPage_widget_content_spacing
		columns: root.stretchHorizontally ? 2 : 1
		rows: root.stretchHorizontally ? 2 : 3
		flow: GridLayout.TopToBottom

		WidgetHeader {
			text: root.title
			icon.source: "qrc:/images/icon_charging_station_24.svg"
			Layout.fillWidth: true
		}

		OverviewElectricalQuantityLabel {
			widgetSize: root.size
			dataObject: Global.evChargers
			sourceType: VenusOS.ElectricalQuantity_Source_Ac
			font.pixelSize: detailLoader.active && root.size === VenusOS.OverviewWidget_Size_M
					? Theme.font_overviewPage_widget_quantityLabel_medium
					: Theme.font_overviewPage_widget_quantityLabel_large
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.preferredWidth: root.stretchHorizontally
					? (parent.width/2 + Theme.geometry_overviewPage_widget_spacing)  // push details to the right
					: -1
		}

		Loader {
			id: detailLoader
			active: root.size >= VenusOS.OverviewWidget_Size_M
			sourceComponent: Global.evChargers.model.count > 1 ? multiEvChargerComponent
					: Global.evChargers.model.count > 0 && Global.evChargers.model.firstObject ? singleEvChargerComponent
					: null
			Layout.fillWidth: true
			Layout.rowSpan: root.stretchHorizontally ? parent.rows : 1
			Layout.alignment: Qt.AlignTop
		}
	}

	Component {
		id: singleEvChargerComponent

		Column {
			id: singleCharger

			readonly property string serviceUid: Global.evChargers.model.firstObject.serviceUid

			width: parent.width

			QuantityLabel {
				height: chargingTimeLabel.height // use normal label height, instead of default baseline calculation
				value: energyItem.value ?? NaN
				valueColor: unitColor
				alignment: Qt.AlignLeft
				unit: VenusOS.Units_Energy_KiloWattHour
				font.pixelSize: root.tertiaryFontSize

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
				font.pixelSize: root.tertiaryFontSize

				VeQuickItem {
					id: statusItem
					uid: singleCharger.serviceUid + "/Status"
				}
			}

			Row {
				width: parent.width
				height: chargingTimeLabel.height
				spacing: Theme.geometry_overviewPage_widget_content_horizontalMargin / 2

				Label {
					width: parent.width - chargingTimeLabel.width - parent.spacing
					elide: Text.ElideRight
					text: Global.evChargers.chargerModeToText(modeItem.value)
					color: Theme.color_font_secondary
					font.pixelSize: root.tertiaryFontSize

					VeQuickItem {
						id: modeItem
						uid: singleCharger.serviceUid + "/Mode"
					}
				}

				FixedWidthLabel {
					id: chargingTimeLabel

					text: chargingTimeItem.value >= 60 ? Utils.formatAsHHMM(chargingTimeItem.value, true) : Utils.formatAsHHMMSS(chargingTimeItem.value, true)
					color: Theme.color_font_secondary
					font.pixelSize: root.tertiaryFontSize
					// do not show value under a second
					visible: chargingTimeItem.value > 0

					VeQuickItem {
						id: chargingTimeItem
						uid: singleCharger.serviceUid + "/Session/Time"
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
						font.pixelSize: root.tertiaryFontSize
						color: Theme.color_font_secondary
					}

					Label {
						id: chargerCountLabel

						text: model.statusCount || "-"
						color: Theme.color_font_secondary
						font.pixelSize: root.tertiaryFontSize
					}
				}
			}
		}
	}
}
