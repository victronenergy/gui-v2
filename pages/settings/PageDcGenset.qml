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
		model: VisibleItemModel {
			ListText {
				//% "Genset status"
				text: qsTrId("page-dc-genset-genset_status")
				secondaryText: Global.acInputs.gensetStatusCodeToText(gensetStatus.value)

				VeQuickItem {
					id: gensetStatus
					uid: root.bindPrefix + "/StatusCode"
				}
			}

			ListGeneratorError {
				dataItem.uid: root.bindPrefix + "/ErrorCode"
			}

			ListText {
				//% "Remote start mode"
				text: qsTrId("page-dc-genset-remote_start_mode")
				dataItem.uid: root.bindPrefix + "/RemoteStartModeEnabled"
				secondaryText: CommonWords.enabledOrDisabled(dataItem.value)
			}

			ListDcOutputQuantityGroup {
				bindPrefix: root.bindPrefix
			}

			ListNavigation {
				text: CommonWords.engine
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageEngine.qml",
												{
													title: text,
													bindPrefix: root.bindPrefix
												})
				}
			}

			ListNavigation {
				readonly property bool isFirstDcGenset: root.bindPrefix === Global.generators.dcModel.firstObject?.serviceUid

				text: CommonWords.device_info_title
				preferredVisible: isFirstDcGenset // only show a Device Page for the first DC generator
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml", {
						serviceUid: root.bindPrefix
					})
				}
			}
		}
	}
}
