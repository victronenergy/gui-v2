/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string bindPrefix

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				ListSwitch {
					//% "Trusted"
					text: qsTrId("eebus_device_trusted")
					dataItem.uid: root.bindPrefix + "/Trusted"
					writeAccessLevel: VenusOS.User_AccessType_User
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.manufacturer
					dataItem.uid: root.bindPrefix + "/Brand"
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.model_name
					dataItem.uid: root.bindPrefix + "/Model"
				}
			}

			DelegateComponent {
				ListText {
					//% "Host"
					text: qsTrId("eebus_device_host")
					dataItem.uid: root.bindPrefix + "/Host"
				}
			}

			DelegateComponent {
				ListText {
					//% "SKI"
					text: qsTrId("eebus_device_ski")
					dataItem.uid: root.bindPrefix + "/Ski"
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.type
					dataItem.uid: root.bindPrefix + "/Type"
				}
			}

			DelegateComponent {
				ListSwitch {
					//% "Auto Accept"
					text: qsTrId("eebus_device_auto_accept")
					dataItem.uid: root.bindPrefix + "/AutoAccept"
					interactive: false
				}
			}
		}
	}
}
