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
		spacing: 0

		Toolbar {
			id: toolbar
			Layout.preferredHeight: 80
			Layout.fillWidth: true

			totalCount: testModel.count
			passCount: testModel.passCount
			failCount: testModel.failedCount
			missingBaselineCount: testModel.missingBaselineCount
			missingCandidateCount: testModel.missingCandidateCount

			onFilterChanged: (filterMode) => {
				listView.currentIndex = -1
				testModel.setFilterMode(filterMode)
			}
		}

		SplitView {
			Layout.fillHeight: true
			Layout.fillWidth: true
			z: -1 // scroll list view beneath the toolbar
			orientation: Qt.Horizontal

			Rectangle { // background behind the list view
				SplitView.preferredWidth: 360
				SplitView.minimumWidth: 100
				SplitView.maximumWidth: 600

				ImageListView {
					id: listView
					anchors.fill: parent
					model: testModel
				}
			}

			CompareView {
				id: compareView
				SplitView.fillWidth: true
				SplitView.fillHeight: true
				z: -1 // do not allow comparison image to pan above the list view
				resultStatus: listView.currentResult.status ?? CompareModel.ComparisonPending
				imagesIdentical: listView.currentResult.mse === undefined ? false : Math.round(listView.currentResult.mse) === 0
				fileName: listView.currentResult.fileName ?? ""
			}
		}

		Rectangle {
			Layout.preferredHeight: 30
			Layout.fillWidth: true
			color: "#f5f5f5"
			border.color: "#ddd"
			border.width: 1

			Text {
				anchors.centerIn: parent
				text: compareView.fileName || "Select an image to compare"
				font.pixelSize: 14
				color: "#666"
			}
		}
	}

	CompareModel {
		id: testModel
		errorTolerance: 10.0
	}
}
