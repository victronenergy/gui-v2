/*
** Copyright (C) 2022 Victron Energy B.V.
*
* Utility class to manipulate data points that consist of a comma separated list of individual values
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS
import "/components/Utils.js" as Utils

DataPoint {
	id: root

	readonly property var valuesAsArray: value ? value.split(',') : []

	property C.ButtonGroup group: C.ButtonGroup { }

	function push(element) {
		var _values = valuesAsArray
		_values.push(element)
		setValue(_values.join(','))
	}

	function deleteCheckedButtons() {
		var _values = valuesAsArray
		for (var i = group.buttons.length - 1; i >= 0; --i) {
			if(group.buttons[i].checked) {
				_values.splice(i, 1)
			}
		}
		var newValue = _values.join(',')
		root.setValue(newValue)
	}
}
