/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	// Declare ObjectModelMonitor before the model that it is monitoring. See QTBUG-123496
	ObjectModelMonitor {
		id: configurationModelMonitor
		model: configurationModel
	}

	RvcDeviceConfigurationModel {
		id: configurationModel
		bindPrefix: root.bindPrefix
	}

	GradientListView {
		model: VisibleItemModel {

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
				preferredVisible: dataItem.valid
			}

			ListNavigation {
				//% "Configuration"
				text: qsTrId("settings_rvc_configuration")
				preferredVisible: configurationModelMonitor.hasVisibleItem && userHasWriteAccess

				onClicked: {
					Global.pageManager.pushPage(emptySettingsComponent,
						{ "title": text, "model": configurationModel })
				}
			}
		}
	}

	Component {
		id: emptySettingsComponent

		Page {
			property alias model: settingsListView.model

			GradientListView {
				id: settingsListView
			}
		}
	}
}
