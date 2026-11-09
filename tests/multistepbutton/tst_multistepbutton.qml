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

		// The off button is one of four equal segments, whatever its text
		compare(headerButton(button).defaultBackgroundWidth, button._segmentWidth)
		compare(button.itemAtIndex(0).width, button._segmentWidth)
		button.offText = "A very long name for the off state of this output"
		compare(headerButton(button).defaultBackgroundWidth, button._segmentWidth)
		compare(button.itemAtIndex(0).width, button._segmentWidth)
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
		id: spyComponent
		SignalSpy {}
	}
}
