/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml

QtObject {
	id: root

	property alias minimumCurrent: _valueRange.minimumValue
	property alias maximumCurrent: _valueRange.maximumValue
	readonly property real averagePhaseCurrentAsRatio: _valueRange.valueAsRatio
	property alias phaseModel: _phaseObjects.model

	readonly property ValueRange _valueRange: ValueRange { id: _valueRange }

	// Sum the phase currents and use this as the value within the range. This is not a technically
	// perfect representation of the AC input/load, as voltage may differ per phase, but it's close.
	readonly property Instantiator _phaseObjects: Instantiator {
		id: _phaseObjects

		model: null
		delegate: QtObject {
			required property real current
			required property int index
			onCurrentChanged: Qt.callLater(_update)

			function _update() {
				if (!root || root._phaseObjects.count === 0) {
					return
				}
				let total = 0
				for (let i = 0; i < root._phaseObjects.count; ++i) {
					const c = i === index ? current : root._phaseObjects.objectAt(i).current
					total += (c || 0)
				}
				_valueRange.value = total / root._phaseObjects.count
			}
		}
	}
}
