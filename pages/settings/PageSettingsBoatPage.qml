/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property ClassAndVrmInstanceModel _classAndVrmInstanceModel: ClassAndVrmInstanceModel {}

	readonly property FilteredClassAndVrmInstanceModel _motordriveClassAndVrmInstances: FilteredClassAndVrmInstanceModel {
		sourceModel: _classAndVrmInstanceModel
		deviceClasses: ["motordrive"]
	}

	readonly property FilteredDeviceModel _motorDrives: FilteredDeviceModel {
		serviceTypes: ["motordrive"]
	}

	VeQuickItem {
		id: leftDeviceInstanceItem
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/MultiDrive/Left/DeviceInstance"
	}

	VeQuickItem {
		id: rightDeviceInstanceItem
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/MultiDrive/Right/DeviceInstance"
	}

	function getOptions(side) {
		//% "None"
		const noneStr = qsTrId("pagesettingsboatpage_none");
		const options = [
			{ display: noneStr, value: -1 }
		];
		for (let i = 0; i < _motordriveClassAndVrmInstances.count; i++) {
			const vrmInstance = _motordriveClassAndVrmInstances.data(_motordriveClassAndVrmInstances.index(i, 0), ClassAndVrmInstanceModel.VrmInstanceRole);
			if (side === 'left' && rightDeviceInstanceItem.value === vrmInstance) {
				continue;
			}
			if (side === 'right' && leftDeviceInstanceItem.value === vrmInstance) {
				continue;
			}
			//% "E-drive with VRM instance #%1"
			let displayName = qsTrId("pagesettingsboatpage_edrive_with_vrm_instance").arg(vrmInstance);
			const device = _motorDrives.count && _motorDrives.deviceForDeviceInstance(vrmInstance);
			if (device) {
				const serial = device.serviceItem.itemGet("Serial");
				if (serial && serial.value) {
					displayName = `${device.name} [${serial.value}]`;
				} else {
					displayName = device.name;
				}
			}
			options.push({
				display: displayName,
				value: vrmInstance
			});
			options.sort(function(a, b) {
				return a.value - b.value;
			});
		}
		return options;
	}

	GradientListView {
		model: VisibleItemModel {
			ListSwitch {
				text: CommonWords.enabled
				dataItem.uid: !!Global.systemSettings ? Global.systemSettings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/Enabled" : ""
				writeAccessLevel: VenusOS.User_AccessType_User
			}

			SectionHeader {
				//% "Dual-Drive Configuration"
				text: qsTrId("pagesettingsboatpage_dual_drive_configuration")
				preferredVisible: _motordriveClassAndVrmInstances.count >= 2
			}

			ListRadioButtonGroup {
				//% "Left E-drive"
				text: qsTrId("pagesettingsboatpage_multi_drive_left")
				dataItem.uid: leftDeviceInstanceItem.uid
				optionModel: getOptions('left')
				preferredVisible: _motordriveClassAndVrmInstances.count >= 2
			}

			ListRadioButtonGroup {
				//% "Right E-drive"
				text: qsTrId("pagesettingsboatpage_multi_drive_right")
				dataItem.uid: rightDeviceInstanceItem.uid
				optionModel: getOptions('right')
				preferredVisible: _motordriveClassAndVrmInstances.count >= 2
			}
		}
	}
}
