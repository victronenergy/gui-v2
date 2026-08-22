/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseListView {
	id: root

	bottomMargin: Theme.geometry_gradientList_bottomMargin

	ScrollBar.vertical: ScrollBar {
		topPadding: Theme.geometry_gradientList_topMargin
		bottomPadding: Theme.geometry_gradientList_bottomMargin
	}

	Binding {
		when: root.parent?.__is_venus_gui_page__ === true
		target: root.parent
		property: "showTopGradient"
		value: !root.atYBeginning
	}
	Binding {
		when: root.parent?.__is_venus_gui_page__ === true
		target: root.parent
		property: "showBottomGradient"
		value: !root.atYEnd
	}
}
