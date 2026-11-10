/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest
import Victron.VenusOS
import Victron.GuiPlugins

TestCase {
	id: root

	name: "PluginLabelTest"

	Component {
		id: labelComponent

		PluginLabel {}
	}

	Component {
		id: quantityComponent

		PluginQuantityLabel {}
	}

	// The inner label is the wrapper's only child item.
	function innerLabel(wrapper) {
		return wrapper.children[0]
	}

	// fontSize is the pixel size of the text, and is PluginPalette.font_size_medium by default.
	function test_fontSizes_data() {
		return [
			{ tag: "label default", component: labelComponent, properties: {}, pixelSize: PluginPalette.font_size_medium },
			{ tag: "label large", component: labelComponent, properties: { fontSize: PluginPalette.font_size_large }, pixelSize: PluginPalette.font_size_large },
			{ tag: "quantity default", component: quantityComponent, properties: {}, pixelSize: PluginPalette.font_size_medium },
			{ tag: "quantity small", component: quantityComponent, properties: { fontSize: PluginPalette.font_size_small }, pixelSize: PluginPalette.font_size_small },
		]
	}

	function test_fontSizes(data) {
		const label = createTemporaryObject(data.component, root, data.properties)
		verify(label !== null)
		compare(innerLabel(label).font.pixelSize, data.pixelSize)
	}

	function test_largerFontSizeIsTaller() {
		const small = createTemporaryObject(labelComponent, root, { text: "Hello", fontSize: PluginPalette.font_size_small })
		const large = createTemporaryObject(labelComponent, root, { text: "Hello", fontSize: PluginPalette.font_size_large })
		verify(small !== null && large !== null)
		verify(large.implicitHeight > small.implicitHeight,
				"large " + large.implicitHeight + ", small " + small.implicitHeight)
		verify(large.implicitWidth > small.implicitWidth)
	}

	function test_labelWrapsWhenItsWidthIsSet() {
		const text = "This text is far too long to fit on one line of a narrow label"
		const oneLine = createTemporaryObject(labelComponent, root, { text: text })
		const wrapped = createTemporaryObject(labelComponent, root, { text: text, width: 60, wrapMode: Text.Wrap })
		verify(oneLine !== null && wrapped !== null)
		verify(oneLine.implicitWidth > 60)
		verify(wrapped.implicitHeight > oneLine.implicitHeight,
				"wrapped " + wrapped.implicitHeight + ", one line " + oneLine.implicitHeight)
		compare(wrapped.width, 60)
	}

	// The labels show the new units with the GUI's own unit text and default decimals.
	function test_quantityUnits_data() {
		return [
			{ tag: "Hertz", unit: PluginUnit.Hertz, value: 50, decimals: 0, valueText: "50", unitText: "Hz" },
			{ tag: "Time_Hour", unit: PluginUnit.Time_Hour, value: 5, decimals: -1, valueText: "5", unitText: "h" },
			{ tag: "PowerFactor", unit: PluginUnit.PowerFactor, value: 0.95, decimals: -1, valueText: "0.950", unitText: "" },
			{ tag: "WattsPerSquareMetre", unit: PluginUnit.WattsPerSquareMetre, value: 850, decimals: -1, valueText: "850", unitText: "W/m\u00b2" },
		]
	}

	function test_quantityUnits(data) {
		const label = createTemporaryObject(quantityComponent, root,
				{ value: data.value, unit: data.unit, decimals: data.decimals })
		verify(label !== null)
		compare(innerLabel(label).valueText, data.valueText)
		compare(innerLabel(label).unitText, data.unitText)
	}

	function test_quantityShowsDashesForNotANumber() {
		const label = createTemporaryObject(quantityComponent, root, { value: NaN, unit: PluginUnit.Watt })
		verify(label !== null)
		compare(innerLabel(label).valueText, "--")
		// With no dataItem uid, the value is that of the invalid dataItem: not a number.
		const unset = createTemporaryObject(quantityComponent, root, { unit: PluginUnit.Watt })
		verify(unset !== null)
		verify(isNaN(unset.value))
		compare(innerLabel(unset).valueText, "--")
	}

	// The number and unit are placed by horizontalAlignment and verticalAlignment, in a label
	// that is bigger than its text.
	function test_quantityAlignment_data() {
		return [
			{ tag: "default: top left", properties: {}, x: "left", y: "top" },
			{ tag: "right, bottom", properties: { horizontalAlignment: Text.AlignRight, verticalAlignment: Text.AlignBottom }, x: "right", y: "bottom" },
			{ tag: "centered", properties: { horizontalAlignment: Text.AlignHCenter, verticalAlignment: Text.AlignVCenter }, x: "center", y: "center" },
			{ tag: "right, top", properties: { horizontalAlignment: Text.AlignRight, verticalAlignment: Text.AlignTop }, x: "right", y: "top" },
		]
	}

	function test_quantityAlignment(data) {
		const properties = Object.assign({ value: 230, unit: PluginUnit.Volt_AC, width: 300, height: 100 }, data.properties)
		const label = createTemporaryObject(quantityComponent, root, properties)
		verify(label !== null)
		// The row of the number and the unit is the inner label's only child item.
		const row = innerLabel(label).children[0]
		verify(row.width > 0 && row.width < 300)
		verify(row.height > 0 && row.height < 100)

		if (data.x === "left") {
			compare(row.x, 0)
		} else if (data.x === "right") {
			compare(row.x + row.width, 300)
		} else {
			fuzzyCompare(row.x, (300 - row.width) / 2, 1)
		}

		if (data.y === "top") {
			compare(row.y, 0)
		} else if (data.y === "bottom") {
			compare(row.y + row.height, 100)
		} else {
			fuzzyCompare(row.y, (100 - row.height) / 2, 1)
		}
	}
}
