/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Units

Page {
	id: root

	property string bindPrefix
	property int bmsType

	GradientListView {
		model: ObjectModel {
			ListRadioButtonGroupNoYes {
				text: CommonWords.allow_to_charge
				dataSource: bindPrefix + "/Bms/AllowToCharge"
				enabled: false
			}

			ListRadioButtonGroupNoYes {
				text: CommonWords.allow_to_discharge
				dataSource: bindPrefix + "/Bms/AllowToDischarge"
				enabled: false
			}

			ListRadioButtonGroupNoYes {
				//% "BMS Error"
				text: qsTrId("vebus_device_bms_error")
				dataSource: bindPrefix + "/Bms/Error"
				enabled: false
				visible: bmsType === VenusOS.VeBusDevice_Bms_Type_VeBus
			}
		}
	}
}
