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
		if (!preferredVisible) {
			return ""
		}
		if (productId.value === ProductInfo.ProductId_PvInverter_Fronius) {
			return dataItem.value || ""
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
		} else {
			// Generic fallback for all other energy meters.
			// Use /ErrorMessage from D-Bus if available; otherwise
			// display the raw error code number (same as Fronius).
			if (errorMessage.valid && errorMessage.value !== "") {
				//: %1 = error description from the device, %2 = the error code number
				//% "%1 (%2)"
				return qsTrId("ac-in-modeldefault_error_with_message").arg(errorMessage.value).arg(dataItem.value || 0)
			}
			return dataItem.value || ""
		}
		return ""
	}
	preferredVisible: productId.value === ProductInfo.ProductId_PvInverter_Fronius
			|| productId.value === ProductInfo.ProductId_EnergyMeter_CarloGavazzi
			|| (dataItem.valid && dataItem.value > 0)
			|| (errorMessage.valid && errorMessage.value !== "")

	VeQuickItem {
		id: productId
		uid: root.bindPrefix + "/ProductId"
	}

	VeQuickItem {
		id: errorMessage
		uid: root.bindPrefix + "/ErrorMessage"
	}
}
