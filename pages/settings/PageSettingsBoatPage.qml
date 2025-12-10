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
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/DualDrive/Left/DeviceInstance"
	}

	VeQuickItem {
		id: rightDeviceInstanceItem
		uid: Global.systemSettings.serviceUid + "/Settings/Gui/ElectricPropulsionUI/DualDrive/Right/DeviceInstance"
	}

	function getOptions(side) {
		const options = [
			{ display: /*% "None"*/ qsTrId("pagesettingsboatpage_none"), value: -1 }
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
			SectionHeader {
				//% "Dual-Drive Configuration"
				text: qsTrId("pagesettingsboatpage_dual_drive_configuration")
				preferredVisible: _motordriveClassAndVrmInstances.count >= 2
			}

			ListRadioButtonGroup {
				//% "Left E-drive"
				text: qsTrId("pagesettingsboatpage_dual_drive_left")
				dataItem.uid: leftDeviceInstanceItem.uid
				optionModel: getOptions('left')
				preferredVisible: _motordriveClassAndVrmInstances.count >= 2
			}

			ListRadioButtonGroup {
				//% "Right E-drive"
				text: qsTrId("pagesettingsboatpage_dual_drive_right")
				dataItem.uid: rightDeviceInstanceItem.uid
				optionModel: getOptions('right')
				preferredVisible: _motordriveClassAndVrmInstances.count >= 2
			}
		}
	}
}
