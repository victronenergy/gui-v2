/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/
import QtQuick
import Victron.VenusOS

ModalDialog {
	id: root

	required property bool chargeFromMainToStarter
	readonly property bool chargingConditionAccepted: understandCheck.checked

	//% "Start emergency charge"
	title: qsTrId("emergencychargestartdialog_start")

	acceptText: CommonWords.start_action
	acceptButtonForegroundColor: Theme.color_dimSuccess_text
	acceptButtonBackground: Rectangle {
		color: canAccept ? Theme.color_dimSuccess : Theme.color_button_on_background_disabled
		bottomRightRadius: Theme.geometry_button_radius
	}
	canAccept: chargingConditionAccepted

	contentItem: ModalDialog.FocusableContentItem {
		implicitHeight: contentLayout.implicitHeight + Theme.geometry_modalDialog_content_spacing
				+ understandCheck.implicitHeight

		Column {
			id: contentLayout

			anchors {
				centerIn: parent
				verticalCenterOffset: -(understandCheck.height + Theme.geometry_modalDialog_content_horizontalMargin_small)/2
			}
			width: parent.width - (2 * Theme.geometry_modalDialog_content_horizontalMargin_small)
			spacing: Theme.geometry_modalDialog_content_spacing

			Label {
				anchors.horizontalCenter: parent.horizontalCenter
				width: parent.width
				wrapMode: Text.Wrap
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: Theme.font_dialog_body_size_large
				text: root.chargeFromMainToStarter
					  //% "The main battery will be used to charge the starter battery. This process takes 15 minutes, followed by a 5-minute waiting period."
					? qsTrId("emergencychargestartdialog_start_explanation_from_main")
					  //% "The starter battery will be used to charge the main battery. This process takes 15 minutes, followed by a 5-minute waiting period."
					: qsTrId("emergencychargestartdialog_start_explanation_from_starter")
			}

			WarningIconLabel {
				anchors.horizontalCenter: parent.horizontalCenter
				width: Math.min(implicitWidth, parent.width)
				text: root.chargeFromMainToStarter
					  //% "Charging starts at 14.4V, max 2A, if main battery conditions permit."
					? qsTrId("emergencychargestartdialog_start_conditions_from_main")
					  //% "Charging starts at 14.4V, max 2A, if starter battery conditions permit."
					: qsTrId("emergencychargestartdialog_start_conditions_from_starter")
				font.pixelSize: Theme.font_dialog_body_secondary_size
			}
		}

		CheckBox {
			id: understandCheck

			anchors {
				bottom: parent.bottom
				left: parent.left
				leftMargin: Theme.geometry_modalDialog_content_horizontalMargin_small
				right: parent.right
				rightMargin: Theme.geometry_modalDialog_content_horizontalMargin_small
			}
			//% "I understand the feature."
			text: qsTrId("emergencychargestartdialog_start_understand_check")
			checkable: true
			focus: true
		}
	}
}
