/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import QtTest
import Victron.VenusOS

TestCase {
	id: root

	name: "NativeContent"
	width: 800
	height: 480
	when: windowShown

	property int originalScreenSize
	property int originalColorScheme
	property Item container

	function init() {
		originalScreenSize = Theme.screenSize
		originalColorScheme = Theme.colorScheme
		container = createTemporaryObject(containerComponent, root)
	}

	function cleanup() {
		container.destroy()
		wait(0)
		Theme.screenSize = originalScreenSize
		Theme.colorScheme = originalColorScheme
	}

	function near(actual, expected, description) {
		fuzzyCompare(actual, expected, 0.01, description)
	}

	function compareItem(actual, expected, description) {
		for (const property of ["x", "y", "width", "height", "implicitWidth", "implicitHeight", "baselineOffset"]) {
			near(actual[property], expected[property], description + "." + property)
		}
	}

	function test_quantityGeometry_data() {
		const rows = []
		for (const size of [12, 19, 28, 60]) {
			for (const alignment of [Qt.AlignHCenter | Qt.AlignVCenter, Qt.AlignLeft,
					Qt.AlignRight | Qt.AlignBottom, Qt.AlignLeft | Qt.AlignVCenter]) {
				for (const unitText of ["V", "", "%", "kWh"]) {
					rows.push({tag: size + "-" + alignment + "-" + unitText,
						pixelSize: size, alignment: alignment, unitText: unitText})
				}
			}
		}
		return rows
	}

	function test_quantityGeometry(data) {
		const actual = createTemporaryObject(quantityComponent, container, {
			width: 301, height: 83, valueText: "123.4", unitText: data.unitText,
			alignment: data.alignment, leftPadding: 7, rightPadding: 11
		})
		verify(actual)
		actual.font.pixelSize = data.pixelSize
		const expected = createTemporaryObject(quantityReference, container, {
			width: actual.width, height: actual.height, valueText: actual.valueText,
			unitText: actual.unitText, alignment: actual.alignment,
			leftPadding: actual.leftPadding, rightPadding: actual.rightPadding,
			font: actual.font
		})
		verify(expected)
		verify(waitForPolish(root.Window.window))
		compareItem(actual, expected, "quantity")
		compareItem(actual._digitRow, expected.row, "row")
		compareItem(actual._valueLabel, expected.valueLabel, "value")
		compareItem(actual._unitLabel, expected.unitLabel, "unit")

		actual.font.weight = Font.Bold
		actual.font.italic = true
		expected.font = actual.font
		actual.valueText = expected.valueText = ""
		verify(waitForPolish(root.Window.window))
		compareItem(actual, expected, "empty value")
		compareItem(actual._valueLabel, expected.valueLabel, "bold value")
		compareItem(actual._unitLabel, expected.unitLabel, "italic unit")
		compare(actual._valueLabel.font.family, Global.quantityFontFamily)
		compare(actual._valueLabel.font.italic, expected.valueLabel.font.italic)
	}

	function test_quantityAliases() {
		const quantity = createTemporaryObject(quantityComponent, container)
		verify(quantity)
		quantity.value = 14.2
		quantity.decimals = 1
		compare(quantity.quantityInfo.value, 14.2)
		compare(quantity.quantityInfo.decimals, 1)
		compare(quantity.valueText, quantity.quantityInfo.number)
		quantity.valueText = "override"
		quantity.unitText = "custom"
		quantity.value = 25
		compare(quantity.valueText, "override")
		compare(quantity.unitText, "custom")
		quantity.valueColor = "red"
		quantity.unitColor = "blue"
		compare(quantity._valueLabel.color, Qt.color("red"))
		compare(quantity._unitLabel.color, Qt.color("blue"))
		quantity.quantityInfo.unitMatchValue = 10000
		compare(quantity.quantityInfo.unitMatchValue, 10000)
	}

	function test_liveThemeAndFont() {
		const quantity = createTemporaryObject(quantityComponent, container)
		for (const screen of [Theme.FiveInch, Theme.SevenInch, Theme.Portrait]) {
			Theme.screenSize = screen
			compare(quantity.font.pixelSize, Theme.font_size_body1)
			compare(quantity._valueLabel.font.pixelSize, Theme.font_size_body1)
		}
		for (const scheme of [Theme.Light, Theme.Dark]) {
			Theme.colorScheme = scheme
			compare(quantity.valueColor, Theme.color_font_primary)
			compare(quantity.unitColor, Theme.color_font_secondary)
		}
		quantity.font.family = "serif"
		quantity.valueFontFamily = "monospace"
		compare(quantity._unitLabel.font.family, "serif")
		compare(quantity._valueLabel.font.family, "monospace")
	}

	function test_inheritedFonts() {
		const control = createTemporaryObject(controlComponent, container)
		const actual = createTemporaryObject(quantityComponent, control, {valueText: "123", unitText: "V"})
		const expected = createTemporaryObject(quantityReference, control, {valueText: "123", unitText: "V"})
		for (const italic of [true, false]) {
			control.font.italic = italic
			control.font.weight = italic ? Font.Bold : Font.Normal
			verify(waitForPolish(root.Window.window))
			compare(actual.font, expected.font)
			compare(actual._valueLabel.font, expected.valueLabel.font)
			compareItem(actual, expected, "inherited quantity")
		}
	}

	Component {
		id: containerComponent
		Item {}
	}

	Component {
		id: controlComponent
		T.Control {}
	}

	Component {
		id: quantityComponent
		QuantityLabel {}
	}

	// Keep the former QML geometry as a reference for the native construction path.
	Component {
		id: quantityReference
		Item {
			id: quantity
			property string valueText
			property string unitText
			property alias font: unit.font
			property int alignment: Qt.AlignHCenter | Qt.AlignVCenter
			property alias leftPadding: digits.leftPadding
			property alias rightPadding: digits.rightPadding
			property alias row: digits
			property alias valueLabel: value
			property alias unitLabel: unit
			implicitWidth: digits.width
			implicitHeight: digits.height
			Row {
				id: digits
				anchors.verticalCenter: quantity.alignment & Qt.AlignVCenter ? parent.verticalCenter : undefined
				anchors.horizontalCenter: quantity.alignment & Qt.AlignHCenter ? parent.horizontalCenter : undefined
				anchors.left: quantity.alignment & Qt.AlignLeft ? parent.left : undefined
				anchors.right: quantity.alignment & Qt.AlignRight ? parent.right : undefined
				anchors.bottom: quantity.alignment & Qt.AlignBottom ? parent.bottom : undefined
				spacing: Theme.geometry_quantityLabel_spacing
				T.Label {
					id: value
					text: quantity.valueText
					font.family: Global.quantityFontFamily
					font.pixelSize: quantity.font.pixelSize
					font.weight: quantity.font.weight
				}
				T.Label {
					id: unit
					text: quantity.unitText
					font.family: Global.fontFamily
					font.pixelSize: Theme.font_size_body1
					anchors.baseline: value.baseline
					anchors.alignWhenCentered: font.pixelSize >= Theme.font_size_body1
				}
			}
		}
	}
}
