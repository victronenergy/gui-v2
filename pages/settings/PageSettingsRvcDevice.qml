/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

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

			ListTextItem {
				text: CommonWords.model_name
				dataItem.uid: root.bindPrefix + "/ModelName"
			}

			ListTextItem {
				text: CommonWords.manufacturer
				dataItem.uid: root.bindPrefix + "/ManufacturerName"
			}

			ListTextItem {
				//% "Source Address"
				text: qsTrId("settings_rvc_source_address")
				secondaryText: Utils.toHexFormat(dataItem.value)
				dataItem.uid: root.bindPrefix + "/Nad"
			}

			ListFirmwareVersionItem {
				dataItem.uid: root.bindPrefix + "/FirmwareVersion"
			}

			ListTextItem {
				text: CommonWords.serial_number
				dataItem.uid: root.bindPrefix + "/Serial"
			}

			ListTextItem {
				text: CommonWords.unique_identity_number
				dataItem.uid: root.bindPrefix + "/RvcUniqueNumber"
			}

			ListTextItem {
				id: vrmInstance

				text: CommonWords.vrm_instance
				dataItem.uid: root.bindPrefix + "/VrmInstance"
				visible: root.isLocalSender
			}

			ListNavigationItem {
				//% "Configuration"
				text: qsTrId("settings_rvc_configuration")
				visible: root.isLocalSender && userHasWriteAccess

				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageSettingsRvcDeviceConfiguration.qml",
						{ bindPrefix: root.bindPrefix, title: text })
				}
			}
		}
	}
}
