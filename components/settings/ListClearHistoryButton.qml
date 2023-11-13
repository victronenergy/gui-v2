/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListButton {
	id: root

	property string bindPrefix

	//% "Clear History"
	text: qsTrId("clear_history_button_clear_history")
	secondaryText: enabled
		   ? CommonWords.press_to_clear
			 //% "Clearing"
		   : qsTrId("clear_history_button_clearing")

	DataPoint {
		id: clear
		source: root.bindPrefix + "/History/Clear"
	}

	DataPoint {
		id: canBeCleared
		source: root.bindPrefix + "/History/CanBeCleared"
	}

	DataPoint {
		id: connected
		source: root.bindPrefix + "/Connected"
	}

	Timer {
		id: timer
		interval: 2000
	}
	enabled: !timer.running

	onClicked: {
		/*
		 * Write some value to the item as the clear command does not need
		 * to have a value. Do make sure to only write the value when the
		 * button is pressed and not when released.
		 */
		clear.setValue(1)
		timer.start()
	}

	visible: connected.value === 1 && canBeCleared.value === 1
}
