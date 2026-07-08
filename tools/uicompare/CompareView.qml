import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
	id: root

	required property int resultStatus
	required property bool imagesIdentical
	required property string fileName

	property real zoomLevel: overlayZoomSlider.value
	property int comparisonMode: 0 // 0 = diff overlay, 1 = candidate overlay
	property real cropLineX: width / 2

	readonly property string baselineImageUri: !fileName || resultStatus === CompareModel.NoBaselineImage ? ""
			: "file:image-captures-baseline/" + fileName
	readonly property string candidateImageUri: !fileName || resultStatus === CompareModel.NoCandidateImage ? ""
			: "file:image-captures/" + fileName
	readonly property bool bothImagesExist: baselineImageUri.length > 0 && candidateImageUri.length > 0

	// Mode selector toolbar
	Rectangle {
		id: modeSelector
		width: parent.width
		height: toolBarLayout.height + 8
		color: "#f5f5f5"
		border.color: "#ddd"

		RowLayout {
			id: toolBarLayout
			width: parent.width
			anchors.verticalCenter: parent.verticalCenter

			Text {
				text: root.resultStatus === CompareModel.NoBaselineImage ? "Nothing to compare: baseline image missing"
					: root.resultStatus === CompareModel.NoCandidateImage ? "Nothing to compare: candidate image missing"
					: root.imagesIdentical ? "Nothing to compare: baseline and candidate images are identical"
					: ""
				font.pixelSize: 16
				leftPadding: 16
				visible: !modeButtonsLayout.visible
			}

			RowLayout {
				id: modeButtonsLayout
				Layout.fillWidth: false
				spacing: 8
				visible: root.resultStatus === CompareModel.ComparisonReady && !root.imagesIdentical

				Text {
					text: "Compare images:"
					leftPadding: 16
					font.pixelSize: 16
				}

				Button {
					text: "Diff overlay"
					checked: root.comparisonMode === 0
					onClicked: root.comparisonMode = 0
					autoExclusive: true
				}

				Button {
					text: "Candidate overlay"
					checked: root.comparisonMode === 1
					onClicked: root.comparisonMode = 1
					autoExclusive: true
				}

				// Opacity slider for overlay mode
				RowLayout {
					Text {
						text: "Opacity:"
						font.pixelSize: 12
					}
					Slider {
						id: overlayOpacitySlider
						from: 0
						to: 1
						value: 0.5
						Layout.preferredWidth: 200
					}
				}

				CheckBox {
					id: cropLineCheckBox
					text: "Crop line (right click to move)"
				}
			}

			Item {
				Layout.fillWidth: true
			}

			// Zoom controls
			RowLayout {
				Layout.rightMargin: 8

				Text {
					text: "Zoom:"
					font.pixelSize: 12
				}
				Slider {
					id: overlayZoomSlider
					from: 0.5
					to: 5
					value: 1.0
					Layout.preferredWidth: 200
				}
				Button {
					text: "1:1"
					onClicked: overlayZoomSlider.value = 1.0
				}
			}
		}
	}

	// Comparison display area
	Rectangle {
		anchors {
			left: parent.left
			right: parent.right
			top: modeSelector.bottom
			bottom: parent.bottom
		}
		color: "#2a2a2a"
		z: -1 // prevent image from panning over the toolbar

		Flickable {
			id: flickable
			anchors.fill: parent
			contentWidth: comparisonContainer.width * root.zoomLevel
			contentHeight: comparisonContainer.height * root.zoomLevel
			boundsBehavior: Flickable.StopAtBounds

			Item {
				id: comparisonContainer
				x: (flickable.contentWidth > flickable.width) ? 0 : (flickable.width - width * root.zoomLevel) / 2
				y: (flickable.contentHeight > flickable.height) ? 0 : (flickable.height - height * root.zoomLevel) / 2
				width: mainImage.width
				height: mainImage.height
				scale: root.zoomLevel
				transformOrigin: Item.TopLeft

				Image {
					id: mainImage
					source: baselineImageUri.length > 0 ? baselineImageUri : candidateImageUri
				}

				Loader {
					active: root.resultStatus === CompareModel.ComparisonReady && !root.imagesIdentical
					sourceComponent: overlayComponent
				}
			}

			ScrollBar.vertical: ScrollBar { }
			ScrollBar.horizontal: ScrollBar { }
		}

		// Mouse wheel zoom
		MouseArea {
			anchors.fill: parent
			acceptedButtons: Qt.NoButton
			onWheel: (wheel) => {
				if (wheel.modifiers & Qt.ControlModifier) {
					if (wheel.angleDelta.y > 0) {
						overlayZoomSlider.value = Math.min(overlayZoomSlider.to, root.zoomLevel + 0.1)
					} else {
						overlayZoomSlider.value = Math.max(overlayZoomSlider.from, root.zoomLevel - 0.1)
					}
					wheel.accepted = true
				}
			}
		}
	}

	// Missing image indicator
	Rectangle {
		anchors.centerIn: parent
		width: missingImageText.implicitWidth + 40
		height: missingImageText.implicitHeight + 20
		border.color: "white"
		color: "orange"
		radius: 4
		visible: root.resultStatus !== CompareModel.ComparisonPending && !root.bothImagesExist

		Text {
			id: missingImageText
			anchors.centerIn: parent
			text: root.baselineImageUri.length === 0 && root.candidateImageUri.length > 0 ? "Candidate image only (baseline missing)"
				: root.baselineImageUri.length > 0 && root.candidateImageUri.length === 0 ? "Baseline image only (candidate missing)"
				: ""
			color: "white"
			font.bold: true
			font.pixelSize: 32
		}
	}

	Component {
		id: overlayComponent

		Item {
			implicitWidth: candidateImage.implicitWidth
			implicitHeight: candidateImage.implicitHeight

			Item {
				anchors {
					left: parent.left
					top: parent.top
					bottom: parent.bottom
				}
				width: overlayCropLine.visible ? Math.min(root.cropLineX, parent.width) : parent.width
				clip: true

				Image {
					id: candidateImage
					source: root.comparisonMode === 0 ? "image://difference/" + root.fileName : root.candidateImageUri
					opacity: overlayOpacitySlider.value
				}
			}

			// Slider for changing the visible part of the overlay. Can be dragged with left
			// mouse button, or clicking anywhere with the right mouse button will move it.
			Rectangle {
				id: overlayCropLine
				anchors.verticalCenter: parent.verticalCenter
				x: root.cropLineX
				width: 8
				height: flickable.height * 2
				color: "#00BCD4"
				visible: cropLineCheckBox.checked && root.resultStatus === CompareModel.ComparisonReady && !root.imagesIdentical

				MouseArea {
					anchors.fill: parent
					drag.target: parent
					drag.axis: Drag.XAxis
				}
			}

			MouseArea {
				anchors.fill: parent
				enabled: overlayCropLine.visible
				acceptedButtons: Qt.RightButton
				onClicked: root.cropLineX = mouseX
				onPressAndHold: root.cropLineX = mouseX
				onPressed: root.cropLineX = mouseX
				onPositionChanged: {
					if (pressed) {
						root.cropLineX = mouseX
					}
				}
			}
		}
	}
}
