/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	readonly property bool isLocalSender: manufacturer.value === 358 && vrmInstance.dataItem.isValid

	VeQuickItem {
		id: manufacturer
		uid: root.bindPrefix + "/Manufacturer"
	}

	GradientListView {
		model: ObjectModel {

			ListText {
				text: CommonWords.model_name
				dataItem.uid: root.bindPrefix + "/ModelName"
			}

			ListText {
				text: CommonWords.manufacturer
				dataItem.uid: root.bindPrefix + "/ManufacturerName"
			}

			ListText {
				//% "Source Address"
				text: qsTrId("settings_rvc_source_address")
				secondaryText: Utils.toHexFormat(dataItem.value)
				dataItem.uid: root.bindPrefix + "/Nad"
			}

			ListFirmwareVersion {
				bindPrefix: root.bindPrefix
			}

			ListText {
				text: CommonWords.serial_number
				dataItem.uid: root.bindPrefix + "/Serial"
			}

			ListText {
				text: CommonWords.unique_identity_number
				dataItem.uid: root.bindPrefix + "/RvcUniqueNumber"
			}

			ListText {
				id: vrmInstance

				text: CommonWords.vrm_instance
				dataItem.uid: root.bindPrefix + "/VrmInstance"
				preferredVisible: root.isLocalSender
			}

			ListNavigation {
				//% "Configuration"
				text: qsTrId("settings_rvc_configuration")
				preferredVisible: root.isLocalSender && userHasWriteAccess

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsRvcDeviceConfiguration.qml",
						{ bindPrefix: root.bindPrefix, title: text })
				}
			}
		}
	}
}
