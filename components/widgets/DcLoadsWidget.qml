/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Units

OverviewWidget {
	id: root

	//% "DC Loads"
	title: qsTrId("overview_widget_dcloads_title")
	icon.source: "qrc:/images/dcloads.svg"
	type: Enums.OverviewWidget_Type_DcLoads
	enabled: (Global.dcLoads.model.count + Global.dcSystems.model.count) > 0

	quantityLabel.dataObject: Global.system.dc

	MouseArea {
		anchors.fill: parent
		onClicked: {
			Global.pageManager.pushPage(consumptionPageComponent, { "title": root.title })
		}
	}

	Component {
		id: consumptionPageComponent

		Page {
			GradientListView {
				model: Global.dcLoads.model.count + Global.dcSystems.model.count

				delegate: ListTextGroup {
					id: deviceDelegate

					readonly property var device: model.index < Global.dcLoads.model.count
							? Global.dcLoads.model.deviceAt(model.index)
							: Global.dcSystems.model.deviceAt(model.index - Global.dcLoads.model.count)

					text: device.name
					textModel: [
						Units.getCombinedDisplayText(Enums.Units_Volt, device.voltage),
						Units.getCombinedDisplayText(Enums.Units_Amp, device.current),
						Units.getCombinedDisplayText(Enums.Units_Watt, device.power),
					]

					MouseArea {
						id: delegateMouseArea

						anchors.fill: parent
						onClicked: {
							Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcMeter.qml",
									{ "title": device.name, "bindPrefix": device.serviceUid })
						}
					}

					CP.ColorImage {
						parent: deviceDelegate.content
						anchors.verticalCenter: parent.verticalCenter
						source: "/images/icon_back_32.svg"
						rotation: 180
						color: delegateMouseArea.containsPress ? Theme.color.listItem.down.forwardIcon : Theme.color.listItem.forwardIcon
						fillMode: Image.PreserveAspectFit
					}
				}
			}
		}
	}
}
