/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	required property bool chargeFromMainToStarter

	//% "Waiting"
	title: qsTrId("emergency_charge_waiting")
	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkOnly
	acceptText: CommonWords.skip_action

	contentItem: ModalDialog.FocusableContentItem {
		implicitHeight: skipContentLayout.implicitHeight

		Column {
			id: skipContentLayout

			anchors.centerIn: parent
			width: parent.width - (2 * Theme.geometry_modalDialog_content_horizontalMargin)
			spacing: Theme.geometry_modalDialog_content_spacing * 2

			Label {
				width: parent.width
				wrapMode: Text.Wrap
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: Theme.font_dialog_body_size_large
				text: root.chargeFromMainToStarter
					  //% "The charger is disabled to reduce load on the starter battery."
					? qsTrId("emergency_charge_skip_explain_from_main")
					  //% "The charger is disabled to reduce load on the main battery."
					: qsTrId("emergency_charge_skip_explain_from_starter")
			}

			WarningIconLabel {
				anchors.horizontalCenter: parent.horizontalCenter
				width: Math.min(implicitWidth, parent.width)
				//% "The vehicle may not start. Skip the countdown and restart the emergency charge if necessary."
				text: qsTrId("emergency_charge_skip_warning")
			}
		}
	}
}
