/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest
import Victron.VenusOS

TestCase {
	id: root

	name: "MultiStepButtonTest"
	when: windowShown
	visible: true
	width: 400
	height: 400

	Component {
		id: buttonComponent

		MultiStepButton {
			// Unit tests load no translation catalogue, so the On/Off header shows the raw
			// "common_words_off" id and is far wider than in the app. Leave room for it.
			width: 700
			model: [ { text: 1 }, { text: 2 }, { text: 3 } ]
		}
	}

	function stepTexts(button) {
		let texts = []
		for (let i = 0; i < button.count; ++i) {
			const delegate = button.itemAtIndex(i)
			verify(delegate, "delegate " + i + " not instantiated")
			let text = ""
			for (const child of delegate.children) {
				if (child.text !== undefined) {
					text = String(child.text)
				}
			}
			texts.push(text)
		}
		return texts
	}

	function test_labels_data() {
		return [
			{
				tag: "no labels",
				labels: [],
				labelsFit: false,
				texts: ["1", "2", "3"],
			},
			{
				tag: "short labels fit",
				labels: ["Low", "Med", "High"],
				labelsFit: true,
				texts: ["Low", "Med", "High"],
			},
			{
				tag: "missing label keeps its number",
				labels: ["Low", "", "High"],
				labelsFit: true,
				texts: ["Low", "2", "High"],
			},
			{
				tag: "one label too long: all steps fall back to numbers",
				labels: ["Low", "Med", "A label that is far too long for its button"],
				labelsFit: false,
				texts: ["1", "2", "3"],
			},
		]
	}

	function test_labels(data) {
		const button = createTemporaryObject(buttonComponent, root)
		verify(button)
		waitForRendering(button)

		button.labels = data.labels
		compare(button.labelsFit, data.labelsFit)
		compare(stepTexts(button), data.texts)
	}

	function test_widthChange() {
		const button = createTemporaryObject(buttonComponent, root)
		verify(button)
		waitForRendering(button)

		button.labels = ["Low", "Med", "High"]
		compare(button.labelsFit, true)
		compare(stepTexts(button), ["Low", "Med", "High"])

		// Not enough room for the labels any more
		button.width = 300
		compare(button.labelsFit, false)
		compare(stepTexts(button), ["1", "2", "3"])

		// ... and back again
		button.width = 700
		compare(button.labelsFit, true)
		compare(stepTexts(button), ["Low", "Med", "High"])
	}
	function headerButton(button) {
		return button.headerItem ? button.headerItem.children[0] : null
	}

	function stepChecked(button) {
		let checked = []
		for (let i = 0; i < button.count; ++i) {
			const delegate = button.itemAtIndex(i)
			let value = false
			for (const child of delegate.children) {
				if (child.checked !== undefined) {
					value = child.checked
				}
			}
			checked.push(value)
		}
		return checked
	}

	function test_exclusiveOff() {
		const button = createTemporaryObject(buttonComponent, root)
		verify(button)
		waitForRendering(button)
		button.currentIndex = 1

		// Legacy: the header is the On/Off toggle and the selected step stays highlighted while off
		compare(button.exclusive, false)
		button.checked = false
		compare(String(headerButton(button).text), CommonWords.off)
		compare(stepChecked(button), [false, true, false])
		button.checked = true
		compare(String(headerButton(button).text), CommonWords.on)

		// Named off state: single choice
		button.offText = "Standby"
		compare(button.exclusive, true)
		compare(String(headerButton(button).text), "Standby")
		compare(stepChecked(button), [false, true, false])
		button.checked = false
		compare(String(headerButton(button).text), "Standby")
		compare(stepChecked(button), [false, false, false])
		compare(headerButton(button).separatorVisible, false)
		compare(headerButton(button).backgroundColor, Theme.color_button_off_background)
		button.checked = true
		compare(headerButton(button).backgroundColor, Theme.color_darkBrand)
		button.checked = false

		// The off button is one of four equal segments, whatever its text: the visible widths
		// (background, without press margins and underlap) are all the same
		button.width = 4 * 100 + 2 * button.horizontalPressMargin + 2 * Theme.geometry_button_border_width
		compare(button._segmentWidth, 100)
		const visibleWidth = (item) => item.width - Math.max(0, item.leftInset) - Math.max(0, item.rightInset)
		compare(visibleWidth(headerButton(button)), 100)
		for (let i = 0; i < button.count; ++i) {
			compare(visibleWidth(button.itemAtIndex(i).children[0]), 100, "step " + i)
		}
		button.offText = "A very long name for the off state of this output"
		compare(visibleWidth(headerButton(button)), 100)
		compare(visibleWidth(button.itemAtIndex(0).children[0]), 100)

		// Without a custom off text the On/Off button keeps its text width
		button.offText = ""
		compare(visibleWidth(headerButton(button)), button._headerTextWidth)
	}

	function test_singleStepNoHeader() {
		const button = createTemporaryObject(segmentsComponent, root)
		verify(button)
		button.model = [ { text: 1 } ]
		waitForRendering(button)

		const only = button.itemAtIndex(0).children[0]
		// Rounded on both sides, nothing to underlap
		verify(only.topLeftRadius > 0)
		verify(only.topRightRadius > 0)
		compare(only.leftInset, button.horizontalPressMargin + Theme.geometry_button_border_width)
		compare(only.rightInset, button.horizontalPressMargin)
		compare(button.itemAtIndex(0).x + only.width - only.rightInset,
				button.width - button.horizontalPressMargin - Theme.geometry_button_border_width)
	}

	function test_labelsFitBoundary() {
		const button = createTemporaryObject(segmentsComponent, root)
		verify(button)
		waitForRendering(button)
		// Find a label whose width is right at the limit of a segment
		const available = button._stepWidth - 2 * Theme.geometry_button_padding
		let label = ""
		while (Math.ceil(metrics.advanceWidth(label + "M")) <= available) {
			label += "M"
		}
		verify(label.length > 0)
		button.labels = [label, "", ""]
		compare(button.labelsFit, true)
		button.labels = [label + "M", "", ""]
		compare(button.labelsFit, false)
	}

	FontMetrics {
		id: metrics
		font.family: Global.fontFamily
		font.pixelSize: Theme.font_size_body1
	}

	function test_exclusiveOffClicks() {
		const button = createTemporaryObject(buttonComponent, root)
		verify(button)
		waitForRendering(button)
		button.offText = "Standby"
		button.currentIndex = 1

		const offSpy = createTemporaryObject(spyComponent, root, { target: button, signalName: "offClicked" })
		const onSpy = createTemporaryObject(spyComponent, root, { target: button, signalName: "onClicked" })

		// Off and clicking the off button: nothing happens
		button.checked = false
		mouseClick(headerButton(button))
		compare(offSpy.count, 0)
		compare(onSpy.count, 0)

		// On and clicking the off button: switches off only
		button.checked = true
		mouseClick(headerButton(button))
		compare(offSpy.count, 1)
		compare(onSpy.count, 0)

		// Legacy toggle still switches on
		button.offText = ""
		button.checked = false
		mouseClick(headerButton(button))
		compare(onSpy.count, 1)
	}

	function test_pixelAlignedSteps() {
		const button = createTemporaryObject(buttonComponent, root)
		verify(button)
		button.offText = "Off"
		// A width that does not divide evenly over the three steps
		button.width = 701
		waitForRendering(button)

		// Buttons keep their slot width whatever their text, so a label the fit check lets
		// through can never push the following buttons off their pixels
		button.labels = ["Boost", "Boost", "Boost"]
		for (let i = 0; i < button.count; ++i) {
			const b = button.itemAtIndex(i).children[0]
			compare(b.width, b.defaultBackgroundWidth + Math.max(0, b.leftInset) + Math.max(0, b.rightInset))
		}

		// The antialiased last button starts one pixel under its (crisp) neighbour, which
		// paints on top of it; so does the On/Off header on its right
		const lastDelegate = button.itemAtIndex(button.count - 1)
		const previousDelegate = button.itemAtIndex(button.count - 2)
		compare(lastDelegate.children[0].leftInset, -1)
		compare(lastDelegate.children[0].leftPadding, 0)
		verify(previousDelegate.z > lastDelegate.z)
		compare(headerButton(button).rightInset, -1)
		verify(button.itemAtIndex(0).z > button.headerItem.z)

		let x = 0
		let total = 0
		for (let i = 0; i < button.count; ++i) {
			const delegate = button.itemAtIndex(i)
			verify(delegate)
			compare(delegate.x, Math.round(delegate.x), "step " + i + " starts on a whole pixel")
			if (i < button.count - 1) {
				compare(delegate.width, Math.round(delegate.width), "step " + i + " has a whole-pixel width")
			}
			x = delegate.x
			total += delegate.width
		}
		// The steps fill the space after the header exactly, press margin included
		compare(total, button._totalDelegateWidth)
	}

	Component {
		id: segmentsComponent

		MultiStepButton {
			width: 700
			showHeader: false
			checked: true
			model: [ { text: 1 }, { text: 2 }, { text: 3 } ]
		}
	}

	function test_noHeader() {
		const button = createTemporaryObject(segmentsComponent, root)
		verify(button)
		waitForRendering(button)
		compare(button.headerItem, null)

		button.labels = ["Low", "Mid", "High"]
		button.currentIndex = 1
		compare(button.labelsFit, true)
		compare(stepTexts(button), ["Low", "Mid", "High"])
		compare(stepChecked(button), [false, true, false])

		// The segments (press margins included in the first and last) fill the control up to
		// the right border, on whole pixels
		let total = 0
		for (let i = 0; i < button.count; ++i) {
			const delegate = button.itemAtIndex(i)
			compare(delegate.x, Math.round(delegate.x))
			total += delegate.width
		}
		compare(total, button.width - Theme.geometry_button_border_width)
		// ... so the backgrounds leave the border visible on both sides
		const firstButton = button.itemAtIndex(0).children[0]
		const lastItem = button.itemAtIndex(button.count - 1)
		compare(button.itemAtIndex(0).x + firstButton.leftInset, button.horizontalPressMargin + Theme.geometry_button_border_width)
		compare(lastItem.x + lastItem.children[0].width - lastItem.children[0].rightInset,
				button.width - button.horizontalPressMargin - Theme.geometry_button_border_width)

		// The first and last buttons carry the press margin and the rounded corners
		const first = button.itemAtIndex(0).children[0]
		const last = button.itemAtIndex(button.count - 1).children[0]
		compare(first.leftInset, button.horizontalPressMargin + Theme.geometry_button_border_width)
		verify(first.topLeftRadius > 0)
		// ... and, being antialiased, extends one pixel under the second button
		compare(first.rightInset, -1)
		compare(first.rightPadding, 0)
		verify(button.itemAtIndex(1).z > button.itemAtIndex(0).z)
		verify(button.itemAtIndex(1).z > button.itemAtIndex(button.count - 1).z)
		compare(last.rightInset, button.horizontalPressMargin)
		verify(last.topRightRadius > 0)
		compare(button.itemAtIndex(1).children[0].topLeftRadius, 0)

		// An off item is highlighted in the off colour, the others in the active colour
		compare(button.itemAtIndex(1).children[0].backgroundColor, Theme.color_brand)
		button.offIndex = 0
		button.currentIndex = 0
		compare(button.itemAtIndex(0).children[0].backgroundColor, Theme.color_button_off_background)
	}

	Component {
		id: spyComponent
		SignalSpy {}
	}

	Component {
		id: outputComponent
		SwitchableOutput {}
	}

	Component {
		id: dropdownCardComponent
		SwitchableOutputCardDelegate_6 {
			width: 400
		}
	}

	function test_dropdownCardKeepsSelectionOnModelRebuild() {
		const uid = "mock/com.victronenergy.test.a/SwitchableOutput/0"
		MockManager.setValue(uid + "/Settings/Type", VenusOS.SwitchableOutput_Type_Dropdown)
		MockManager.setValue(uid + "/Settings/Labels", ["Option 0", "Option 1", "Option 2", "Option 3", "Option 4"])
		MockManager.setValue(uid + "/Dimming", 3)

		const output = createTemporaryObject(outputComponent, root, { uid: uid })
		verify(output)
		const card = createTemporaryObject(dropdownCardComponent, root, { switchableOutput: output })
		verify(card)
		waitForRendering(card)

		let dropdown = null
		for (const child of card.children) {
			if (child instanceof ComboBox) {
				dropdown = child
			}
		}
		verify(dropdown, "dropdown not found")
		tryCompare(dropdown, "count", 5)
		compare(dropdown.currentIndex, 3)

		// Reserved labels are re-translated on a language change, which rebuilds the model.
		// The selection must still follow /Dimming afterwards.
		Language.currentLanguageChanged()
		compare(dropdown.count, 5)
		compare(dropdown.currentIndex, 3)

		// Likewise when the labels themselves change
		MockManager.setValue(uid + "/Settings/Labels", ["A", "B", "C", "D", "E"])
		compare(dropdown.count, 5)
		compare(dropdown.currentIndex, 3)

		MockManager.removeValue(uid)
	}
}
