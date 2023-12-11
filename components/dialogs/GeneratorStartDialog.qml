/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

ModalDialog {
	id: root

	property var generator

	title: CommonWords.generator

	//% "Start Now"
	acceptText: qsTrId("controlcard_generator_startdialog_start_now")

	contentItem: Column {
		anchors {
			top: root.header.bottom
			topMargin: Theme.geometry_modalDialog_content_margins
			left: parent.left
			right: parent.right
			bottom: parent.footer.top
		}
		spacing: Theme.geometry_modalDialog_content_margins

		Switch {
			id: timedRunSwitch

			anchors {
				left: timeSelector.left
				right: timeSelector.right
			}
			//% "Timed run"
			text: qsTrId("controlcard_generator_startdialog_timed_run")
			checked: root.generator.manualStartTimer > 0
		}

		TimeSelector {
			id: timeSelector

			anchors.horizontalCenter: parent.horizontalCenter
			enabled: timedRunSwitch.checked
			maximumHour: 59
		}

		Label {
			anchors {
				left: timeSelector.left
				right: timeSelector.right
			}
			wrapMode: Text.Wrap
			color: Theme.color_font_primary
			horizontalAlignment: Text.AlignHCenter
			visible: root.generator.autoStart

			//% "Generator will stop after the set time, unless autostart condition is met, in which case it will keep running."
			text: qsTrId("controlcard_generator_startdialog_description")
		}
	}

	acceptButton.background: AcceptButtonBackground {
		id: acceptButtonBackground

		width: root.acceptButton.width
		height: root.acceptButton.height
		color: Theme.color_dimGreen

		onSlidingAnimationFinished: {
			root.canAccept = true
			root.accept()
		}
	}

	tryAccept: function() {
		root.canAccept = false
		root.generator.start(timedRunSwitch.checked ? Utils.composeDuration(timeSelector.hour, timeSelector.minute) : 0)
		acceptButtonBackground.slidingAnimationTo(Theme.color_green)
		return false
	}

	onAboutToShow: {
		const timeParts = Utils.decomposeDuration(root.generator.manualStartTimer)
		timeSelector.hour = timeParts.h
		timeSelector.minute = timeParts.m
	}
}
