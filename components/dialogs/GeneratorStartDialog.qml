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
	property bool _timedRunSwitchChecked
	property int _timeSelectorHour
	property int _timeSelectorMinute

	signal startSlidingAnimation()

	title: CommonWords.generator

	//% "Start Now"
	acceptText: qsTrId("controlcard_generator_startdialog_start_now")

	contentItem: Column {
		property var timeSelectorWidth

		anchors {
			top: root.header.bottom
			topMargin: Theme.geometry.modalDialog.content.margins
			left: parent.left
			right: parent.right
			bottom: parent.footer.top
		}
		spacing: Theme.geometry.modalDialog.content.margins

		Switch {
			width: parent.timeSelectorWidth
			//% "Timed run"
			text: qsTrId("controlcard_generator_startdialog_timed_run")
			checked: root.generator.manualStartTimer > 0
			Component.onCompleted: root._timedRunSwitchChecked = Qt.binding(function() { return this.checked})
		}

		TimeSelector {
			anchors.horizontalCenter: parent.horizontalCenter
			enabled: root._timedRunSwitchChecked
			maximumHour: 59
			hour: _timeSelectorHour
			minute: _timeSelectorMinute
			Component.onCompleted: parent.timeSelectorWidth = Qt.binding(function() { return this.width})

			Connections {
				target: root

				function onAboutToShow() {
					const timeParts = Utils.decomposeDuration(root.generator.manualStartTimer)
					_timeSelectorHour = timeParts.h
					_timeSelectorMinute = timeParts.m
				}
			}
		}

		Label {
			width: parent.timeSelectorWidth
			wrapMode: Text.Wrap
			color: Theme.color.font.primary
			horizontalAlignment: Text.AlignHCenter

			//% "Generator will stop after the set time, unless autostart condition is met, in which case it will keep running."
			text: qsTrId("controlcard_generator_startdialog_description")
		}
	}

	acceptButton.background: AcceptButtonBackground {
		width: root.acceptButton.width
		height: root.acceptButton.height
		color: Theme.color.dimGreen

		onSlidingAnimationFinished: {
			root.canAccept = true
			root.accept()
		}

		Connections {
			target: root

			function onStartSlidingAnimation() {
				slidingAnimationTo(Theme.color.green)
			}
		}
	}

	tryAccept: function() {
		root.canAccept = false
		root.generator.start(root._timedRunSwitchChecked ? Utils.composeDuration(_timeSelectorHour, _timeSelectorMinute) : 0)
		root.startSlidingAnimation()
		return false
	}
}
