/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	readonly property bool isLocalSender: manufacturer.value === 358 && vrmInstanceDC.dataItem.valid

	VeQuickItem {
		id: manufacturer
		uid: root.bindPrefix + "/Manufacturer"
	}

	GradientListView {
		model: DelegateComponentModel {

			DelegateComponent {
				ListText {
					text: CommonWords.model_name
					dataItem.uid: root.bindPrefix + "/ModelName"
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.manufacturer
					dataItem.uid: root.bindPrefix + "/ManufacturerName"
				}
			}

			DelegateComponent {
				ListText {
					//% "Source Address"
					text: qsTrId("settings_rvc_source_address")
					secondaryText: Utils.toHexFormat(dataItem.value)
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
					dataItem.uid: root.bindPrefix + "/RvcUniqueNumber"
				}
			}

			DelegateComponent {
				id: vrmInstanceDC
				dataItem: VeQuickItem { uid: root.bindPrefix + "/VrmInstance" }
				preferredVisible: root.isLocalSender
				ListText {
					id: vrmInstance

					text: CommonWords.vrm_instance
					dataItem.uid: root.bindPrefix + "/VrmInstance"
				}
			}

			DelegateComponent {
				property bool userHasWriteAccess: Global.systemSettings.canAccess(VenusOS.User_AccessType_Installer)
				preferredVisible: root.isLocalSender && userHasWriteAccess
				ListNavigation {
					//% "Configuration"
					text: qsTrId("settings_rvc_configuration")

					onClicked: {
						Global.pageManager.pushPage("/pages/settings/PageSettingsRvcDeviceConfiguration.qml",
							{ bindPrefix: root.bindPrefix, title: text })
					}
				}
			}
		}
	}
}
