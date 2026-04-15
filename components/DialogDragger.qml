/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

/*
	Allows a dialog to be vertically dragged off screen.

	By default, this is only enabled in portrait.
*/
MouseArea {
	id: root

	required property T.Dialog dialog
	required property DialogShadow shadow

	property real _dialogYOnPress
	property real _mouseYOnPress
	property real _shadowHeightOnPress
	property real _dialogHeightOnPress

	enabled: Theme.screenSize === Theme.Portrait

	states: State {
		name: "dragging"
		PropertyChanges {
			target: root.dialog
			height: root._dialogHeightOnPress
		}
		PropertyChanges {
			target: root.shadow
			height: root._shadowHeightOnPress * 2
		}
	}

	// Use the 'pressed' state to handle the dialog dragging. Note that MouseArea::drag cannot be
	// used to drag the dialogs, because the base type of Dialog is QtObject, not Item.
	onPressedChanged: {
		if (pressed) {
			// A drag has been initiated. Record the necessary parameters.
			_dialogYOnPress = root.dialog.y
			_mouseYOnPress = mouseY
			_dialogHeightOnPress = root.dialog.height
			_shadowHeightOnPress = root.shadow.height
			state = "dragging"
		} else {
			// The drag has been released. If the dialog has been dragged down more than 1/4 of the
			// screen, and it can be auto-closed, then animate it off the screen and close it.
			// Otherwise, move it back to its original position.
			if (root.dialog.y - _dialogYOnPress > Global.main.height / 4
					&& (!root.dialog.tryReject || root.dialog.tryReject())) {
				pushOffscreenAnim.start()
			} else {
				restoreYAnim.start()
			}
		}
	}

	onPositionChanged: {
		root.dialog.y += (mouseY - _mouseYOnPress)
	}

	// Move the dialog to its initial y position.
	NumberAnimation {
		id: restoreYAnim

		target: root.dialog
		duration: 150
		property: "y"
		to: _dialogYOnPress
		easing.type: Easing.InQuad
	}

	// Slide the dialog off screen, then close it.
	SequentialAnimation {
		id: pushOffscreenAnim

		NumberAnimation {
			target: root.dialog
			property: "y"
			duration: 150
			to: Global.main.height
			easing.type: Easing.InQuad
		}
		ScriptAction {
			script: root.dialog.close()
		}
	}

	Rectangle {
		anchors {
			top: parent.top
			topMargin: Theme.geometry_modalDialog_grabber_topMargin
			horizontalCenter: parent.horizontalCenter
		}
		visible: root.enabled
		width: Theme.geometry_modalDialog_grabber_width
		height: Theme.geometry_modalDialog_grabber_height
		radius: Theme.geometry_modalDialog_grabber_height
		color: Theme.color_modalDialog_grabber_background
	}
}
