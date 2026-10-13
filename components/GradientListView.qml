/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseListView {
	id: root

	bottomMargin: Theme.geometry_size_16

	ScrollBar.vertical: ScrollBar {
		topPadding: Theme.geometry_size_6
		bottomPadding: Theme.geometry_size_16
	}

	ViewGradient {
		anchors.bottom: root.bottom

		// In case the VKB area is partially transparent (e.g. on iOS with Wasm), hide the gradient
		// when the VKB is visible, to avoid showing a floating gradient above the VKB.
		visible: !Theme.virtualKeyboardOpened
	}
}
