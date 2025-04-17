/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS


// This dialog allows the generator to be started or stopped. It is does not close immediately
// when the 'accept' button is clicked to start/stop the generator. Instead, it shows a color
// animation over a short duration, and while the animation is running, the user can elect to cancel
// the start/stop action.
//
// When the dialog is opened, the 'accept' button shows either 'Start' or 'Stop' to start/stop the
// generator, and the 'reject' button shows 'Close'. When the Start/Stop button is clicked:
//  - A color animation slides slowly over the button background
//  - The 'reject' button text changes from 'Close' to 'Cancel'. If the button is clicked at
//    this point, the color animation stops, the dialog does NOT close, and the reject button
//    text changes again to 'Close'.
//  - If the Cancel button is not clicked, when the color animation reaches the end of the
//    button, the start/stop action is triggered. When the action completes, the dialog is closed.
//
// If the reject button is clicked when its text is 'Close' (i.e. before the Start/Stop button
// is clicked, or if the reject button was clicked to cancel the start/stop action), the dialog
// is closed without starting or stopping the generator.
ModalDialog {
	id: root

	required property string generatorUid

	readonly property Generator generator: Generator { serviceUid: root.generatorUid }
	readonly property int generatorState: generator ? generator.state : VenusOS.Generators_State_Stopped
	readonly property int generatorRunningBy: generator ? generator.runningBy : VenusOS.Generators_RunningBy_NotRunning
	property var runGeneratorAction

	title: CommonWords.generator

	acceptButton.background: AcceptButtonBackground {
		id: acceptButtonBackground

		width: root.acceptButton.width
		height: root.acceptButton.height
		color: root.finalGeneratorState === VenusOS.Generators_State_Stopped ? Theme.color_dimRed : Theme.color_dimGreen
		secondaryColor: root.finalGeneratorState === VenusOS.Generators_State_Stopped ? Theme.color_red : Theme.color_green

		states: [
			// The state where Start/Stop has not been clicked, or it was clicked and then the
			// user clicked 'Cancel'.
			State {
				name: "default"
				PropertyChanges {
					target: root
					tryReject: function() {
						// Dialog can be closed as user has not clicked 'accept'.
						return true
					}
					tryAccept: function() {
						// Instead of accepting and closing the dialog, start the color animation
						// and see if user wants to cancel the start/stop action.
						acceptButtonBackground.state = "acceptAnimationRunning"
						return false
					}
				}
				PropertyChanges {
					target: acceptButtonBackground
					animating: false
				}
			},

			// The state where Start/Stop has been clicked and the button color animation is
			// running.
			State {
				name: "acceptAnimationRunning"
				PropertyChanges {
					target: acceptButtonBackground
					animating: true
					onAnimationFinished: {
						// When the animation finishes, execute the start/stop action
						acceptButtonBackground.state = "actionRunning"
					}
				}
				PropertyChanges {
					target: root
					canAccept: false
					tryReject: function() {
						// If user clicks reject button, restore the default dialog state, instead
						// of closing the dialog.
						acceptButtonBackground.animating = false
						acceptButtonBackground.state = "default"
						root.rejectButton.focus = true // accept button is now disabled, so focus a different button.
						return false
					}
				}
			},

			// The state where the button color animation has completed, and the start/stop action
			// should now be triggered. When the action completes soon after, the dialog is closed.
			State {
				// In this state
				name: "actionRunning"
				StateChangeScript {
					script: {
						root.runGeneratorAction()
					}
				}
				// Do not allow the 'accept' button to be clicked again in this state, but allow
				// the 'reject' button to be clicked to close the dialog, in case the action
				// doesn't complete as expected. (In practice, starting/stopping the generator
				// should be almost immediate.)
				PropertyChanges {
					target: root
					canAccept: false
					tryReject: function() {
						return true
					}
				}
			}
		]
	}

	onAboutToShow: {
		acceptButtonBackground.state = "default"
	}
}
