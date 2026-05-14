import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
	id: root

	property int totalCount: 0
	property int passCount: 0
	property int failCount: 0
	property int missingBaselineCount: 0
	property int missingCandidateCount: 0
	property int filterMode: 0  // 0=all, 1=pass, 2=fail, 3=missing baseline, 4=missing candidate

	signal filterChanged(filterMode : int)

	color: "#f5f5f5"
	border.color: "#ddd"
	border.width: 1

	RowLayout {
		anchors.fill: parent
		anchors.margins: 8
		spacing: 12

		// Statistics display
		Rectangle {
			Layout.preferredWidth: 280
			Layout.fillHeight: true
			color: "#fff"
			border.color: "#ddd"
			radius: 4

			ColumnLayout {
				anchors.centerIn: parent
				spacing: 2

				Text {
					Layout.alignment: Qt.AlignHCenter
					text: "Test Results"
					font.bold: true
					font.pixelSize: 12
				}

				RowLayout {
					Layout.alignment: Qt.AlignHCenter
					spacing: 16

					Column {
						Text {
							anchors.horizontalCenter: parent.horizontalCenter
							text: root.totalCount
							font.pixelSize: 18
							font.bold: true
						}
						Text {
							text: "Total"
							font.pixelSize: 9
							color: "#666"
						}
					}

					Column {
						Text {
							anchors.horizontalCenter: parent.horizontalCenter
							text: root.passCount
							font.pixelSize: 18
							font.bold: true
							color: "#4CAF50"
						}
						Text {
							text: "Pass"
							font.pixelSize: 9
							color: "#666"
						}
					}

					Column {
						Text {
							anchors.horizontalCenter: parent.horizontalCenter
							text: root.failCount
							font.pixelSize: 18
							font.bold: true
							color: "#F44336"
						}
						Text {
							text: "Fail"
							font.pixelSize: 9
							color: "#666"
						}
					}

					Column {
						Text {
							anchors.horizontalCenter: parent.horizontalCenter
							text: root.missingBaselineCount
							font.pixelSize: 18
							font.bold: true
							color: "#FF9800"
						}
						Text {
							text: "No Base"
							font.pixelSize: 9
							color: "#666"
						}
					}

					Column {
						Text {
							anchors.horizontalCenter: parent.horizontalCenter
							text: root.missingCandidateCount
							font.pixelSize: 18
							font.bold: true
							color: "#FF9800"
						}
						Text {
							text: "No Cand"
							font.pixelSize: 9
							color: "#666"
						}
					}
				}
			}
		}

		// Filter controls
		RowLayout {
			spacing: 4

			Text {
				text: "Filter:"
				font.pixelSize: 11
			}

			ComboBox {
				id: filterCombo
				model: ["Show All", "Pass Only", "Fail Only", "Missing Baseline", "Missing Candidate"]
				onCurrentIndexChanged: root.filterChanged(currentIndex)
			}
		}

		Item {
			Layout.fillWidth: true
		}
	}
}

