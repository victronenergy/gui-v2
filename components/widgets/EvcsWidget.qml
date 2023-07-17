/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

OverviewWidget {
	id: root

	//: Abbreviation of Electric Vehicle Charging Station
	//% "EVCS"
	title: qsTrId("overview_widget_evcs_title")
	icon.source: "qrc:/images/icon_charging_station_24.svg"
	type: VenusOS.OverviewWidget_Type_Evcs
	enabled: true
	quantityLabel.dataObject: { "power": Global.evChargers.power, "current": NaN }

	extraContent.children: [
		Loader {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry.overviewPage.widget.content.horizontalMargin + root.rightPadding
				bottom: parent.bottom
				bottomMargin: Theme.geometry.overviewPage.widget.extraContent.bottomMargin
			}
			sourceComponent: Global.evChargers.model.count > 1 ? multiEvChargerComponent
					: Global.evChargers.model.count > 0 ? singleEvChargerComponent
					: null
		}
	]

	MouseArea {
		anchors.fill: parent
		onClicked: {
			if (Global.evChargers.model.count === 1) {
				Global.pageManager.pushPage("/pages/evcs/EvChargerPage.qml",
						{ "evCharger": Global.evChargers.model.get(0).evCharger })
			} else {
				Global.pageManager.pushPage("/pages/evcs/EvChargerListPage.qml")
			}
		}
	}

	Component {
		id: singleEvChargerComponent

		Column {
			readonly property var evCharger: Global.evChargers.model.objectAt(0)

			width: parent.width

			ElectricalQuantityLabel {
				height: chargingTimeLabel.height // use normal label height, instead of default baseline calculation
				value: evCharger.energy
				valueColor: unitColor
			}

			Label {
				width: parent.width
				elide: Text.ElideRight
				text: Global.evChargers.chargerStatusToText(evCharger.status)
				color: Theme.color.font.secondary
			}

			Row {
				width: parent.width
				spacing: Theme.geometry.overviewPage.widget.content.horizontalMargin / 2

				Label {
					width: parent.width - chargingTimeLabel.width
					elide: Text.ElideRight
					text: Global.evChargers.chargerModeToText(evCharger.mode)
					color: Theme.color.font.secondary
				}

				FixedWidthLabel {
					id: chargingTimeLabel

					text: Utils.formatAsHHMM(evCharger.chargingTime, true)
					color: Theme.color.font.secondary
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
						color: Theme.color.font.secondary
					}

					Label {
						id: chargerCountLabel

						text: model.statusCount || "-"
						color: Theme.color.font.secondary
					}
				}
			}
		}
	}
}
