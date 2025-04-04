/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

GeneratorDialog {
	id: root

	//% "Stop Now"
	acceptText: qsTrId("controlcard_generator_stopdialog_stop_now")
	secondaryTitle: CommonWords.manual_stop

	onGeneratorStateChanged: {
		if (root.open) {
			if (generatorState == VenusOS.Generators_State_Stopped
					|| generatorState == VenusOS.Generators_State_Stopping
					|| generatorState == VenusOS.Generators_State_CoolDown) {
				root.accept()
			}
		}
	}

	// Invoked when manually starting generator while it was already running due to a condition.
	onGeneratorRunningByChanged: {
		if (root.open) {
			if (generatorRunningBy != VenusOS.Generators_RunningBy_Manual) {
				root.accept()
			}
		}
	}

	runGeneratorAction: function() {
		root.generator.stop()
	}

	contentItem: ModalDialog.FocusableContentItem {
		anchors {
			top: root.header.bottom
			topMargin: Theme.geometry_modalDialog_content_margins
			left: parent.left
			right: parent.right
			bottom: parent.footer.top
		}
		height: contentColumn.height

		Column {
			id: contentColumn
			width: parent.width

			Label {
				height: implicitHeight + Theme.geometry_modalDialog_content_margins/2
				wrapMode: Text.Wrap
				horizontalAlignment: Text.AlignHCenter
				x: Theme.geometry_page_content_horizontalMargin
				elide: Text.ElideRight
				width: parent.width - 2*x

				//% "Total Run Time"
				text: qsTrId("controlcard_generator_stopdialog_total_run_time")
			}

			FixedWidthLabel {
				anchors.horizontalCenter: parent.horizontalCenter
				text: Utils.formatGeneratorRuntime(root.generator.runtime)
				font.pixelSize: Theme.font_size_h3
			}

			Label {
				elide: Text.ElideRight
				width: parent.width - 2*x
				wrapMode: Text.Wrap
				color: Theme.color_font_secondary
				horizontalAlignment: Text.AlignHCenter
				visible: root.generator.manualStartTimer > 0

				//: %1 = the total time (in hours, minutes, seconds) that the generator will run for, as set by the user
				//% "Set Time %1"
				text: qsTrId("controlcard_generator_stopdialog_set_time").arg(Utils.secondsToString(root.generator.manualStartTimer))
			}
		}

		Label {
			anchors.top: contentColumn.bottom
			width: parent.width
			topPadding: Theme.geometry_modalDialog_content_margins
			wrapMode: Text.Wrap
			color: Theme.color_font_primary
			horizontalAlignment: Text.AlignHCenter
			visible: root.generator.autoStart
			elide: Text.ElideRight
			maximumLineCount: 2

			//% "Generator will keep running if an autostart condition is met."
			text: qsTrId("controlcard_generator_stopdialog_description")
		}
	}
}
