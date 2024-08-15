/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

NumberSelectorDialog {
	id: root

	property int productId

	/* - Mask the Product id with `0xFF00`
	 * - If the result is `0x1900` or `0x2600` it is an EU model (230VAC)
	 * - If the result is `0x2000` or `0x2700` it is an US model (120VAC)
	 */
	readonly property int _productUpperByte: productId > 0 ? productId / 0x100 : 0

	function _euAmpOptions() {
		return [ 3.0, 6.0, 10.0, 13.0, 16.0, 25.0, 32.0, 63.0 ].map(function(v) { return { value: v } })
	}

	function _usAmpOptions() {
		return [ 10.0, 15.0, 20.0, 30.0, 50.0, 100.0 ].map(function(v) { return { value: v } })
	}

	title: CommonWords.input_current_limit
	suffix: Units.defaultUnitString(VenusOS.Units_Amp)
	stepSize: 0.1
	to: 1000
	decimals: 1

	// Show the correct amp presets depending on whether this is an EU or US product.
	presets: _productUpperByte === 0x19 || _productUpperByte === 0x26
			 ? _euAmpOptions()
			 : (_productUpperByte === 0x20 || _productUpperByte === 0x27 ? _usAmpOptions() : [])
}
