/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix // mqtt/vebus/274

	//% "Microgrid"
	title: qsTrId("microgrid")

	objectName: "PageMicrogrid"
	onBindPrefixChanged: console.log(objectName, "bindPrefix:", bindPrefix)


	GradientListView {
		model: VisibleItemModel {
			ListText {
				//% "Active mode"
				text: qsTrId("page_microgrid_active_mode")
				secondaryText: VenusOS.microgridModeToText(mode.value)
			}

			SettingsListHeader {
				//% "Hybrid droop parameters"
				text: qsTrId("page_microgrid_hybrid_droop_parameters")
			}

			ListText {
				dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/P0/Value"
				textFormat: Text.RichText
				//% "Reference active power (P<sub>0</sub>)"
				text: qsTrId("page_microgrid_reference_active_power_p0")
				secondaryText: dataItem.value * 100 + "%"
			}

			ListText {
				dataItem.uid: root.bindPrefix + "/MicroGrid/DroopModeParameters/P0/Value"
				textFormat: Text.RichText
				//% "Reference frequency (f<sub>0</sub>)"
				text: qsTrId("page_microgrid_reference_frequency_f0")
			}
		}

		//loader.status == loader.Ready && mode.valid ? loader.item : null

		VeQuickItem {
			id: mode
			uid: root.bindPrefix + "/Mode"
			onValueChanged: console.log("*********************************************** ", uid, value)
			Component.onCompleted: console.log("*********************************************** ", uid, value)
		}


		/*
		VisibleItemModel {
			id: droopModel

			ListText {
				//% "Active mode"
				text: qsTrId("page_microgrid_active_mode")
				secondaryText: VenusOS.microgridModeToText(mode.value)
			}

			SettingsListHeader {
				//% "Hybrid droop parameters"
				text: qsTrId("page_microgrid_hybrid_droop_parameters")
			}
		}

		VisibleItemModel {
			id: gridFollowingModel

			ListText {
				//% "Active mode"
				text: qsTrId("page_microgrid_active_mode")
				secondaryText: VenusOS.microgridModeToText(mode.value)
			}

			SettingsListHeader {
				//% "V-f direct drive settings"
				text: qsTrId("page_microgrid_v_f_direct_drive_settings")
			}
		}

		VisibleItemModel {
			id: gridFormingModel

			ListText {
				//% "Active mode"
				text: qsTrId("page_microgrid_active_mode")
				secondaryText: VenusOS.microgridModeToText(mode.value)
			}

			SettingsListHeader {
				text: qsTrId("page_microgrid_v_f_direct_drive_settings")
			}
		}
		*/
	}

	/*
	component MicrogridVisibleItemModel : VisibleItemModel {
		ListText {
			//% "Active mode"
			text: qsTrId("page_microgrid_active_mode")
			secondaryText: VenusOS.microgridModeToText(mode.value)
		}
	}

	component VfDirectDriveSettingsSettingsListHeader : SettingsListHeader {
		//% "V-f direct drive settings"
		text: qsTrId("page_microgrid_v_f_direct_drive_settings")
	}

	Component {
		id: droopModel

		VisibleItemModel {
			ListText {
				//% "Active mode"
				text: qsTrId("page_microgrid_active_mode")
				secondaryText: VenusOS.microgridModeToText(mode.value)
			}

			SettingsListHeader {
				//% "Hybrid droop parameters"
				text: qsTrId("page_microgrid_hybrid_droop_parameters")
			}

			ListText {
				//% "Reference power active (%1)"
				text: qsTrId("page_microgrid_reference_power_active_p0").arg("(P<sub>0</sub>)")
			}
		}
	}

	Component {
		id: gridFollowingModel

		VisibleItemModel {

			ListText {
				//% "Active mode"
				text: qsTrId("page_microgrid_active_mode")
				secondaryText: VenusOS.microgridModeToText(mode.value)
			}

			VfDirectDriveSettingsSettingsListHeader {}
		}
	}


	Component {
		id: gridFormingModel
		VisibleItemModel {

			ListText {
				//% "Active mode"
				text: qsTrId("page_microgrid_active_mode")
				secondaryText: VenusOS.microgridModeToText(mode.value)
			}

			VfDirectDriveSettingsSettingsListHeader {}
		}
	}
		Loader {
			id: loader

			sourceComponent: droopModel {
				switch (mode.value)
				{
				case VenusOS.MicrogridMode_HybridDroop:
					return droopModel
				case VenusOS.MicrogridMode_GridFollowing:
					return gridFollowingModel
				case VenusOS.MicroMicrogridMode_GridForming:
					return gridFormingModel
				default:
					return []
				}
			}
		}
	*/
}
