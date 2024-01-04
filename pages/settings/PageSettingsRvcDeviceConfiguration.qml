/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property string bindPrefix
	readonly property bool _hasMultipleDcSources: dcSource2Instance.isValid

	function _lineInstanceName(num) {
		return num
			  //: %1 = number of this line instance
			  //% "Line instance #%1"
			? qsTrId("settings_rvc_line_instance_num").arg(num)
			  //% "Line instance"
			: qsTrId("settings_rvc_line_instance")
	}

	VeQuickItem {
		id: dcSource2Instance
		uid: root.bindPrefix + "/DcSource/1/Instance"
	}

	GradientListView {
		model: ObjectModel {
			ListSpinBox {
				//% "Charger instance"
				text: qsTrId("settings_rvc_charger_instance")
				dataItem.uid: root.bindPrefix + "/ChargerInstance"
				visible: defaultVisible && dataItem.isValid
			}

			ListSpinBox {
				//% "Inverter instance"
				text: qsTrId("settings_rvc_inverter_instance")
				dataItem.uid: root.bindPrefix + "/InverterInstance"
				visible: defaultVisible && dataItem.isValid
			}

			ListRadioButtonGroup {
				text: root._lineInstanceName(line2.dataItem.isValid ? "1" : "")
				dataItem.uid: root.bindPrefix + "/Line/0/Instance"
				visible: defaultVisible && dataItem.isValid
				optionModel: [
					{ display: "L1", value: 0 },
					{ display: "L2", value: 1 },
				]
			}

			ListRadioButtonGroup {
				id: line2

				text: root._lineInstanceName("2")
				dataItem.uid: root.bindPrefix + "/Line/1/Instance"
				visible: defaultVisible && dataItem.isValid
				optionModel: [
					{ display: "L1", value: 0 },
					{ display: "L2", value: 1 },
				]
			}

			Column {
				width: parent ? parent.width : 0

				Repeater {
					model: 3
					delegate: Column {
						width: parent ? parent.width : 0

						ListSpinBox {
							text: root._hasMultipleDcSources
								  //: %1 = number of this DC source
								  //% "DC source #%1 instance"
								? qsTrId("settings_rvc_dc_source_#_instance").arg(model.index + 1)
								  //% "DC source instance"
								: qsTrId("settings_rvc_dc_source_instance")
							dataItem.uid: root.bindPrefix + "/DcSource/" + model.index + "/Instance"
							visible: defaultVisible && dataItem.isValid
						}

						ListSpinBox {
							text: root._hasMultipleDcSources
								  //: %1 = number of this DC source
								  //% "DC source #%1 priority"
								? qsTrId("settings_rvc_dc_source_#_priority").arg(model.index + 1)
								  //% "DC source priority"
								: qsTrId("settings_rvc_dc_source_priority")
							dataItem.uid: root.bindPrefix + "/DcSource/" + model.index + "/Priority"
							visible: defaultVisible && dataItem.isValid
						}
					}
				}
			}

			ListSpinBox {
				//% "Tank instance"
				text: qsTrId("settings_rvc_tank_instance")
				dataItem.uid: root.bindPrefix + "/TankInstance"
				visible: defaultVisible && dataItem.isValid
			}
		}
	}
}
