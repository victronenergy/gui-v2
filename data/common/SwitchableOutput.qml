/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A switchable output (aka "channel").

	The main details for each output are provided under the output uid. For example, for an output
	provided by a 'switch' service, the details are under:
		com.victronenergy.switch[.suffix]/SwitchableOutput/<outputId>

	Further settings are provided under the /Settings path:
		com.victronenergy.switch[.suffix]/SwitchableOutput/<outputId>/Settings/<Group|Type|[etc]>

	System relays configured with a "manual" function are also published as switchable outputs, at:
		com.victronenergy.system/SwitchableOutput/<outputId>
*/
QtObject {
	id: root

	// The fully qualified uid for the output. For example, for an output on the 'switch' service
	// on D-Bus, it is: com.victronenergy.switch[.suffix]/SwitchableOutput/<outputId>
	required property string uid

	// The identifier for the output on its device (not necessarily an integer)
	readonly property string outputId: uid.substring(uid.lastIndexOf('/') + 1)

	// The device to which this output belongs. This may be a switch from a com.victronenergy.switch
	// service, or another service like a solar charger or inverter, or the system service if it
	// controls a system relay.
	readonly property Device device: Device {
		serviceUid: BackendConnection.serviceUidFromUid(root.uid)
	}

	// A name for the output, with additional details: if the output has no custom name and is in a
	// named group (rather than its default device group), the returned text includes the device
	// name and instance.
	readonly property string formattedName: {
		if (customName) {
			return customName
		}
		if (group) {
			// When the output is in a named group (where it might be in the same group as outputs
			// from other devices) then use a name that identifies the source device.
			const prefix = device.serviceType === "system" ? CommonWords.gx_device_relays
					: device.customName ? device.customName
					: "%1 (%2)".arg(device.productName).arg(device.deviceInstance)
			return "%1 | %2".arg(prefix).arg(name)
		} else {
			// When the output is in the default group for the device, instead of in a named group,
			// then the /Name can be used directly.
			return name
		}
	}

	// Output/channel operational paths
	readonly property int state: _state.valid ? _state.value : -1
	readonly property int status: _status.valid ? _status.value : -1
	readonly property string name: _name.value ?? ""
	readonly property int dimming: _dimming.valid ? _dimming.value : 0  // 0-100 %
	readonly property bool hasDimming: _dimming.valid

	// Output/channel settings
	readonly property int type: _type.valid ? _type.value : -1
	readonly property string group: _group.value ?? ""
	readonly property string customName: _customName.value ?? ""
	readonly property bool showUIControl: (!_showUIControl.valid || _showUIControl.value === 1) // true when setting is not present
			// If this is a system relay, it is only shown in the UI if it is a manual relay.
			&& (!_relayFunction.uid || _relayFunction.value === VenusOS.Relay_Function_Manual)

	function setDimming(value) {
		if (hasDimming) {
			_dimming.setValue(value)
		}
	}

	function setState(value) {
		// require integer state value.
		_state.setValue(value > 0 ? 1 : 0)
	}

	//--- internal implementation below

	readonly property VeQuickItem _state: VeQuickItem {
		uid: `${root.uid}/State`
	}

	readonly property VeQuickItem _status: VeQuickItem {
		uid: `${root.uid}/Status`
	}

	readonly property VeQuickItem _name: VeQuickItem {
		uid: `${root.uid}/Name`
	}

	readonly property VeQuickItem _dimming: VeQuickItem {
		uid: root.type === VenusOS.SwitchableOutput_Type_Dimmable
				|| root.type === VenusOS.SwitchableOutput_Type_UnrangedSetpoint
				|| root.type === VenusOS.SwitchableOutput_Type_TemperatureSetpoint
			 ? `${root.uid}/Dimming` : ""
	}

	readonly property VeQuickItem _customName: VeQuickItem {
		uid: `${root.uid}/Settings/CustomName`
	}

	readonly property VeQuickItem _type: VeQuickItem {
		uid: `${root.uid}/Settings/Type`
	}

	readonly property VeQuickItem _group: VeQuickItem {
		uid: `${root.uid}/Settings/Group`
	}

	readonly property VeQuickItem _showUIControl: VeQuickItem {
		uid: `${root.uid}/Settings/ShowUIControl`
	}

	// /Settings/Function is only valid for system relays.
	readonly property VeQuickItem _relayFunction: VeQuickItem {
		uid: root.device.serviceType === "system" ? `${root.uid}/Settings/Function` : ""
	}
}
