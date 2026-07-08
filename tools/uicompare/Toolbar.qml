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

	implicitWidth: toolBarLayout.implicitWidth
	implicitHeight: toolBarLayout.implicitHeight
	color: "#f5f5f5"
	border.color: "#ddd"
	border.width: 1

	component StatisticDisplay : ColumnLayout {
		required property string title
		required property string number
		required property color numberColor

		spacing: 0

		Text {
			Layout.alignment: Text.AlignHCenter
			Layout.preferredWidth: 60
			horizontalAlignment: Text.AlignHCenter
			text: number
			font.pixelSize: 18
			font.bold: true
			color: numberColor
			leftPadding: 4
			rightPadding: 4
		}

		Text {
			Layout.alignment: Text.AlignHCenter
			horizontalAlignment: Text.AlignHCenter
			text: title
			font.pixelSize: 12
			color: "#666"
			leftPadding: 4
			rightPadding: 4
		}
	}

	RowLayout {
		id: toolBarLayout

		anchors.fill: parent
		anchors.margins: 8
		spacing: 12

		// Statistics display
		Rectangle {
			Layout.preferredWidth: toolBarContentLayout.implicitWidth
			Layout.fillHeight: true
			color: "#fff"
			border.color: "#ddd"
			radius: 4

			ColumnLayout {
				id: toolBarContentLayout
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

					StatisticDisplay {
						title: "Total"
						number: root.totalCount
						numberColor: "black"
					}

					StatisticDisplay {
						title: "Pass"
						number: root.passCount
						numberColor: "#4CAF50"
					}

					StatisticDisplay {
						title: "Fail"
						number: root.failCount
						numberColor: "#F44336"
					}

					StatisticDisplay {
						title: "No baseline"
						number: root.missingBaselineCount
						numberColor: "orange"
					}

					StatisticDisplay {
						title: "No candidate"
						number: root.missingCandidateCount
						numberColor: "orange"
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

