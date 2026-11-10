/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseListView {
	id: root

	property int currentIndex
	property bool checked

	// Optional text for the first (off) button. When set, the control is a single-choice group:
	// the off button is highlighted while unchecked and only switches off, the steps are only
	// highlighted while checked, and clicking a step is expected to switch on as well.
	property string offText: ""
	readonly property bool exclusive: offText.length > 0

	// Without the header the strip is a plain row of equal segments (e.g. a short dropdown).
	property bool showHeader: true

	// Step that represents an off state: highlighted in the off colour (e.g. a dropdown whose
	// first option is "/off").
	property int offIndex: -1

	// Expand clickable area to the left of the On/Off button, and to the right of the last button.
	readonly property real horizontalPressMargin: Theme.geometry_controlCard_button_margins

	// Expand clickable area vertically for On/Off and delegate buttons.
	readonly property real verticalPressMargin: Theme.geometry_button_touch_verticalMargin

	readonly property real _totalDelegateWidth: width - (headerItem?.width ?? 0) - Theme.geometry_button_border_width

	// Whole-pixel step widths, the last step takes the remainder: the last button has rounded
	// corners and is therefore antialiased, so a fractional left edge would show as a seam
	// between it and its neighbour.
	// The header absorbs the left press margin and the left border; without it the first step
	// button carries them, so they are taken out of the steps width here.
	readonly property real _stepsWidth: _totalDelegateWidth - horizontalPressMargin
			- (showHeader ? 0 : horizontalPressMargin + Theme.geometry_button_border_width)
	readonly property real _stepWidth: Math.floor(_stepsWidth / Math.max(1, model?.length ?? 1))

	// In single-choice mode the off button is one of (steps + 1) equal segments of the control.
	readonly property real _segmentWidth: Math.floor((width - (2 * horizontalPressMargin) - (2 * Theme.geometry_button_border_width))
			/ ((model?.length ?? 0) + 1))

	// Optional text per step, indexed like the model. An empty entry keeps the model text.
	// The labels are only shown when every one of them fits its button, otherwise all
	// steps fall back to the model text (e.g. the step number).
	property var labels: []

	readonly property bool labelsFit: {
		if (!model || !model.length || !labels || !labels.length) {
			return false
		}
		// Reference the font so that the check is re-run once the font has been loaded or
		// when the language font changes; advanceWidth() alone does not create a dependency.
		const fontFamily = labelMetrics.font.family
		const fontSize = labelMetrics.font.pixelSize
		// Each button paints its background over the same slot width. Keep the button padding
		// free on both sides so the text is not pressed against the neighbouring buttons.
		const slotWidth = _stepWidth
		const available = slotWidth - (2 * Theme.geometry_button_padding)
		for (let i = 0; i < model.length; ++i) {
			const label = labels[i]
			// Text widths are rounded up by Text.implicitWidth, measure the same way
			if (label && Math.ceil(labelMetrics.advanceWidth(label)) > available) {
				return false
			}
		}
		return true
	}

	signal indexClicked(index: int)
	signal onClicked()
	signal offClicked()

	implicitWidth: Theme.geometry_control_width
	implicitHeight: Theme.geometry_iochannel_control_height

	FontMetrics {
		id: labelMetrics
		font.family: Global.fontFamily
		font.pixelSize: Theme.font_size_body1
	}

	// The On/Off button is sized like MiniToggleButton sizes itself: to the longer of On/Off.
	TextMetrics {
		id: headerTextMetrics
		font.family: Global.fontFamily
		font.pixelSize: Theme.font_size_body1
		text: (CommonWords.on.length > CommonWords.off.length) ? CommonWords.on : CommonWords.off
	}
	readonly property real _headerTextWidth: Math.ceil(headerTextMetrics.tightBoundingRect.x + headerTextMetrics.tightBoundingRect.width)
			+ (2 * Theme.geometry_miniSlider_text_padding)

	orientation: ListView.Horizontal
	focus: false
	interactive: false

	// Background rectangle
	Rectangle {
		anchors.horizontalCenter: parent.horizontalCenter
		width: parent.width - (2 * root.horizontalPressMargin)
		height: Theme.geometry_iochannel_control_height
		color: enabled ? Theme.color_brand : Theme.color_font_disabled
		radius: Theme.geometry_button_radius
		z: -1
	}

	// Each button expands vertically beyond the delegate bounds, so that presses above and
	// below the button still trigger the click action. The last button also expands its
	// clickable area to the right.
	delegate: FocusScope {
		readonly property bool firstListItem: index === 0 && !root.showHeader
		readonly property bool lastListItem: index === root.model.length - 1

		// The first (without header) and the last button have rounded corners and are therefore
		// antialiased. The control may sit on a fractional pixel, in which case their straight
		// edge would blend with the background and show as a seam. So their background extends
		// one pixel under the neighbouring button, which paints on top of it with a crisp edge.
		readonly property bool underlapsPrevious: lastListItem && !firstListItem
		readonly property bool underlapsNext: firstListItem && !lastListItem

		implicitWidth: numberButton.width
		implicitHeight: numberButton.height
		// Above the header, which the view keeps at z 1; crisp buttons above the rounded ones
		z: (underlapsPrevious || underlapsNext) ? 1.5 : 2

		// Allow Utils.acceptsKeyNavigation() to accept moving focus to this item.
		focusPolicy: (root.checked || root.exclusive) ? Qt.TabFocus : Qt.NoFocus

		Button {
			id: numberButton

			y: -root.verticalPressMargin
			defaultBackgroundWidth: lastListItem
					? root._stepsWidth - root._stepWidth * (root.model.length - 1)
					: root._stepWidth
			// Never wider than the slot, whatever the text: a wider button would push the next
			// ones onto fractional pixels, which shows as a seam at the antialiased last button.
			width: defaultBackgroundWidth + Math.max(0, leftInset) + Math.max(0, rightInset)
			defaultBackgroundHeight: Theme.geometry_iochannel_control_height - (2 * Theme.geometry_button_border_width)
			topInset: root.verticalPressMargin + Theme.geometry_button_border_width
			bottomInset: root.verticalPressMargin + Theme.geometry_button_border_width
			leftInset: firstListItem ? root.horizontalPressMargin + Theme.geometry_button_border_width
					: underlapsPrevious ? -1 : 0
			rightInset: lastListItem ? root.horizontalPressMargin
					: underlapsNext ? -1 : 0

			// Offset the content to fit within the background.
			topPadding: topInset
			bottomPadding: bottomInset
			leftPadding: Math.max(0, leftInset)
			rightPadding: Math.max(0, rightInset)

			topLeftRadius: firstListItem ? Theme.geometry_button_radius - Theme.geometry_button_border_width : 0
			topRightRadius: lastListItem ? Theme.geometry_button_radius - Theme.geometry_button_border_width : 0
			bottomLeftRadius: firstListItem ? Theme.geometry_button_radius - Theme.geometry_button_border_width : 0
			bottomRightRadius: lastListItem ? Theme.geometry_button_radius - Theme.geometry_button_border_width : 0
			borderWidth: 0
			flat: false
			text: root.labelsFit && root.labels[index] ? root.labels[index] : modelData.text
			font.pixelSize: Theme.font_size_body1
			color: root.enabled
					? (checked ? Theme.color_button_down_text : Theme.color_font_primary)
					: Theme.color_font_disabled
			backgroundColor: !root.enabled ? (checked ? Theme.color_button_off_background_disabled : Theme.color_background_disabled)
					: checked ? ((root.checked && index !== root.offIndex) ? Theme.color_brand : Theme.color_button_off_background)
					: Theme.color_darkBrand
			checked: index === root.currentIndex && (!root.exclusive || root.checked)
			focus: true

			onClicked: root.indexClicked(index)
		}
	}

	header: showHeader ? headerComponent : null

	Component {
		id: headerComponent

		FocusScope {
		implicitWidth: stateToggleButton.width
		implicitHeight: stateToggleButton.height
		// Rounded (antialiased) on the left: its background extends one pixel under the first
		// step button, which paints on top of it (the view keeps the header at z 1), so no seam
		// shows on a fractional pixel.

		// Allow Utils.acceptsKeyNavigation() to accept moving focus to this item.
		focusPolicy: Qt.TabFocus

		MiniToggleButton {
			id: stateToggleButton

			y: -root.verticalPressMargin
			defaultBackgroundHeight: Theme.geometry_iochannel_control_height - (2 * Theme.geometry_button_border_width)
			topInset: root.verticalPressMargin + Theme.geometry_button_border_width
			bottomInset: root.verticalPressMargin + Theme.geometry_button_border_width
			leftInset: root.horizontalPressMargin + Theme.geometry_button_border_width
			rightInset: -1

			// Offset the content to fit within the background.
			topPadding: topInset
			bottomPadding: bottomInset
			leftPadding: leftInset
			rightPadding: 0

			topLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			topRightRadius: 0
			bottomLeftRadius: Theme.geometry_button_radius - Theme.geometry_button_border_width
			bottomRightRadius: 0
			borderWidth: 0
			flat: false
			text: root.exclusive ? root.offText : (checked ? CommonWords.on : CommonWords.off)
			defaultBackgroundWidth: root.exclusive ? root._segmentWidth : root._headerTextWidth
			// An equal segment regardless of the off text (which elides when too long), and the
			// one pixel of underlap grows the background rather than shrinking the button.
			width: defaultBackgroundWidth + Math.max(0, leftInset) + Math.max(0, rightInset)
			color: !enabled ? Theme.color_font_disabled
					: (root.exclusive && !root.checked) ? Theme.color_button_down_text
					: Theme.color_font_primary
			// The selected off state uses the same colour as an off toggle / the selected step of an
			// off switch, not the "on" colour of a selected step.
			backgroundColor: !root.enabled ? (root.exclusive && !root.checked ? Theme.color_button_off_background_disabled : Theme.color_background_disabled)
					: (root.exclusive && !root.checked) ? Theme.color_button_off_background
					: Theme.color_darkBrand
			checked: root.checked
			focus: true
			separatorColor: enabled ? Theme.color_multistepbutton_separator : Theme.color_font_disabled
			separatorVisible: !root.exclusive && root.currentIndex !== 0

			onClicked: {
				if (root.exclusive) {
					// The off button only switches off; a step switches on.
					if (root.checked) {
						root.offClicked()
					}
				} else if (root.checked) {
					root.offClicked()
				} else {
					root.onClicked()
				}
			}
		}
		}
	}

	Keys.onEnterPressed: focus = false
	Keys.onEscapePressed: focus = false
	Keys.onReturnPressed: focus = false
	Keys.onLeftPressed: (event) => { event.accepted = true }
	Keys.onRightPressed: (event) => { event.accepted = true }
	Keys.onUpPressed: (event) => { event.accepted = true }
	Keys.onDownPressed: (event) => { event.accepted = true }
}
