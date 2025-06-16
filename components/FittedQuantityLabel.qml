/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QuantityLabel {
	id: root

	property int minimumPixelSize: -1
	property int maximumPixelSize: -1

	readonly property real _maximumWidth: width - Theme.geometry_quantityLabel_spacing
	readonly property string _combinedText: valueText + unitText

	on_MaximumWidthChanged: Qt.callLater(_calculateFontFitting)
	on_CombinedTextChanged: Qt.callLater(_calculateFontFitting)
	onVisibleChanged:       Qt.callLater(_calculateFontFitting)

	function _calculateFontFitting() {
		if (root.visible) {
			root.font.pixelSize = FastUtils.fittedPixelSize(root._combinedText, root._maximumWidth, root.minimumPixelSize, root.maximumPixelSize, root.font, Theme)
		}
	}
}
