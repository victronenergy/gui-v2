/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

VisibleItemModel {
	id: root

	property string bindPrefix
	readonly property bool _hasMultipleDcSources: _dcSource2Instance.valid
	readonly property VeQuickItem _dcSource2Instance: VeQuickItem {
		uid: root.bindPrefix + "/DcSource/1/Instance"
	}

	function _lineInstanceName(num) {
		return num
			  //: %1 = number of this line instance
			  //% "Line instance #%1"
			? qsTrId("settings_rvc_line_instance_num").arg(num)
			  //% "Line instance"
			: qsTrId("settings_rvc_line_instance")
	}

	ListSpinBox {
		//% "Charger instance"
		text: qsTrId("settings_rvc_charger_instance")
		dataItem.uid: root.bindPrefix + "/ChargerInstance"
		preferredVisible: dataItem.valid
	}

	ListSpinBox {
		//% "Inverter instance"
		text: qsTrId("settings_rvc_inverter_instance")
		dataItem.uid: root.bindPrefix + "/InverterInstance"
		preferredVisible: dataItem.valid
	}

	ListRadioButtonGroup {
		text: root._lineInstanceName(line2.dataItem.valid ? "1" : "")
		dataItem.uid: root.bindPrefix + "/Line/0/Instance"
		preferredVisible: dataItem.valid
		optionModel: [
			{ display: "L1", value: 0 },
			{ display: "L2", value: 1 },
		]
	}

	ListRadioButtonGroup {
		id: line2

		text: root._lineInstanceName("2")
		dataItem.uid: root.bindPrefix + "/Line/1/Instance"
		preferredVisible: dataItem.valid
		optionModel: [
			{ display: "L1", value: 0 },
			{ display: "L2", value: 1 },
		]
	}

	SettingsColumn {
		width: parent ? parent.width : 0
		preferredVisible: dcSource0Instance.preferredVisible || dcSource0Priority.preferredVisible

		ListSpinBox {
			id: dcSource0Instance
			text: root._hasMultipleDcSources
					//% "DC source 1 instance"
				? qsTrId("settings_rvc_dc_source_1_instance")
					//% "DC source instance"
				: qsTrId("settings_rvc_dc_source_instance")
			dataItem.uid: root.bindPrefix + "/DcSource/0/Instance"
			preferredVisible: dataItem.valid
		}

		ListSpinBox {
			id: dcSource0Priority
			text: root._hasMultipleDcSources
					//% "DC source 1 priority"
				? qsTrId("settings_rvc_dc_source_1_priority")
					//% "DC source priority"
				: qsTrId("settings_rvc_dc_source_priority")
			dataItem.uid: root.bindPrefix + "/DcSource/0/Priority"
			preferredVisible: dataItem.valid
		}
	}

	SettingsColumn {
		width: parent ? parent.width : 0
		preferredVisible: dcSource1Instance.preferredVisible || dcSource1Priority.preferredVisible

		ListSpinBox {
			id: dcSource1Instance
			//% "DC source 2 instance"
			text: qsTrId("settings_rvc_dc_source_2_instance")
			dataItem.uid: root.bindPrefix + "/DcSource/1/Instance"
			preferredVisible: dataItem.valid
		}

		ListSpinBox {
			id: dcSource1Priority
			//% "DC source 2 priority"
			text: qsTrId("settings_rvc_dc_source_2_priority")
			dataItem.uid: root.bindPrefix + "/DcSource/1/Priority"
			preferredVisible: dataItem.valid
		}
	}

	SettingsColumn {
		width: parent ? parent.width : 0
		preferredVisible: dcSource2Instance.preferredVisible || dcSource2Priority.preferredVisible

		ListSpinBox {
			id: dcSource2Instance
			//% "DC source 3 instance"
			text: qsTrId("settings_rvc_dc_source_3_instance")
			dataItem.uid: root.bindPrefix + "/DcSource/2/Instance"
			preferredVisible: dataItem.valid
		}

		ListSpinBox {
			id: dcSource2Priority
			//% "DC source 3 priority"
			text: qsTrId("settings_rvc_dc_source_3_priority")
			dataItem.uid: root.bindPrefix + "/DcSource/2/Priority"
			preferredVisible: dataItem.valid
		}
	}

	ListSpinBox {
		//% "Tank instance"
		text: qsTrId("settings_rvc_tank_instance")
		dataItem.uid: root.bindPrefix + "/TankInstance"
		preferredVisible: dataItem.valid
	}

	ListSpinBox {
		//% "Transfer switch instance"
		text: qsTrId("settings_rvc_transfer_switch_instance")
		dataItem.uid: root.bindPrefix + "/AtsInstance"
		preferredVisible: dataItem.valid
	}
}
