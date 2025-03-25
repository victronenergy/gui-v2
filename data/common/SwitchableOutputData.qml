/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS


QtObject{
	id: root

	property string switchuid: model.uid

	property variant splitUid: model.uid.split("/SwitchableOutput/")
	property string deviceUid: splitUid[0]


	property string switchChannel: {
		var val = parseInt(splitUid[1]);
		if ( val !== "NAN" ){
			return val + 1;
		} else {
			return ""
		}
	}
	property string devName: _deviceCustomName.valueValid ? _deviceCustomName.value
														  : _deviceInstance.valid
															? qsTrId("switchDev_InstProductName").arg (_productName.value).arg(_deviceInstance.value)
															: productName.value

	property bool useGroupName: _groupName.valid && _groupName.value!==""
	property string groupName: useGroupName ? _groupName.value : devName
	property string name: _customName.valueValid
						 ? _customName.value
						 : useGroupName
						   //: %1 is the channel of the device, %2 is the device name
						   //% "%2|Ch %1"
						   ? qsTrId("Switches_InGroupDefaultName").arg(switchChannel).arg(devName)
						   //% "Channel %1"
						   : qsTrId("Switches_NonGroupDefaultName").arg(switchChannel)

	property bool overviewVisible: _type.valid
											  && ((_type.value == VenusOS.SwitchableOutput_Function_Momentary)
											  || (_type.value == VenusOS.SwitchableOutput_Function_Latching)
											  || (_type.value == VenusOS.SwitchableOutput_Function_Dimmable))

	property int type: _type.value

	//parent generic device items
	readonly property VeQuickItem _productName: VeQuickItem {
		uid: deviceUid + "/ProductName"
	}
	readonly property VeQuickItem _deviceInstance: VeQuickItem {
		uid: deviceUid + "/DeviceInstance"
	}
	readonly property VeQuickItem _deviceCustomName: VeQuickItem {
		uid: deviceUid + "/CustomName"
		property bool valueValid: valid &&  value !== ""
	}

	//SwitchableOutput items
	readonly property VeQuickItem _groupName: VeQuickItem {
		uid: model.uid + "/Settings/Group"
		property bool valueValid: valid && value !== ""
	}
	readonly property VeQuickItem _customName: VeQuickItem {
		uid: model.uid + "/Settings/CustomName"
		property bool valueValid: valid && value !== ""
	}
	property VeQuickItem _type: VeQuickItem {
		uid: model.uid + "/Settings/Type"
	}
}
