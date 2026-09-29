/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml

QtObject {
	id: root

	property alias minimumCurrent: _valueRange.minimumValue
	property alias maximumCurrent: _valueRange.maximumValue
	readonly property real averagePhaseCurrent: _valueRange.value
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
					if (i === index) {
						total += (current || 0)
						continue
					}
					const obj = root._phaseObjects.objectAt(i)
					if (!obj) {
						// Async incubation can run this callLater before every
						// Instantiator delegate exists.
						return
					}
					total += (obj.current || 0)
				}
				_valueRange.value = total / root._phaseObjects.count
			}
		}
	}
}
