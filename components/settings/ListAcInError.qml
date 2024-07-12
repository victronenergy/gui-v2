/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextItem {
	id: root

	property string bindPrefix

	// froniusInverterProductId should always be equal to VE_PROD_ID_PV_INVERTER_FRONIUS
	readonly property int froniusInverterProductId: 0xA142
	// carloGavazziEmProductId should always be equal to VE_PROD_ID_CARLO_GAVAZZI_EM
	readonly property int carloGavazziEmProductId: 0xB002

	text: CommonWords.error_code
	dataItem.uid: root.bindPrefix + "/ErrorCode"
	secondaryText: {
		if (productId.value === froniusInverterProductId) {
			return dataItem.value
		} else if (productId.value === carloGavazziEmProductId) {
			if (dataItem.value === 1) {
				//: %1 = the error number
				//% "Front selector locked (%1)"
				return qsTrId("ac-in-modeldefault_front_selector_locked").arg(dataItem.value)
			} else if (dataItem.value !== undefined) {
				//: %1 = the error number
				//% "No error (%1)"
				return qsTrId("ac-in-modeldefault_no_error").arg(dataItem.value)
			}
		}
		return ""
	}
	allowed: productId.value === froniusInverterProductId
			|| productId.value === carloGavazziEmProductId


	VeQuickItem {
		id: productId
		uid: root.bindPrefix + "/ProductId"
	}
}
