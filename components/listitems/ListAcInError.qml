/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListText {
	id: root

	property string bindPrefix

	text: CommonWords.error_code
	dataItem.uid: root.bindPrefix + "/ErrorCode"
	secondaryText: {
		if (productId.value === ProductInfo.ProductId_PvInverter_Fronius) {
			return dataItem.value
		} else if (productId.value === ProductInfo.ProductId_EnergyMeter_CarloGavazzi) {
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
	preferredVisible: productId.value === ProductInfo.ProductId_PvInverter_Fronius
			|| productId.value === ProductInfo.ProductId_EnergyMeter_CarloGavazzi


	VeQuickItem {
		id: productId
		uid: root.bindPrefix + "/ProductId"
	}
}
