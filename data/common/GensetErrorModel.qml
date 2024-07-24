/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListModel {
	id: root

	property string uidPrefix
	property list<int> errorCodes: [0, 0, 0, 0, 0, 0, 0, 0]

	readonly property VeQuickItem _error0: VeQuickItem {
		uid: uidPrefix + "/Error/0/Id"
		onValueChanged: root._errorChanged(0, value || 0)
	}

	readonly property VeQuickItem _error1: VeQuickItem {
		uid: uidPrefix + "/Error/1/Id"
		onValueChanged: root._errorChanged(1, value || 0)
	}

	readonly property VeQuickItem _error2: VeQuickItem {
		uid: uidPrefix + "/Error/2/Id"
		onValueChanged: root._errorChanged(2, value || 0)
	}

	readonly property VeQuickItem _error3: VeQuickItem {
		uid: uidPrefix + "/Error/3/Id"
		onValueChanged: root._errorChanged(3, value || 0)
	}

	readonly property VeQuickItem _error4: VeQuickItem {
		uid: uidPrefix + "/Error/4/Id"
		onValueChanged: root._errorChanged(4, value || 0)
	}

	readonly property VeQuickItem _error5: VeQuickItem {
		uid: uidPrefix + "/Error/5/Id"
		onValueChanged: root._errorChanged(5, value || 0)
	}

	readonly property VeQuickItem _error6: VeQuickItem {
		uid: uidPrefix + "/Error/6/Id"
		onValueChanged: root._errorChanged(6, value || 0)
	}

	readonly property VeQuickItem _error7: VeQuickItem {
		uid: uidPrefix + "/Error/7/Id"
		onValueChanged: root._errorChanged(7, value || 0)
	}

	function _errorChanged(errorNumber, errorCode) {
		errorCodes[errorNumber] = errorCode
		for (let i = 0; i < count; ++i) {
			const data = get(i)
			if (data.errorNumber === errorNumber) {
				root.setProperty(i, "errorCode", errorCode)
				return
			} else if (data.errorNumber > errorNumber) {
				insert(i, {"errorNumber": errorNumber, "errorCode": errorCode, })
				return
			}
		}
	}
}
