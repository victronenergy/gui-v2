import QtQuick
import QtQuick.Controls

ListView {
	id: root

	property string currentFilename: ""

	clip: true
	delegate: ImageListViewDelegate {
		anchors.left: parent.left
		width: ListView.view.width - listViewScrollBar.width
		onClicked: (index, filename) => {
			root.currentIndex = index
			root.currentFilename = filename
		}
	}
	highlight: Rectangle {
		color: "#E3F2FD"
		border.color: "#2196F3"
		border.width: 2
		radius: 4
	}
	highlightFollowsCurrentItem: true
	highlightMoveDuration: 100

	// Auto-select first item when model is populated
	onCountChanged: {
		if (count > 0 && currentIndex < 0) {
			currentIndex = 0
		}
	}

	ScrollBar.vertical: ScrollBar {
		id: listViewScrollBar
		policy: ScrollBar.AlwaysOn
		width: 12
	}
}
