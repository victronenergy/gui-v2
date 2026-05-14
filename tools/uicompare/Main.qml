import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Dialogs

Window {
	width: 1280
	height: 800
	visible: true
	title: qsTr("UI Compare")

	// On startup, begin the image comparisons.
	Component.onCompleted: Qt.callLater(testModel.refresh)

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
			missingCandidateCount: testModel.missingCandidateCount

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
				clip: true

				// Update currentFilename when currentIndex changes
				onCurrentIndexChanged: {
					if (currentIndex >= 0) {
						const fileName = testModel.data(testModel.index(currentIndex, 0), 0x0101) // TextRole
						if (fileName && fileName.length > 0) {
							currentFilename = fileName
						}
					} else {
						currentFilename = ""
					}
				}
			}
			CompareView {
				id: compareView
				SplitView.fillWidth: true

				fileName: listView.currentFilename
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
}
