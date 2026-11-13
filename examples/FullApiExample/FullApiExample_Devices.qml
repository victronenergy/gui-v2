import QtQuick
import Victron.GuiPlugins

/*
	The devices of one service type, such as every tank.

	PluginDeviceModel lists the devices, sorted by name, but not the values of their paths. The
	level is a PluginDataItem whose uid is the device's service uid plus a path.
*/
PluginPage {
	PluginDeviceModel {
		id: tanks

		serviceTypes: ["tank"]
	}

	PluginModelListView {
		model: tanks

		header: PluginPrimaryListLabel {
			text: "Each list item is a tank. The number on the right is its level."
		}

		delegate: PluginListText {
			required property int index
			required property string name
			required property string serviceUid
			required property string serviceType
			required property int deviceInstance
			required property int productId

			text: name
			caption: serviceType + ", instance " + deviceInstance + ", product " + productId
			dataItem.uid: serviceUid + "/Level"
		}
	}
}
