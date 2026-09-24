/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/* Choose the filesystem for the single Storage Manager format transaction. */
ModalDialog {
	id: root

	required property string volumePrefix
	required property string mountPoint
	property string nickname: ""
	// True for "Format first" on unmanaged media. The backend may need to
	// replace its partition table, so this must be described as a whole-drive
	// erase rather than merely formatting the selected filesystem.
	property bool eraseEntireDrive: false
	readonly property string displayName: nickname || mountPoint

	signal filesystemChosen(string filesystem)

	//% "Reformat storage - %1"
	title: qsTrId("formatchoosedialog_title").arg(root.displayName)
	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_NoOptions

	contentItem: ColumnLayout {
		// Shared with the adoption flow; keep enough width for the
		// portability row rather than reverting to the older compact table.
		implicitWidth: Theme.geometry_modalDialog_width + 100
		spacing: Theme.geometry_modalDialog_content_spacing

		Label {
			text: root.eraseEntireDrive
					//% "Choose the new filesystem. All data and partitions on this drive will be permanently erased."
					? qsTrId("formatchoosedialog_description_entire_drive")
					//% "Choose the new filesystem. All data on this storage will be permanently erased."
					: qsTrId("formatchoosedialog_description")
			wrapMode: Text.Wrap
			Layout.fillWidth: true
			Layout.margins: Theme.geometry_modalDialog_content_spacing
		}

		StorageFilesystemCompatibility {
			Layout.fillWidth: true
			Layout.leftMargin: Theme.geometry_modalDialog_content_spacing
			Layout.rightMargin: Theme.geometry_modalDialog_content_spacing
		}

		Item { Layout.preferredHeight: Theme.geometry_modalDialog_content_spacing }
	}

	footer: FocusScope {
		implicitHeight: Theme.geometry_modalDialog_footer_height
		focus: true
		Keys.onEscapePressed: root.reject()
		Keys.enabled: Global.keyNavigationEnabled

		SeparatorBar {
			anchors { left: parent.left; right: parent.right; top: parent.top }
		}

		RowLayout {
			anchors {
				fill: parent
				topMargin: Theme.geometry_modalDialog_content_spacing
				leftMargin: Theme.geometry_modalDialog_content_spacing
				rightMargin: Theme.geometry_modalDialog_content_spacing
				bottomMargin: Theme.geometry_modalDialog_content_spacing
			}
			spacing: Theme.geometry_modalDialog_content_spacing

			Button {
				text: CommonWords.cancel
				Layout.fillWidth: true
				Layout.fillHeight: true
				onClicked: root.reject()
			}
			Button {
				//% "FAT32"
				text: qsTrId("formatchoosedialog_column_fat")
				Layout.fillWidth: true
				Layout.fillHeight: true
				onClicked: {
					root.filesystemChosen("vfat")
					root.accept()
				}
			}
			Button {
				//% "EXT4"
				text: qsTrId("formatchoosedialog_column_ext4")
				Layout.fillWidth: true
				Layout.fillHeight: true
				onClicked: {
					root.filesystemChosen("ext4")
					root.accept()
				}
			}
		}
	}
}
