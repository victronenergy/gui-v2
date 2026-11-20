/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	//% "Stop emergency charge"
	title: qsTrId("emergency_charge_stop_emergency_charge")
	contentItem: ModalDialog.FocusableContentItem {
		implicitHeight: stopConfirmationLabel.implicitHeight

		Label {
			id: stopConfirmationLabel
			anchors.centerIn: parent
			width: parent.width - (2 * Theme.geometry_modalDialog_content_horizontalMargin)
			horizontalAlignment: Text.AlignHCenter
			wrapMode: Text.Wrap
			font.pixelSize: Theme.font_dialog_body_size_large
			//% "The emergency charge is in progress. Do you want to stop it?"
			text: qsTrId("emergency_charge_stop_are_you_sure")
		}
	}
	acceptButtonBackground: Rectangle {
		color: Theme.color_dimCritical
		bottomRightRadius: Theme.geometry_button_radius
	}
}
