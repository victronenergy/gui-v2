import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
	id: root

	property string filename
	property string leftImageUri
	property string rightImageUri
	property int comparisonMode: 0  // 0=side-by-side, 1=overlay
	property real zoomLevel: overlayZoomSlider.value

	Column {
		anchors.fill: parent
		spacing: 4

		// Mode selector toolbar
		Rectangle {
			width: parent.width
			height: 40
			color: "#f5f5f5"
			border.color: "#ddd"

			RowLayout {
				anchors.centerIn: parent
				spacing: 8

				Text {
					text: "Mode:"
					font.pixelSize: 11
				}

				Button {
					text: "Side by Side"
					checked: root.comparisonMode === 0
					onClicked: root.comparisonMode = 0
					checkable: true
					autoExclusive: true
				}

				Button {
					text: "Overlay"
					checked: root.comparisonMode === 1
					onClicked: root.comparisonMode = 1
					checkable: true
					autoExclusive: true
				}

				Item { Layout.fillWidth: true }

				// Opacity slider for overlay mode
				RowLayout {
					//enabled: root.comparisonMode === 1
					Text {
						text: "Opacity:"
						font.pixelSize: 10
					}
					Slider {
						id: overlayOpacitySlider
						from: 0
						to: 1
						value: 0.5
						Layout.preferredWidth: 100
					}
				}

				// Zoom controls
				RowLayout {
					//enabled: root.comparisonMode === 1
					Text {
						text: "Zoom:"
						font.pixelSize: 10
					}
					Slider {
						id: overlayZoomSlider
						from: 0.8
						to: 10
						value: 1.0
						Layout.preferredWidth: 100
					}
					Button {
						text: "1:1"
						onClicked: root.zoomLevel = 1.0
					}
				}


			}
		}

		// Comparison display area
		Rectangle {
			width: parent.width
			height: parent.height - 44
			color: "#2a2a2a"
			clip: true

			Flickable {
				id: flickable
				anchors.fill: parent
				contentWidth: comparisonLoader.item ? comparisonLoader.item.width * root.zoomLevel : width
				contentHeight: comparisonLoader.item ? comparisonLoader.item.height * root.zoomLevel : height
				boundsBehavior: Flickable.StopAtBounds

				Loader {
					id: comparisonLoader
					x: (flickable.contentWidth > flickable.width) ? 0 : (flickable.width - width * root.zoomLevel) / 2
					y: (flickable.contentHeight > flickable.height) ? 0 : (flickable.height - height * root.zoomLevel) / 2
					scale: root.zoomLevel
					transformOrigin: Item.TopLeft

					sourceComponent: {
						switch(root.comparisonMode) {
						case 0: return sideBySideComponent
						case 1: return overlayComponent
						case 2: return differenceComponent
						case 3: return flickerComponent
						default: return sideBySideComponent
						}
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
							root.zoomLevel = Math.min(4.0, root.zoomLevel + 0.1)
						} else {
							root.zoomLevel = Math.max(0.25, root.zoomLevel - 0.1)
						}
						wheel.accepted = true
					}
				}
			}
		}
	}

	// Side-by-side comparison (original with slider)
	Component {
		id: sideBySideComponent

		Item {
			implicitWidth: Math.max(leftImage.implicitWidth, rightImage.implicitWidth, 10)
			implicitHeight: Math.max(leftImage.implicitHeight, rightImage.implicitHeight, 10)

			readonly property bool leftExists: leftImage.status === Image.Ready
			readonly property bool rightExists: rightImage.status === Image.Ready
			readonly property bool bothExist: leftExists && rightExists

			Image {
				id: leftImage
				source: leftImageUri && leftImageUri.length > 0 ? leftImageUri : ""
				fillMode: Image.Pad
				visible: leftExists
			}

			Rectangle {
				anchors {
					left: parent.left
					top: parent.top
					bottom: parent.bottom
				}
				width: bothExist ? sliderRect.x : (rightExists ? parent.width : 0)
				clip: true

				Image {
					id: rightImage
					source: rightImageUri && rightImageUri.length > 0 ? rightImageUri : ""
					fillMode: Image.Pad
					visible: rightExists
				}
			}

			// Slider only visible when both images exist
			Rectangle {
				id: sliderRect
				x: parent.width / 2
				y: 0
				width: 3
				height: parent.height
				color: "#00BCD4"
				visible: bothExist
			}

			// Missing image indicator for baseline (left)
			Rectangle {
				anchors.centerIn: parent
				width: missingLeftText.implicitWidth + 40
				height: missingLeftText.implicitHeight + 20
				color: "#FF9800"
				radius: 4
				visible: !leftExists && rightExists

				Text {
					id: missingLeftText
					anchors.centerIn: parent
					text: "Baseline image missing"
					color: "white"
					font.bold: true
					font.pixelSize: 14
				}
			}

			// Missing image indicator for current (right)
			Rectangle {
				anchors.centerIn: parent
				width: missingRightText.implicitWidth + 40
				height: missingRightText.implicitHeight + 20
				color: "#FF9800"
				radius: 4
				visible: leftExists && !rightExists

				Text {
					id: missingRightText
					anchors.centerIn: parent
					text: "Current image missing"
					color: "white"
					font.bold: true
					font.pixelSize: 14
				}
			}

			MouseArea {
				anchors.fill: parent
				enabled: bothExist
				onClicked: sliderRect.x = mouseX
				onPressAndHold: sliderRect.x = mouseX
				onPressed: sliderRect.x = mouseX
				onPositionChanged: {
					if (pressed) {
						sliderRect.x = mouseX
					}
				}
			}
		}
	}

	// Overlay comparison
	Component {
		id: overlayComponent

		Item {
			implicitWidth: Math.max(baseImage.implicitWidth, overlayImage.implicitWidth, 10)
			implicitHeight: Math.max(baseImage.implicitHeight, overlayImage.implicitHeight, 10)

			readonly property bool baseExists: baseImage.status === Image.Ready
			readonly property bool overlayExists: overlayImage.status === Image.Ready

			Image {
				id: baseImage
				source: leftImageUri && leftImageUri.length > 0 ? leftImageUri : ""
				fillMode: Image.Pad
				visible: baseExists
			}

			Image {
				id: overlayImage
				source: rightImageUri && rightImageUri.length > 0 ? rightImageUri : ""
				fillMode: Image.Pad
				opacity: overlayOpacitySlider.value
				visible: overlayExists
			}

			// Missing image indicator for baseline
			Rectangle {
				anchors.centerIn: parent
				width: missingBaseText.implicitWidth + 40
				height: missingBaseText.implicitHeight + 20
				color: "#FF9800"
				radius: 4
				visible: !baseExists && overlayExists

				Text {
					id: missingBaseText
					anchors.centerIn: parent
					text: "Baseline image missing"
					color: "white"
					font.bold: true
					font.pixelSize: 14
				}
			}

			// Missing image indicator for current
			Rectangle {
				anchors.centerIn: parent
				width: missingOverlayText.implicitWidth + 40
				height: missingOverlayText.implicitHeight + 20
				color: "#FF9800"
				radius: 4
				visible: baseExists && !overlayExists

				Text {
					id: missingOverlayText
					anchors.centerIn: parent
					text: "Current image missing"
					color: "white"
					font.bold: true
					font.pixelSize: 14
				}
			}
		}
	}

	// Difference view
	Component {
		id: differenceComponent

		Item {
			implicitWidth: diffImage.implicitWidth
			implicitHeight: diffImage.implicitHeight

			Image {
				id: differenceImage
				source: root.filename ? ("image://difference/" + root.filename) : ""
				fillMode: Image.Pad
			}
		}
	}

	// Flicker comparison
	Component {
		id: flickerComponent

		Item {
			implicitWidth: Math.max(flickerLeft.implicitWidth, flickerRight.implicitWidth, 10)
			implicitHeight: Math.max(flickerLeft.implicitHeight, flickerRight.implicitHeight, 10)

			readonly property bool leftExists: flickerLeft.status === Image.Ready
			readonly property bool rightExists: flickerRight.status === Image.Ready
			readonly property bool bothExist: leftExists && rightExists

			Image {
				id: flickerLeft
				source: leftImageUri && leftImageUri.length > 0 ? leftImageUri : ""
				fillMode: Image.Pad
				visible: leftExists && (flickerTimer.showLeft || !rightExists)
			}

			Image {
				id: flickerRight
				source: rightImageUri && rightImageUri.length > 0 ? rightImageUri : ""
				fillMode: Image.Pad
				visible: rightExists && (!flickerTimer.showLeft || !leftExists)
			}

			// Missing image indicator for baseline
			Rectangle {
				anchors.centerIn: parent
				width: missingFlickerLeftText.implicitWidth + 40
				height: missingFlickerLeftText.implicitHeight + 20
				color: "#FF9800"
				radius: 4
				visible: !leftExists && flickerTimer.showLeft && rightExists

				Text {
					id: missingFlickerLeftText
					anchors.centerIn: parent
					text: "Baseline image missing"
					color: "white"
					font.bold: true
					font.pixelSize: 14
				}
			}

			// Missing image indicator for current
			Rectangle {
				anchors.centerIn: parent
				width: missingFlickerRightText.implicitWidth + 40
				height: missingFlickerRightText.implicitHeight + 20
				color: "#FF9800"
				radius: 4
				visible: !rightExists && !flickerTimer.showLeft && leftExists

				Text {
					id: missingFlickerRightText
					anchors.centerIn: parent
					text: "Current image missing"
					color: "white"
					font.bold: true
					font.pixelSize: 14
				}
			}

			Timer {
				id: flickerTimer
				property bool showLeft: true
				interval: 500
				repeat: true
				running: bothExist
				onTriggered: showLeft = !showLeft
			}
		}
	}
}
