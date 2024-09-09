/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListModel {
	id: root

	property string uidPrefix
	property list<string> errorCodes: ["", "", "", "", "", "", "", ""]

	property Instantiator instantiator: Instantiator {
		model: 8
		delegate: VeQuickItem {
			uid: uidPrefix + "/Error/" + index + "/Id"
			onValueChanged: { // eg. "dse:w-4097"
				root._errorChanged(index, value)
			}
		}
	}

	function _errorChanged(errorNumber, errorCode) {
		errorCodes[errorNumber] = errorCode // 'errorCode' is eg. "dse:w-4097"

		if (root.count === 0) { // initialize ListModel
			for (var i = 0; i < instantiator.count; ++i) {
				root.append({"errorNumber": i, "errorCode": ""})
			}
		}

		for (let i = 0; i < root.count; ++i) {
			const data = get(i)
			if (data.errorNumber === errorNumber) {
				root.setProperty(i, "errorCode", errorCode)
				return
			} else if (data.errorNumber > errorNumber) {
				insert(i, {"errorNumber": errorNumber, "errorCode": errorCode })
				return
			}
		}
	}
}
