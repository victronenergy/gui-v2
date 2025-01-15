/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: firstCode

		uid: root.bindPrefix + "/Devices/0/ExtendStatus/GridRelayReport/Code"
	}

	GradientListView {
		model: AllowedItemModel {

			PrimaryListLabel {
				//% "VE.Bus Error 11 reporting requires minimum VE.Bus firmware version 454."
				text: qsTrId("vebus_error_11_reporting_requires_v454")
				allowed: !firstCode.seen
			}

			Column {
				width: parent ? parent.width : 0

				Repeater {
					model: 18

					PageVeBusError11Menu {
						bindPrefix: root.bindPrefix
						_index: index
					}
				}
			}
		}
	}
}
