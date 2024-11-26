/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListModel {
	id: root

	property string uidPrefix

	readonly property VeQuickItem _lastError1: VeQuickItem {
		uid: uidPrefix + "/LastError1"
		onValueChanged: root._errorChanged(1, value || 0)
	}

	readonly property VeQuickItem _lastError2: VeQuickItem {
		uid: uidPrefix + "/LastError2"
		onValueChanged: root._errorChanged(2, value || 0)
	}

	readonly property VeQuickItem _lastError3: VeQuickItem {
		uid: uidPrefix + "/LastError3"
		onValueChanged: root._errorChanged(3, value || 0)
	}

	readonly property VeQuickItem _lastError4: VeQuickItem {
		uid: uidPrefix + "/LastError4"
		onValueChanged: root._errorChanged(4, value || 0)
	}

	function _errorChanged(errorNumber, errorCode) {
		if (errorCode === 0) {
			_removeError(errorNumber);
		} else {
			_addError(errorNumber, errorCode);
		}
	}

	function _addError(errorNumber, errorCode) {
		// Add in sorted order, by errorNumber (lowest first)
		let insertionIndex = count;
		for (let i = 0; i < count; ++i) {
			const data = get(i);
			if (data.errorNumber > errorNumber) {
				insertionIndex = i;
				break;
			}
		}
		insert(insertionIndex, {
				"errorNumber": errorNumber,
				"errorCode": errorCode
			});
	}

	function _removeError(errorNumber) {
		for (let i = 0; i < count; ++i) {
			const data = get(i);
			if (data.errorNumber === errorNumber) {
				remove(i);
				break;
			}
		}
	}
}
