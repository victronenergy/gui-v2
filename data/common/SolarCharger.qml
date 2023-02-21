/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

QtObject {
	id: solarCharger

	property string serviceUid

	// Track when all Instantiator objects have been created, otherwise when SolarChargers.qml
	// calls yieldHistories.objectAt(), the function returns null.
	readonly property bool yieldHistoriesReady: yieldHistories.completedObjectCount > 0
			&& yieldHistories.completedObjectCount === yieldHistories.count

	onYieldHistoriesReadyChanged: {
		if (yieldHistoriesReady) {
			Qt.callLater(Global.solarChargers.initializeYieldHistory)
		}
	}

	// Yield for each previous day, in kwh
	readonly property Instantiator yieldHistories: Instantiator {
		property int completedObjectCount

		model: undefined    // ensure delegates are not created before history model is set
		delegate: VeQuickItem {
			readonly property real yieldKwH: value || 0
			// uid is e.g. com.victronenergy.solarcharger.tty0/History/Daily/<day>/Yield
			uid: solarCharger.serviceUid + "/History/Daily/" + model.index + "/Yield"

			onValueChanged: {
				if (yieldHistoriesReady && value !== undefined) {
					Global.solarChargers.refreshYieldHistoryForDay(model.index)
				}
			}
			Component.onCompleted: {
				yieldHistories.completedObjectCount++
			}
		}
	}

	readonly property VeQuickItem _veHistoryCount: VeQuickItem {
		uid: solarCharger.serviceUid + "/History/Overall/DaysAvailable"
		onValueChanged: {
			if (value !== undefined) {
				yieldHistories.model = value
			}
		}
	}
}
