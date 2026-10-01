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

	VeQuickItem {
		id: tankInstanceItem
		uid: root.bindPrefix + "/TankInstance"
	}
	VeQuickItem {
		id: instanceItem
		uid: root.bindPrefix + "/Line/1/Instance"
	}
	VeQuickItem {
		id: instanceItem2
		uid: root.bindPrefix + "/Line/0/Instance"
	}
	VeQuickItem {
		id: inverterInstanceItem
		uid: root.bindPrefix + "/InverterInstance"
	}
	VeQuickItem {
		id: chargerInstanceItem
		uid: root.bindPrefix + "/ChargerInstance"
	}
	VeQuickItem {
		id: dcSource2Instance
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
	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				preferredVisible: chargerInstanceItem.valid
				ListSpinBox {
					//% "Charger instance"
					text: qsTrId("settings_rvc_charger_instance")
					dataItem.uid: root.bindPrefix + "/ChargerInstance"
				}
			}

			DelegateComponent {
				preferredVisible: inverterInstanceItem.valid
				ListSpinBox {
					//% "Inverter instance"
					text: qsTrId("settings_rvc_inverter_instance")
					dataItem.uid: root.bindPrefix + "/InverterInstance"
				}
			}

			DelegateComponent {
				preferredVisible: instanceItem2.valid
				ListRadioButtonGroup {
					text: root._lineInstanceName(line2DC.dataItem.valid ? "1" : "")
					dataItem.uid: root.bindPrefix + "/Line/0/Instance"
					optionModel: [
						{ display: "L1", value: 0 },
						{ display: "L2", value: 1 },
					]
				}
			}

			DelegateComponent {
				id: line2DC
				dataItem: VeQuickItem { uid: root.bindPrefix + "/Line/1/Instance" }
				preferredVisible: instanceItem.valid
				ListRadioButtonGroup {
					id: line2

					text: root._lineInstanceName("2")
					dataItem.uid: root.bindPrefix + "/Line/1/Instance"
					optionModel: [
						{ display: "L1", value: 0 },
						{ display: "L2", value: 1 },
					]
				}
			}

			DelegateComponent {
				Column {
					width: parent ? parent.width : 0

					Repeater {
						model: 3
						delegate: SettingsColumn {
							width: parent ? parent.width : 0
							preferredVisible: dcSourceInstance.dataItem.valid || dcSourcePriority.dataItem.valid

							ListSpinBox {
								id: dcSourceInstance
								text: root._hasMultipleDcSources
									  //: %1 = number of this DC source
									  //% "DC source #%1 instance"
									? qsTrId("settings_rvc_dc_source_#_instance").arg(model.index + 1)
									  //% "DC source instance"
									: qsTrId("settings_rvc_dc_source_instance")
								dataItem.uid: root.bindPrefix + "/DcSource/" + model.index + "/Instance"
								preferredVisible: dataItem.valid
							}

							ListSpinBox {
								id: dcSourcePriority
								text: root._hasMultipleDcSources
									  //: %1 = number of this DC source
									  //% "DC source #%1 priority"
									? qsTrId("settings_rvc_dc_source_#_priority").arg(model.index + 1)
									  //% "DC source priority"
									: qsTrId("settings_rvc_dc_source_priority")
								dataItem.uid: root.bindPrefix + "/DcSource/" + model.index + "/Priority"
								preferredVisible: dataItem.valid
							}
						}
					}
				}
			}

			DelegateComponent {
				preferredVisible: tankInstanceItem.valid
				ListSpinBox {
					//% "Tank instance"
					text: qsTrId("settings_rvc_tank_instance")
					dataItem.uid: root.bindPrefix + "/TankInstance"
				}
			}
		}
	}
}