/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	//% "Start emergency charge"
	title: qsTrId("emergencychargestartdialog_start")

	acceptText: CommonWords.start_action
	acceptButtonBackground: Rectangle {
		color: canAccept ? Theme.color_dimSuccess : Theme.color_button_on_background_disabled
		bottomRightRadius: Theme.geometry_button_radius
	}
	canAccept: understandCheck.checked

	contentItem: ModalDialog.FocusableContentItem {
		implicitHeight: contentLayout.implicitHeight

		Column {
			id: contentLayout

			anchors.centerIn: parent
			width: parent.width - (2 * Theme.geometry_modalDialog_content_horizontalMargin_small)
			spacing: Theme.geometry_modalDialog_content_spacing_large

			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width
				wrapMode: Text.Wrap
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: Theme.font_dialog_body_size_large
				//% "The auxiliary battery will be used to charge the starter battery. This process takes 15 minutes, followed by a 5-minute waiting period."
				text: qsTrId("emergencychargestartdialog_start_explanation")
			}

			WarningIconLabel {
				anchors.horizontalCenter: parent.horizontalCenter
				width: Math.min(implicitWidth, parent.width)
				//% "Charging starts at 14.4V, max 2A, if auxiliary battery conditions permit."
				text: qsTrId("emergencychargestartdialog_start_conditions")
				font.pixelSize: Theme.font_dialog_body_secondary_size
			}

			CheckBox {
				id: understandCheck

				width: parent.width
				//% "I understand the feature."
				text: qsTrId("emergencychargestartdialog_start_understand_check")
				checkable: true
				focus: true
			}
		}
	}
}
