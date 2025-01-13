/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	property int bmsType

	GradientListView {
		model: VisibleItemModel {
			ListText {
				text: CommonWords.allow_to_charge
				secondaryText: CommonWords.yesOrNo(dataItem.value)
				dataItem.uid: bindPrefix + "/Bms/AllowToCharge"
			}

			ListText {
				text: CommonWords.allow_to_discharge
				secondaryText: CommonWords.yesOrNo(dataItem.value)
				dataItem.uid: bindPrefix + "/Bms/AllowToDischarge"
			}

			ListText {
				//% "BMS Error"
				text: qsTrId("vebus_device_bms_error")
				secondaryText: CommonWords.yesOrNo(dataItem.value)
				dataItem.uid: bindPrefix + "/Bms/Error"
				preferredVisible: dataItem.value === VenusOS.VeBusDevice_Bms_Type_VeBus
			}
		}
	}
}
