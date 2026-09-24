/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

/*
 * The single filesystem-capability table used anywhere storage can be
 * adopted or reformatted. Keep consumer support and portability guidance
 * here so the two entry points cannot drift into different revisions.
 */
ColumnLayout {
	id: root

	//% "VRM online logging"
	readonly property string vrmConsumerName: qsTrId("pagesettingsstorage_consumer_vrm")
	readonly property var storageConsumers: [
		{ serviceType: "logger", name: root.vrmConsumerName },
	]

	Layout.fillWidth: true
	spacing: Theme.geometry_modalDialog_content_spacing

	RowLayout {
		Layout.fillWidth: true
		spacing: Theme.geometry_modalDialog_content_spacing

		Item { Layout.fillWidth: true }
		//% "EXT4"
		Label {
			text: qsTrId("formatchoosedialog_column_ext4")
			Layout.preferredWidth: Theme.geometry_modalDialog_content_spacing * 4
			horizontalAlignment: Text.AlignHCenter
		}
		//% "FAT32"
		Label {
			text: qsTrId("formatchoosedialog_column_fat")
			Layout.preferredWidth: Theme.geometry_modalDialog_content_spacing * 4
			horizontalAlignment: Text.AlignHCenter
		}
	}

	Repeater {
		model: root.storageConsumers

		delegate: RowLayout {
			id: consumerRow
			required property var modelData
			readonly property string serviceUid: BackendConnection.serviceUidForType(modelData.serviceType)

			Layout.fillWidth: true
			spacing: Theme.geometry_modalDialog_content_spacing

			VeQuickItem {
				id: supportedFilesystems
				uid: consumerRow.serviceUid ? (consumerRow.serviceUid + "/Storage/SupportedFilesystems") : ""
			}

			function supports(filesystem) {
				if (!supportedFilesystems.valid) {
					return false
				}
				try {
					return JSON.parse(supportedFilesystems.value || "[]").indexOf(filesystem) !== -1
				} catch (error) {
					return false
				}
			}

			Label {
				text: consumerRow.modelData.name
				Layout.fillWidth: true
				wrapMode: Text.Wrap
			}
			CP.ColorImage {
				Layout.preferredWidth: Theme.geometry_modalDialog_content_spacing * 4
				Layout.preferredHeight: Theme.geometry_modalDialog_content_spacing * 3
				Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
				width: Theme.geometry_modalDialog_content_spacing * 3
				height: Theme.geometry_modalDialog_content_spacing * 2.25
				fillMode: Image.PreserveAspectFit
				source: "qrc:/images/icon_checkmark_32.svg"
				color: Theme.color_green
				// Preserve the cell even when unsupported so columns never shift.
				opacity: consumerRow.supports("ext4") ? 1 : 0
			}
			CP.ColorImage {
				Layout.preferredWidth: Theme.geometry_modalDialog_content_spacing * 4
				Layout.preferredHeight: Theme.geometry_modalDialog_content_spacing * 3
				Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
				width: Theme.geometry_modalDialog_content_spacing * 3
				height: Theme.geometry_modalDialog_content_spacing * 2.25
				fillMode: Image.PreserveAspectFit
				source: "qrc:/images/icon_checkmark_32.svg"
				color: Theme.color_green
				opacity: consumerRow.supports("vfat") ? 1 : 0
			}
		}
	}

	RowLayout {
		Layout.fillWidth: true
		spacing: Theme.geometry_modalDialog_content_spacing

		Label {
			//% "Works on other systems (Windows, Mac, Linux)"
			text: qsTrId("pagesettingsstorage_reformat_portable_row")
			Layout.fillWidth: true
			wrapMode: Text.Wrap
		}
		Item {
			Layout.preferredWidth: Theme.geometry_modalDialog_content_spacing * 4
			Layout.preferredHeight: Theme.geometry_modalDialog_content_spacing * 3
		}
		CP.ColorImage {
			Layout.preferredWidth: Theme.geometry_modalDialog_content_spacing * 4
			Layout.preferredHeight: Theme.geometry_modalDialog_content_spacing * 3
			Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
			width: Theme.geometry_modalDialog_content_spacing * 3
			height: Theme.geometry_modalDialog_content_spacing * 2.25
			fillMode: Image.PreserveAspectFit
			source: "qrc:/images/icon_checkmark_32.svg"
			color: Theme.color_green
		}
	}
}
