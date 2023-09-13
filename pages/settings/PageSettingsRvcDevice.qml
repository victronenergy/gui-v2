/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Utils

Page {
	id: root

	property string bindPrefix

	readonly property bool isLocalSender: manufacturer.value === 358 && vrmInstance.dataValid

	DataPoint {
		id: manufacturer
		source: root.bindPrefix + "/Manufacturer"
	}

	GradientListView {
		model: ObjectModel {

			ListTextItem {
				text: CommonWords.model_name
				dataSource: root.bindPrefix + "/ModelName"
			}

			ListTextItem {
				text: CommonWords.manufacturer
				dataSource: root.bindPrefix + "/ManufacturerName"
			}

			ListTextItem {
				//% "Source Address"
				text: qsTrId("settings_rvc_source_address")
				secondaryText: Utils.toHexFormat(dataValue)
				dataSource: root.bindPrefix + "/Nad"
			}

			ListTextItem {
				text: CommonWords.firmware_version
				dataSource: root.bindPrefix + "/FirmwareVersion"
			}

			ListTextItem {
				text: CommonWords.serial_number
				dataSource: root.bindPrefix + "/Serial"
			}

			ListTextItem {
				text: CommonWords.unique_identity_number
				dataSource: root.bindPrefix + "/RvcUniqueNumber"
			}

			ListTextItem {
				id: vrmInstance

				text: CommonWords.vrm_instance
				dataSource: root.bindPrefix + "/VrmInstance"
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
