/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl as CP
import Victron.VenusOS

T.Button {
	id: root

	property color color: showEnabled
						  ? (down ? Theme.color_button_down_text : Theme.color_font_primary)
						  : (down ? Theme.color_button_on_text_disabled : Theme.color_button_off_text_disabled)
	property color backgroundColor: showEnabled
									? (down ? Theme.color_ok : Theme.color_darkOk)
									: (down ? Theme.color_button_on_background_disabled : Theme.color_background_disabled)
	property color borderColor: showEnabled ? Theme.color_ok : Theme.color_font_disabled
	property real borderWidth: Theme.geometry_button_border_width
	property real radius: Theme.geometry_button_radius
	property real topLeftRadius: NaN
	property real bottomLeftRadius: NaN
	property real topRightRadius: NaN
	property real bottomRightRadius: NaN
	property bool showEnabled: enabled
	property int extent: Theme.geometry_listItem_expanded_clickable_extent
	property int topExtent: extent
	property int bottomExtent: extent
	property int leftExtent: extent
	property int rightExtent: extent
	readonly property string __typename: "Button"
	property var siblings: objectName, root.parent.children
	property var clickableSiblings: []
	property var overlappingButtonPairs: []
	property alias expandedClickableArea: expandedClickableArea
	property var expandedSceneCoords

	onXChanged: sceneCoordsTimer.restart()
	onYChanged: sceneCoordsTimer.restart()
	onObjectNameChanged: sceneCoordsTimer.restart()

	onExpandedSceneCoordsChanged: {
		overlappingButtonPairs = overlappingPairs(clickableSiblings)
	}
	onOverlappingButtonPairsChanged: {
		for (let overlappingButtonPair of overlappingButtonPairs) {
			if (!overlappingButtonPair.itemA.expandedSceneCoords) {
				continue
			}

			if (!overlappingButtonPair.itemB.expandedSceneCoords) {
				continue
			}

			// find the smallest overlap
			let min = getSideToTrim(overlappingButtonPair.c)
			let itemASideToTrim = min[0]
			let overlapSize = min[1]
			var newExtentA = Math.max(0, overlappingButtonPair.itemA[itemASideToTrim] - overlapSize / 2)

			overlappingButtonPair.itemA[itemASideToTrim] = newExtentA

			let itemBSideToTrim = oppositeSide(itemASideToTrim)
			var newExtentB = Math.max(0, overlappingButtonPair.itemB[itemBSideToTrim] - overlapSize / 2)
			overlappingButtonPair.itemB[itemBSideToTrim] = newExtentB
		}
	}

	property alias expandedClickableAreaBackground: expandedClickableAreaBackground

	function getSideToTrim(overlap)
	{
		let retval = Qt.RightEdge

		const [minKey, minValue] =
			Object.entries(overlap).reduce(
				(max, entry) => entry[1] <  max[1] ? entry : max
			);

		return [minKey, minValue]
	}

	function oppositeSide(side) {
		switch (side) {
		case "rightExtent": return "leftExtent"
		case "leftExtent": return "rightExtent"
		case "topExtent": return "bottomExtent"
		case "bottomExtent": return "topExtent"
		default: {
			console.warn("Unknown side")
			return ""
		}
		}
	}

	function rectsOverlap(a, b) {
		let overlap = !(
				a.x + a.width  <= b.x          ||  // a.rhs is left of b.lhs
				b.x + b.width  <= a.x          ||  // b.rhs is left of a.lhs
				a.y + a.height <= b.y          ||  // a is above b
				b.y + b.height <= a.y             // b is above a
			)

		var retval = {
			rightExtent: overlap ? Math.max(((a.x + a.width) - b.x), 0) : 0,
			leftExtent: overlap ? Math.max((b.x + b.width  - a.x), 0) : 0,
			bottomExtent: overlap ? Math.max((a.y + a.height  - b.y), 0) : 0,
			topExtent: overlap ? Math.max((b.y + b.height  - a.y), 0) : 0
		}

		return overlap ? retval : false
	}

	function expandedClickableArea_sceneCoordinates(item) {
		// top-left of the item in scene coords
		const p = item.expandedClickableArea.mapToItem(null, 0, 0)
		const retval = Qt.rect(p.x, p.y, item.width + item.leftExtent + item.rightExtent, item.height + item.topExtent + item.bottomExtent)

		return retval
	}

	/*
	  Given a list of sibling Items, build a list  of Item pairs that have overlapping expanded areas.
	*/
	function overlappingPairs(clickableSiblings) {
		const rects = clickableSiblings.map(expandedClickableArea_sceneCoordinates)
		const overlappingButtonPairs = []

		for (let i = 0; i < clickableSiblings.length; ++i) {
			for (let j = i + 1; j < clickableSiblings.length; ++j) {
				let collision = rectsOverlap(rects[i], rects[j])
				if (collision) {
					overlappingButtonPairs.push({ itemA: clickableSiblings[i], itemB: clickableSiblings[j], expandedItemA: rects[i], expandedItemB: rects[j], c: collision })
				}
			}
		}

		return overlappingButtonPairs
	}
	onSiblingsChanged: {
		let newButtonSiblings = []
		for (let sibling of root.siblings) {

			if (sibling.__typename === "Button" || sibling.__typename === "ListButton" || sibling.__typename === "ListItemButton") {
				newButtonSiblings.push(sibling)
			}
		}
		clickableSiblings = newButtonSiblings
	}
	onClickableSiblingsChanged: {
		overlappingButtonPairs = overlappingPairs(clickableSiblings)
	}

	onPressed: pressEffect.start(pressX/width, pressY/height)
	onReleased: pressEffect.stop()
	onCanceled: pressEffect.stop()
	down: pressed || checked || expandedClickableArea.containsPress
	spacing: Theme.geometry_button_spacing
	topPadding: 0
	bottomPadding: 0
	leftPadding: 0
	rightPadding: 0

	implicitWidth: contentItem.implicitWidth + root.leftPadding + root.rightPadding
	implicitHeight: contentItem.implicitHeight + root.topPadding + root.bottomPadding

	icon.color: root.color
	font.family: Global.fontFamily
	font.pixelSize: Theme.font_size_body1

	// flat=true means the background should not be visible.
	flat: true

	background: Rectangle {
		color: root.backgroundColor
		border.width: root.borderWidth
		border.color: root.borderColor
		visible: !root.flat

		// Only set the radius if none of the corner radii are set, otherwise each corner will be
		// rounded even if no radius has been set for that corner.
		radius: isNaN(root.topLeftRadius)
				&& isNaN(root.bottomLeftRadius)
				&& isNaN(root.topRightRadius)
				&& isNaN(root.bottomRightRadius)
				? root.radius
				: 0

		// Clear corner radii values if they are not set.
		topLeftRadius: isNaN(root.topLeftRadius) ? undefined : root.topLeftRadius
		bottomLeftRadius: isNaN(root.bottomLeftRadius) ? undefined : root.bottomLeftRadius
		topRightRadius: isNaN(root.topRightRadius) ? undefined : root.topRightRadius
		bottomRightRadius: isNaN(root.bottomRightRadius) ? undefined : root.bottomRightRadius
	}

	contentItem: CP.IconLabel {
		spacing: root.spacing
		display: root.display
		icon: root.icon
		text: root.text
		font: root.font
		color: root.color
	}

	KeyNavigationHighlight.active: root.activeFocus

	PressEffect {
		id: pressEffect
		radius: root.radius
		anchors.fill: parent
	}

	MouseArea {
		id: expandedClickableArea
		anchors {
			fill: parent
			topMargin: -topExtent
			leftMargin: -leftExtent
			rightMargin: -rightExtent
			bottomMargin: -bottomExtent
		}
		objectName: root.objectName + ".expandedClickableArea"// TODO: remove
		onClicked: root.clicked()

		Rectangle {// TODO: remove
			id: expandedClickableAreaBackground
			anchors.fill: parent
			color: "pink"
			opacity: 0.5
		}
	}

	Timer {
		id: sceneCoordsTimer
		interval: 1000
		onTriggered: {
			expandedSceneCoords = expandedClickableArea_sceneCoordinates(root)
		}
	}

	Component.onCompleted: {
		sceneCoordsTimer.restart()
	}
}
