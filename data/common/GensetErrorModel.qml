/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListModel {
	id: root

	property string uidPrefix

	property Instantiator instantiator: Instantiator {
		model: 8
		delegate: VeQuickItem {
			uid: uidPrefix + "/Error/" + index + "/Id"
			onValueChanged: { // eg. "dse:w-4097"
				root._errorChanged(index, value)
			}
		}
	}

	function _errorChanged(errorNumber, errorCode) { // 'errorCode' is eg. "dse:w-4097"
		if (root.count === 0) { // initialize ListModel
			for (let i = 0; i < instantiator.model; ++i) {
				root.append({"errorNumber": i, "errorCode": ""})
			}
		}

		root.setProperty(errorNumber, "errorCode", errorCode === undefined ? "" : errorCode)
	}
}
