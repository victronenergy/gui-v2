import QtQuick
import Victron.GuiPlugins

/*
	A page on the page of a device: here, a Skylla-i charger (product id 0x106).

	The GUI sets serviceUid, productId and deviceName when it opens the page. The device's values
	are read with data items whose uid starts with serviceUid.
*/
PluginDevicePage {
	id: root

	title: "Full API example"

	// The number of the charger's outputs.
	readonly property PluginDataItem outputCount: PluginDataItem {
		uid: root.serviceUid + "/NrOfOutputs"
	}

	PluginGradientListView {
		PluginSettingsListHeader {
			text: "Device"
		}

		PluginListText {
			text: "Name"
			secondaryText: root.deviceName
		}

		PluginListText {
			text: "Product id"
			secondaryText: "0x" + root.productId.toString(16)
		}

		PluginListText {
			text: "Service"
			secondaryText: root.serviceUid
		}

		PluginSettingsListHeader {
			text: "Output 1"
		}

		PluginListQuantity {
			text: PluginWords.voltage
			unit: PluginUnit.Volt_DC
			dataItem.uid: root.serviceUid + "/Dc/0/Voltage"
		}

		PluginListQuantity {
			text: PluginWords.current_amps
			unit: PluginUnit.Amp
			dataItem.uid: root.serviceUid + "/Dc/0/Current"
		}

		PluginListTemperature {
			text: PluginWords.temperature
			dataItem.uid: root.serviceUid + "/Dc/0/Temperature"
			// Hidden when the charger has no temperature sensor.
			preferredVisible: dataItem.valid
		}

		PluginSettingsListHeader {
			text: "Output 2"
			preferredVisible: root.outputCount.value >= 2
		}

		PluginListQuantity {
			text: PluginWords.voltage
			unit: PluginUnit.Volt_DC
			dataItem.uid: root.serviceUid + "/Dc/1/Voltage"
			preferredVisible: root.outputCount.value >= 2
		}

		PluginListQuantity {
			text: PluginWords.current_amps
			unit: PluginUnit.Amp
			dataItem.uid: root.serviceUid + "/Dc/1/Current"
			preferredVisible: root.outputCount.value >= 2
		}

		PluginSettingsListHeader {
			text: "Output 3"
			preferredVisible: root.outputCount.value >= 3
		}

		PluginListQuantity {
			text: PluginWords.voltage
			unit: PluginUnit.Volt_DC
			dataItem.uid: root.serviceUid + "/Dc/2/Voltage"
			preferredVisible: root.outputCount.value >= 3
		}

		PluginListQuantity {
			text: PluginWords.current_amps
			unit: PluginUnit.Amp
			dataItem.uid: root.serviceUid + "/Dc/2/Current"
			preferredVisible: root.outputCount.value >= 3
		}

		PluginSettingsListHeader {
			text: "AC input"
		}

		PluginListQuantity {
			text: PluginWords.current_amps
			unit: PluginUnit.Amp
			dataItem.uid: root.serviceUid + "/Ac/In/L1/I"
		}

		PluginListQuantity {
			text: "Current limit"
			unit: PluginUnit.Amp
			dataItem.uid: root.serviceUid + "/Ac/In/CurrentLimit"
		}
	}
}
