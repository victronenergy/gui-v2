import QtQuick

MouseArea {
	id: root

	required property string title
	required property string secondaryTitle
	required property size imageSize
	required property string fileName

	required property int status
	required property real mse
	required property string errorMessage

	readonly property bool ready: status !== CompareModel.ComparisonPending
	readonly property real similarity: 1 - (mse / (255 * 255 * 4))
	readonly property bool isIdentical: Math.round(mse) === 0
	readonly property bool isPassing: ready && mse < ListView.view.model.errorTolerance
	readonly property bool hasError: ready && errorMessage.length > 0
	readonly property color statusColor: isPassing || isIdentical ? "#4CAF50"
			: status === CompareModel.ComparisonPending
				|| status === CompareModel.NoBaselineImage
				|| status === CompareModel.NoCandidateImage ? "orange"
			: "#F44336"

	implicitHeight: column.implicitHeight + column.anchors.margins * 2

	Rectangle {
		id: statusBadge
		anchors {
			left: parent.left
			leftMargin: 8
			top: column.top
			bottom: column.bottom
		}
		width: 8
		radius: 4
		color: root.statusColor
	}

	Column {
		id: column
		width: parent.width
		anchors {
			top: parent.top
			bottom: parent.bottom
			left: statusBadge.right
			right: thumbnail.left
			margins: 8
		}
		spacing: 4

		Text {
			width: parent.width
			text: root.title
			font.pixelSize: 16
			font.capitalization: Font.Capitalize
			font.bold: true
			elide: Text.ElideRight
		}

		Text {
			width: parent.width
			text: root.secondaryTitle
			font.pixelSize: 14
			color: "#666"
			elide: Text.ElideRight
		}

		Text {
			text: root.errorMessage ? root.errorMessage
				: root.isIdentical ? "✓"
				: "⚠ %1%".arg((root.similarity * 100).toFixed(3))
			font.pixelSize: 16
			color: root.statusColor
			font.bold: true
		}
	}

	// Difference thumbnail
	Image {
		id: thumbnail
		anchors {
			right: parent.right
			rightMargin: 8
		}
		width: root.imageSize.width
		height: root.imageSize.height
		source: root.fileName && root.fileName.length > 0 ? ("image://difference/" + root.fileName) : ""
		sourceSize: root.imageSize
		fillMode: Image.PreserveAspectFit
	}
}
