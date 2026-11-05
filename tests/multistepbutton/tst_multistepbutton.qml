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
}
