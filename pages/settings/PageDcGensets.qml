/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string generator1ServiceUid: Global.generators.generator1ServiceUid
	property string settingsBindPrefix: Global.systemSettings.serviceUid + "/Settings/Generator1"
	readonly property bool enableControls: gensetError.dataItem.valid && gensetError.dataItem.value !== VenusOS.Genset_ErrorCode_EmptyCustomEnabledGensetsGroup

	function generator1ServiceUid_append(suffix) {
		return generator1ServiceUid ? generator1ServiceUid + suffix : ""
	}

	title: CommonWords.dcGensets

	GradientListView {
		model: VisibleItemModel {
			ListGeneratorAutoStartSwitch {
				interactive: defaultInteractive && root.enableControls
				dataItem.uid: root.generator1ServiceUid_append("/AutoStartEnabled")
				caption: root.enableControls
						 ? ""
						   //% "This control is disabled while the custom enabled gensets group is empty"
						 : qsTrId("page_dc_gensets_this_control_is_disabled_while_the_custom_enabled_gensets_group_is_empty")
			}

			ListGeneratorManualControlButton {
				interactive: root.enableControls
				generatorUid: root.generator1ServiceUid
			}

			ListGeneratorControlStatus {
				startStopBindPrefix: root.generator1ServiceUid
			}

			ListGeneratorError {
				id: gensetError

				//% "Control error code"
				text: qsTrId("ac-in-genset_control_error_code")
				dataItem.uid: root.generator1ServiceUid_append("/Error")
			}

			ListVoltageCurrentPower {
				//% "Output"
				text: qsTrId("page-dc-gensets-output")
				bindPrefix: root.generator1ServiceUid_append("/MultipleGensets")
				voltageUnit: VenusOS.Units_Volt_DC
			}

			ListNavigation {
				text: CommonWords.settings
				interactive: root.generator1ServiceUid && root.settingsBindPrefix
				onClicked: Global.pageManager.pushPage("/pages/settings/PageDcGensetsSettings.qml",
													   {
														   "title": text,
														   "startStopBindPrefix": root.generator1ServiceUid,
														   "settingsBindPrefix": root.settingsBindPrefix
													   })
			}

			ListNavigation {
				//% "Gensets"
				text: qsTrId("page-dc-gensets-gensets")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageGensets.qml", { "title": text })
			}
		}
	}
}
