/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils
import "../data" as DBusData

Item {
	id: root

	property ListModel model: ListModel {
		Component.onCompleted: {
			append({ generator: generator })
		}
	}

	property QtObject generator: QtObject {
		property int state: DBusData.Generators.GeneratorState.Running
		property bool manualStart
		property int runtime: 35*60
		property int runningBy: DBusData.Generators.GeneratorRunningBy.Soc
	}
}
