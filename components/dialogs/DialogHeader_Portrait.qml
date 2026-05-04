/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	Header for a dialog in portrait layout.

	In portrait layout, show a round "X" button that is positioned similarly to the close button
	in popups on mobile devices:

	- When there are no OK/Set buttons and the only possible action is to close the dialog, show
	  the "X" on the top-right.
	- When the dialog has the OK/Set button, show the "X" on the left-hand side instead, so that
	  closing the dialog no longer appears to be the default action.

	For label alignments: if a label fits within the space available, then horizontally align it,
	otherwise left-align it.
*/
Item {
	id: root

	required property int dialogDoneOptions
	property string title
	property int titleTextFormat: Text.AutoText
	property string secondaryTitle

	readonly property int _closeButtonAlignment: !_showCloseButton ? 0
			: dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_CancelOnly ? Qt.AlignRight
			: Qt.AlignLeft
	readonly property real _labelOffset: _closeButtonAlignment === 0 ? 0
			: _closeButtonAlignment === Qt.AlignRight ? (roundCloseButton.width + Theme.geometry_modalDialog_content_spacing)/2
			: -(roundCloseButton.width + Theme.geometry_modalDialog_content_spacing)/2
	readonly property bool _showCloseButton: root.dialogDoneOptions !== VenusOS.ModalDialog_DoneOptions_OkOnly

	signal closeButtonClicked

	implicitWidth: Theme.geometry_modalDialog_width
	implicitHeight: Math.max(Theme.geometry_modalDialog_header_height,
			roundCloseButton.visible ? roundCloseButton.height + (2 * roundCloseButton.y) : 0)

	RoundCloseButton {
		id: roundCloseButton
		x: root._closeButtonAlignment === Qt.AlignLeft ? Theme.geometry_page_content_horizontalMargin
				: root._closeButtonAlignment === Qt.AlignRight ? parent.width - width - Theme.geometry_page_content_horizontalMargin
				: 0
		y: Theme.geometry_page_content_horizontalMargin
		visible: root._showCloseButton
		onClicked: root.closeButtonClicked()
	}

	ColumnLayout {
		anchors {
			verticalCenter: root._showCloseButton ? roundCloseButton.verticalCenter: parent.verticalCenter
			left: root._closeButtonAlignment === Qt.AlignLeft ? roundCloseButton.right : parent.left
			leftMargin: root._closeButtonAlignment === Qt.AlignLeft ? Theme.geometry_modalDialog_content_spacing : Theme.geometry_page_content_horizontalMargin
			right: root._closeButtonAlignment === Qt.AlignRight ? roundCloseButton.left : parent.right
			rightMargin: root._closeButtonAlignment === Qt.AlignRight ? Theme.geometry_modalDialog_content_spacing : Theme.geometry_page_content_horizontalMargin
		}
		spacing: Theme.geometry_modalDialog_header_spacing

		Item {
			Layout.preferredHeight: secondaryLabel.implicitHeight
			Layout.fillWidth: true
			visible: secondaryLabel.text.length > 0

			Label {
				id: secondaryLabel

				x: implicitWidth > width ? 0 : root._labelOffset
				width: parent.width
				horizontalAlignment: root._showCloseButton && implicitWidth > width ? Text.AlignLeft : Text.AlignHCenter
				font.pixelSize: Theme.font_dialog_secondaryTitle_size
				text: root.secondaryTitle
				textFormat: root.titleTextFormat
				elide: Text.ElideRight
			}
		}

		Item {
			Layout.preferredHeight: primaryLabel.implicitHeight
			Layout.fillWidth: true

			Label {
				id: primaryLabel

				x: implicitWidth > width ? 0 : root._labelOffset
				width: parent.width
				horizontalAlignment: root._showCloseButton && implicitWidth > width ? Text.AlignLeft : Text.AlignHCenter
				font.pixelSize: root.secondaryTitle.length ? Theme.font_dialog_header_smallSize : Theme.font_dialog_header_largeSize
				text: root.title
				textFormat: root.titleTextFormat
				elide: Text.ElideRight
			}
		}
	}
}
