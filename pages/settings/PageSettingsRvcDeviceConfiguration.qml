/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	readonly property bool _hasMultipleDcSources: dcSource2Instance.valid

	function _lineInstanceName(num) {
		return num
			  //: %1 = number of this line instance
			  //% "Line instance #%1"
			? qsTrId("settings_rvc_line_instance_num").arg(num)
			  //% "Line instance"
			: qsTrId("settings_rvc_line_instance")
	}

	DataPoint {
		id: dcSource2Instance
		source: root.bindPrefix + "/DcSource/1/Instance"
	}

	GradientListView {
		model: ObjectModel {
			ListSpinBox {
				//% "Charger instance"
				text: qsTrId("settings_rvc_charger_instance")
				dataSource: root.bindPrefix + "/ChargerInstance"
				visible: defaultVisible && dataValid
			}

			ListSpinBox {
				//% "Inverter instance"
				text: qsTrId("settings_rvc_inverter_instance")
				dataSource: root.bindPrefix + "/InverterInstance"
				visible: defaultVisible && dataValid
			}

			ListRadioButtonGroup {
				text: root._lineInstanceName(line2.dataValid ? "1" : "")
				dataSource: root.bindPrefix + "/Line/0/Instance"
				visible: defaultVisible && dataValid
				optionModel: [
					{ display: "L1", value: 0 },
					{ display: "L2", value: 1 },
				]
			}

			ListRadioButtonGroup {
				id: line2

				text: root._lineInstanceName("2")
				dataSource: root.bindPrefix + "/Line/1/Instance"
				visible: defaultVisible && dataValid
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
							dataSource: root.bindPrefix + "/DcSource/" + model.index + "/Instance"
							visible: defaultVisible && dataValid
						}

						ListSpinBox {
							text: root._hasMultipleDcSources
								  //: %1 = number of this DC source
								  //% "DC source #%1 priority"
								? qsTrId("settings_rvc_dc_source_#_priority").arg(model.index + 1)
								  //% "DC source priority"
								: qsTrId("settings_rvc_dc_source_priority")
							dataSource: root.bindPrefix + "/DcSource/" + model.index + "/Priority"
							visible: defaultVisible && dataValid
						}
					}
				}
			}

			ListSpinBox {
				//% "Tank instance"
				text: qsTrId("settings_rvc_tank_instance")
				dataSource: root.bindPrefix + "/TankInstance"
				visible: defaultVisible && dataValid
			}
		}
	}
}
