import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Dialogs
import Uicompare

Window {
	width: 1280
	height: 800
	visible: true
	title: qsTr("Qompare - Image Comparison Tool")

	ColumnLayout {
		anchors.fill: parent
		Toolbar {
			id: toolbar
			Layout.preferredHeight: 70
			Layout.fillWidth: true

			totalCount: testModel.count
			passCount: testModel.passCount
			failCount: testModel.failedCount
			missingBaselineCount: testModel.missingBaselineCount
			missingCurrentCount: testModel.missingCurrentCount

			onFilterChanged: (filterMode) => testModel.setFilterMode(filterMode)
		}

		SplitView {
			Layout.fillHeight: true
			Layout.fillWidth: true
			orientation: Qt.Horizontal

			ImageListView {
				id: listView
				SplitView.preferredWidth: 310
				SplitView.minimumWidth: 100
				SplitView.maximumWidth: 600
				model: testModel

				// Update currentFilename when currentIndex changes
				onCurrentIndexChanged: {
					if (currentIndex >= 0) {
						var filename = testModel.data(testModel.index(currentIndex, 0), 0x0101) // TextRole
						if (filename && filename.length > 0) {
							currentFilename = filename
						}
					} else {
						currentFilename = ""
					}
				}
			}
			CompareView {
				id: compareView
				SplitView.fillWidth: true

				filename: listView.currentFilename
				leftImageUri: listView.currentFilename ? ("file:image-captures-baseline/" + listView.currentFilename) : ""
				rightImageUri: listView.currentFilename ? ("file:image-captures/" +  listView.currentFilename) : ""
			}
		}

		Rectangle {
			Layout.preferredHeight: 24
			Layout.fillWidth: true
			color: "#f5f5f5"
			border.color: "#ddd"
			border.width: 1

			Text {
				anchors.centerIn: parent
				text: listView.currentFilename || "Select an image to compare"
				font.pixelSize: 11
				color: "#666"
			}
		}
	}

	CompareModel {
		id: testModel
	}

	Timer {
		id: timer
		interval: 1
		running: true
		repeat: false
		onTriggered: testModel.refresh()
	}

	// Component.onCompleted: {
	//	 Qt.callLater(function() {

	//	 })
	// }
}
