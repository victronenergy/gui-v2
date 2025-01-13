/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: VisibleItemModel {
			Column {
				width: parent ? parent.width : 0

				Repeater {
					model: 4

					ListNavigation {
						text: CommonWords.ac_sensor_x.arg(index)
						onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageAcSensor.qml", {
									   "title": CommonWords.ac_sensor_x.arg(index),
									   "bindPrefix": root.bindPrefix + "/" + index,
									   "index": index
						})
					}
				}
			}
		}
	}
}
