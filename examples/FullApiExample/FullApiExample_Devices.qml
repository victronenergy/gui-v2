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

	PluginPrimaryListLabel {
		id: intro

		width: parent.width
		text: "Each list item is a tank. The number on the right is its level."
	}

	ListView {
		anchors.top: intro.bottom
		anchors.bottom: parent.bottom
		width: parent.width
		clip: true
		model: tanks

		delegate: PluginListText {
			required property int index
			required property string name
			required property string serviceUid
			required property string serviceType
			required property int deviceInstance
			required property int productId

			width: ListView.view.width
			text: name
			caption: serviceType + ", instance " + deviceInstance + ", product " + productId
			dataItem.uid: serviceUid + "/Level"
		}
	}
}
