import QtQuick
import Victron.GuiPlugins

/*
	The child paths of a uid, such as the top-level paths of a device.

	PluginDataPathModel lists the paths that the system has, sorted by name. A path with child paths
	opens this page again, for that path's uid. A path without child paths shows its value, read
	with a PluginDataItem. A second PluginDataPathModel in each list item tells the two apart.
*/
PluginPage {
	id: root

	// Set by the list item that opens this page.
	property string pathUid

	PluginDataPathModel {
		id: paths

		uid: root.pathUid
	}

	PluginModelListView {
		model: paths

		header: PluginPrimaryListLabel {
			text: root.pathUid + " has " + paths.count + " child paths."
		}

		delegate: PluginListNavigation {
			id: pathListItem

			required property string childName
			required property string childUid

			readonly property PluginDataPathModel childPaths: PluginDataPathModel {
				uid: pathListItem.childUid
			}
			readonly property bool hasChildPaths: childPaths.count > 0

			// Only a path without child paths has a value of its own.
			readonly property PluginDataItem pathValue: PluginDataItem {
				uid: pathListItem.hasChildPaths ? "" : pathListItem.childUid
			}

			text: pathListItem.childName
			secondaryText: pathListItem.hasChildPaths ? ""
				: pathListItem.pathValue.valid ? String(pathListItem.pathValue.value)
				: "--"
			interactive: pathListItem.hasChildPaths
			pageUrl: Qt.resolvedUrl("FullApiExample_Paths.qml")
			pageProperties: ({ pathUid: pathListItem.childUid })
		}
	}
}
