import QtQuick
import QtQuick.Layouts

Item {
	id: root

	readonly property var splitName: model.text.split("-")
	readonly property bool isIdentical: model.identical
	readonly property bool isPassing: model.similarity >= 0.999
	readonly property bool hasError: model.errorMessage && model.errorMessage.length > 0
	readonly property color statusColor: hasError ? "#F44336" : (isIdentical ? "#4CAF50" : (isPassing ? "#4CAF50" : "#FFC107"))

	signal clicked(index : int, fileName : string)

	implicitHeight: column.height + column.anchors.margins * 2

	Column {
		id: column
		width: parent.width
		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			margins: 8
		}
		spacing: 4

		// Header with status indicator
		Item {
			width: parent.width
			height: 40

			Rectangle {
				id: statusBadge
				anchors.left: parent.left
				anchors.verticalCenter: parent.verticalCenter
				width: 8
				height: 30
				radius: 4
				color: statusColor
			}

			Column {
				id: headerColumn
				anchors {
					left: statusBadge.right
					leftMargin: 8
					right: metricsColumn.left
					rightMargin: 4
					verticalCenter: parent.verticalCenter
				}

				Text {
					id: sectionText
					text: splitName[0].replace("tst_", "")
					font.capitalization: Font.Capitalize
					font.bold: true
					width: headerColumn.width
					elide: Text.ElideRight
				}
				Text {
					id: subSectionText
					text: splitName.length > 1 ? splitName[1] : ""
					font.pixelSize: 10
					color: "#666"
					width: headerColumn.width
					elide: Text.ElideRight
				}
			}

			Column {
				id: metricsColumn
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				spacing: 2

				Text {
					id: similarityText
					anchors.right: parent.right
					text: hasError ? "⚠" : (isIdentical ? "✓ " : "") + ((model.similarity * 100).toFixed(2) + "%")
					font.pixelSize: 10
					color: statusColor
					font.bold: true
				}
				Text {
					id: errorText
					anchors.right: parent.right
					text: hasError ? model.errorMessage : ("Δ " + model.error.toFixed(2))
					font.pixelSize: 9
					color: hasError ? statusColor : "#666"
					elide: Text.ElideRight
					width: Math.min(implicitWidth, 100)
				}
			}
		}

		// Difference thumbnail
		Image {
			id: differenceImage
			width: parent.width
			height: 140
			source: model.text && model.text.length > 0 ? ("image://difference/" + model.text) : ""
			sourceSize: Qt.size(width, 140)
			fillMode: Image.PreserveAspectFit
			visible: source.toString().length > 0
		}
	}

	MouseArea {
		anchors.fill: parent
		onClicked: {
			root.clicked(index, model.text)
		}
	}
}

