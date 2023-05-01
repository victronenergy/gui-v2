/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQml
import Victron.Veutil

QtObject {
	id: root

	readonly property string serviceUid: "MockDevice-" + name
	property var deviceInstance: QtObject {
		property int value
	}

	property string name
}
