/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

OverviewWidget {
	id: root

	onClicked: Global.pageManager.pushPage(consumptionPageComponent, { "title": root.title })

	//% "DC Loads"
	title: qsTrId("overview_widget_dcloads_title")
	icon.source: "qrc:/images/dcloads.svg"
	type: VenusOS.OverviewWidget_Type_DcLoads
	enabled: Global.dcLoads.model.count > 0

	quantityLabel.dataObject: Global.system.dc

	Component {
		id: consumptionPageComponent

		Page {
			GradientListView {
				model: Global.dcLoads.model

				delegate: ListTextGroup {
					id: deviceDelegate

					required property var device

					text: device.name
					textModel: [
						Units.getCombinedDisplayText(VenusOS.Units_Volt_DC, device.voltage),
						Units.getCombinedDisplayText(VenusOS.Units_Amp, device.current),
						Units.getCombinedDisplayText(VenusOS.Units_Watt, device.power),
					]

					ListPressArea {
						id: delegatePressArea

						radius: backgroundRect.radius
						anchors {
							fill: parent
							bottomMargin: deviceDelegate.spacing
						}
						onClicked: {
							if (BackendConnection.serviceTypeFromUid(device.serviceUid) === "dcdc") {
								Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcDcConverter.qml",
										{ "title": device.name, "bindPrefix": device.serviceUid })
							} else {
								  Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcMeter.qml",
										{ "title": device.name, "bindPrefix": device.serviceUid })
							}
						}
					}

					CP.ColorImage {
						parent: deviceDelegate.content
						anchors.verticalCenter: parent.verticalCenter
						source: "qrc:/images/icon_arrow_32.svg"
						rotation: 180
						color: delegatePressArea.containsPress ? Theme.color_listItem_down_forwardIcon : Theme.color_listItem_forwardIcon
					}
				}
			}
		}
	}
}
