/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	property int index

	GradientListView {
		model: VisibleItemModel {

			Column {
				width: parent ? parent.width : 0
				spacing: Theme.geometry_gradientList_spacing

				Repeater {
					model: VeBusAcSensorModel { }

					ListText {
						//% "AC sensor %1 %2"
						text: qsTrId("vebus_device_ac_sensor_x_y").arg(root.index).arg(displayText)
						dataItem.uid: bindPrefix + pathSuffix
					}
				}
			}
		}
	}
}
