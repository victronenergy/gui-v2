/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

ModalDialog {
	id: root

	property var generator

	title: CommonWords.generator

	//% "Stop Now"
	acceptText: qsTrId("controlcard_generator_stopdialog_stop_now")

	contentItem: Column {
		anchors {
			top: root.header.bottom
			topMargin: Theme.geometry.modalDialog.content.margins
			left: parent.left
			right: parent.right
			bottom: parent.footer.top
		}
		spacing: Theme.geometry.modalDialog.content.margins

		Column {
			width: parent.width

			Label {
				width: parent.width
				height: implicitHeight + Theme.geometry.modalDialog.content.margins/2
				wrapMode: Text.Wrap
				horizontalAlignment: Text.AlignHCenter

				//% "Total Run Time"
				text: qsTrId("controlcard_generator_stopdialog_total_run_time")
			}

			FixedWidthLabel {
				anchors.horizontalCenter: parent.horizontalCenter
				text: Utils.formatAsHHMMSS(root.generator.runtime)
				font.pixelSize: Theme.font.size.h3
			}

			Label {
				width: parent.width
				wrapMode: Text.Wrap
				color: Theme.color.font.secondary
				horizontalAlignment: Text.AlignHCenter
				visible: root.generator.manualStartTimer > 0

				//: %1 = the total time (in hours, minutes, seconds) that the generator will run for, as set by the user
				//% "Set Time %1"
				text: qsTrId("controlcard_generator_stopdialog_set_time").arg(Utils.secondsToString(root.generator.manualStartTimer))
			}
		}

		Label {
			width: parent.width
			wrapMode: Text.Wrap
			color: Theme.color.font.primary
			horizontalAlignment: Text.AlignHCenter

			//% "Generator will keep running if an autostart condition is met."
			text: qsTrId("controlcard_generator_stopdialog_description")
		}
	}

	acceptButton.background: AcceptButtonBackground {
		id: acceptButtonBackground

		width: root.acceptButton.width
		height: root.acceptButton.height
		color: Theme.color.dimRed

		onSlidingAnimationFinished: {
			root.canAccept = true
			root.accept()
		}
	}

	tryAccept: function() {
		root.canAccept = false
		root.generator.stop()
		acceptButtonBackground.slidingAnimationTo(Theme.color.red)
		return false
	}
}
