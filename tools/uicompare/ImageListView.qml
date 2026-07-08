import QtQuick
import QtQuick.Controls

ListView {
	id: root

	property var currentResult: ({})

	delegate: ImageListViewDelegate {
		required property int index
		readonly property int fileNameSeparatorIndex: fileName.indexOf('-')

		width: ListView.view.width - listViewScrollBar.width
		height: 80
		title: fileName.substring(4, fileNameSeparatorIndex) // start at 4 to skip "tst_" prefix
		secondaryTitle: fileName.substring(fileNameSeparatorIndex + 1)
		imageSize: Qt.size(height, height)

		onClicked: {
			root.currentIndex = index
		}
	}
	highlight: Rectangle {
		z: 1
		color: "transparent"
		border.color: "#2196F3"
		border.width: 2
		radius: 4
	}
	highlightFollowsCurrentItem: true
	highlightMoveDuration: 100
	keyNavigationEnabled: true
	focus: true

	onCurrentIndexChanged: {
		currentResult = root.model.get(currentIndex)
	}

	// Auto-select first item when model is populated
	Connections {
		target: root.model

		function onFirstResultAvailable() {
			if (root.currentIndex < 0) {
				root.currentIndex = 0
			}
		}
	}

	ScrollBar.vertical: ScrollBar {
		id: listViewScrollBar
		policy: ScrollBar.AlwaysOn
		width: 12
	}
}
