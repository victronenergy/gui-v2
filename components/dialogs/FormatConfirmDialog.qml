/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	Storage Manager's final "reformat storage?" confirmation - shared by
	the Storage list page and a volume's own detail page. Fully
	self-contained: always fires Admin/FormatAndAdopt (one atomic backend
	call - format, preserve/apply the label, and bring the volume back into
	use; see dbus_service.py's format_and_adopt_volume()). Emits
	formatStarted(triggerName) afterward so a
	caller that wants "Formatting..." progress feedback on its own row
	can watch the right trigger leaf reset to "" - purely optional, the
	format itself already happened by the time this signal fires.
*/
ModalDialog {
	id: root

	required property string volumePrefix
	required property string mountPoint
	required property string filesystem
	// Entered before a new-media format, or the existing adopted name when
	// reformatting storage already in use.
	property string nickname: ""
	property bool eraseEntireDrive: false
	readonly property string displayName: nickname || mountPoint
	property bool formatting: false
	property bool requestSent: false
	property bool triggerAcknowledged: false
	property string failure: ""

	signal formatStarted(string triggerName)
	signal formatFinished()

	function completeFormat() {
		if (!root.formatting) {
			return
		}
		root.formatting = false
		if (operationError.value) {
			root.failure = operationError.value
			return
		}
		root.formatFinished()
		root.accept()
	}

	VeQuickItem {
		id: formatAndAdoptAction
		uid: root.volumePrefix ? (root.volumePrefix + "/Admin/FormatAndAdopt") : ""
		onValueChanged: {
			if (!root.requestSent) {
				return
			}
			if (value !== "") {
				root.triggerAcknowledged = true
			} else if (root.triggerAcknowledged) {
				root.completeFormat()
			}
		}
		onValidChanged: {
			// A successful format creates a new filesystem UUID, so the old
			// /Volumes/<N> trigger disappears instead of resetting in place.
			if (root.requestSent && !valid) {
				root.completeFormat()
			}
		}
	}
	VeQuickItem {
		id: operationError
		uid: root.volumePrefix ? (root.volumePrefix + "/LastOperationError") : ""
	}
	StorageVolumeConsumers { id: consumers; volumePrefix: root.volumePrefix }

	//% "Reformat storage - %1?"
	title: qsTrId("formatconfirmdialog_title").arg(root.displayName)
	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_NoOptions
	Timer {
		id: formatTimer
		interval: 100
		repeat: false
		onTriggered: {
			root.requestSent = true
			formatAndAdoptAction.setValue(JSON.stringify({
				"filesystem": root.filesystem,
				"nickname": root.nickname,
			}))
		}
	}

	contentItem: ColumnLayout {
		implicitWidth: Theme.geometry_modalDialog_width
		spacing: Theme.geometry_modalDialog_content_spacing

		Label {
			//% "Formatting as %1."
			text: qsTrId("formatconfirmdialog_filesystem").arg(
					root.filesystem === "vfat"
							//% "FAT32"
							? qsTrId("formatchoosedialog_column_fat")
							//% "EXT4"
							: qsTrId("formatchoosedialog_column_ext4"))
			wrapMode: Text.Wrap
			Layout.fillWidth: true
			Layout.topMargin: Theme.geometry_modalDialog_content_spacing
			Layout.leftMargin: Theme.geometry_modalDialog_content_spacing
			Layout.rightMargin: Theme.geometry_modalDialog_content_spacing
		}

		Label {
			visible: consumers.consumerNames.length > 0
			//% "Currently used by: %1"
			text: qsTrId("formatconfirmdialog_used_by").arg(consumers.consumerNames.join(", "))
			color: Theme.color_orange
			wrapMode: Text.Wrap
			Layout.fillWidth: true
			Layout.leftMargin: Theme.geometry_modalDialog_content_spacing
			Layout.rightMargin: Theme.geometry_modalDialog_content_spacing
		}

		Label {
			visible: root.formatting
			//% "Formatting storage…"
			text: qsTrId("formatconfirmdialog_formatting")
			color: Theme.color_orange
			wrapMode: Text.Wrap
			Layout.fillWidth: true
			Layout.margins: Theme.geometry_modalDialog_content_spacing
		}

		Label {
			visible: !!root.failure
			//% "Formatting failed: %1"
			text: qsTrId("formatconfirmdialog_failed").arg(root.failure)
			color: Theme.color_red
			wrapMode: Text.Wrap
			Layout.fillWidth: true
			Layout.leftMargin: Theme.geometry_modalDialog_content_spacing
			Layout.rightMargin: Theme.geometry_modalDialog_content_spacing
			Layout.bottomMargin: Theme.geometry_modalDialog_content_spacing
		}

		Label {
			text: root.eraseEntireDrive
					//% "This will erase the entire drive, create a new %1 partition, and manage it as “%2”. This cannot be reversed."
					? qsTrId("formatconfirmdialog_confirm_entire_drive")
						.arg(root.filesystem === "vfat"
								? qsTrId("formatchoosedialog_column_fat")
								: qsTrId("formatchoosedialog_column_ext4"))
						.arg(root.displayName)
					//% "This cannot be reversed. Are you sure?"
					: qsTrId("formatconfirmdialog_confirm")
			visible: !root.formatting
			wrapMode: Text.Wrap
			Layout.fillWidth: true
			Layout.leftMargin: Theme.geometry_modalDialog_content_spacing
			Layout.rightMargin: Theme.geometry_modalDialog_content_spacing
			Layout.bottomMargin: Theme.geometry_modalDialog_content_spacing
		}
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
				text: root.failure ? CommonWords.ok : CommonWords.cancel
				enabled: !root.formatting
				flat: false
				Layout.fillWidth: true
				Layout.fillHeight: true
				onClicked: root.reject()
			}
			Button {
				//% "Reformat"
				text: qsTrId("formatconfirmdialog_button")
				color: Theme.color_red
				flat: false
				Layout.fillWidth: true
				Layout.fillHeight: true
				enabled: !root.formatting
				onClicked: {
					root.failure = ""
					root.formatting = true
					root.formatStarted("Admin/FormatAndAdopt")
					formatTimer.start()
				}
			}
		}
	}
}
