/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: VisibleItemModel {
			ListSwitch {
				//% "Trusted"
				text: qsTrId("eebus_device_trusted")
				dataItem.uid: root.bindPrefix + "/Trusted"
				writeAccessLevel: VenusOS.User_AccessType_User
			}

			ListText {
				text: CommonWords.manufacturer
				dataItem.uid: root.bindPrefix + "/Brand"
			}

			ListText {
				text: CommonWords.model_name
				dataItem.uid: root.bindPrefix + "/Model"
			}

			ListText {
				//% "SKI"
				text: qsTrId("eebus_device_ski")
				dataItem.uid: root.bindPrefix + "/Ski"
			}

			ListText {
				text: CommonWords.type
				dataItem.uid: root.bindPrefix + "/Type"
			}

			ListSwitch {
				//% "Auto Accept"
				text: qsTrId("eebus_device_auto_accept")
				dataItem.uid: root.bindPrefix + "/AutoAccept"
				interactive: false
			}
		}
	}
}
