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
		model: DelegateComponentModel {

			DelegateComponent {
				id: statusDC
				dataItem: VeQuickItem { uid: root.bindPrefix + "/Connected" }
				ListText {
					id: status
					text: CommonWords.status
					secondaryText: CommonWords.onlineOrOffline(dataItem.value)
					dataItem.uid: root.bindPrefix + "/Connected"
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.model_name
					dataItem.uid: root.bindPrefix + "/ModelName"
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.custom_name
					dataItem.uid: root.bindPrefix + "/CustomName"
				}
			}

			DelegateComponent {
				PrimaryListLabel {
					//% "Careful, for ESS systems, as well as systems with a managed battery, the CAN-bus device instance must remain configured to 0. See GX manual for more information."
					text: qsTrId("settings_vecan_instance_zero_warning")
				}
			}

			DelegateComponent {
				ListSpinBox {
					//% "VE.Can Device Instance"
					text: qsTrId("settings_vecan_device_instance")
					dataItem.uid: root.bindPrefix + "/DeviceInstance"
					enabled: statusDC.dataItem.value === 1
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.manufacturer
					dataItem.uid: root.bindPrefix + "/Manufacturer"
				}
			}

			DelegateComponent {
				ListText {
					//% "Network Address"
					text: qsTrId("settings_vecan_nad")
					dataItem.uid: root.bindPrefix + "/Nad"
				}
			}

			DelegateComponent {
				ListFirmwareVersion {
					bindPrefix: root.bindPrefix
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.serial_number
					dataItem.uid: root.bindPrefix + "/Serial"
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.unique_identity_number
					dataItem.uid: root.bindPrefix + "/N2kUniqueNumber"
				}
			}
		}
	}
}
