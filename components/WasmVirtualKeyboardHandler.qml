/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Handles the case where a text field is focused when running on Wasm, causing the native virtual
	keyboard (not the Qt virtual keyboard, as defined by InputPanel.qml) to appear. When this
	happens in landscape orientation, the view needs to move upwards or be scrolled upwards, so
	that the focused field is not obscured by the native VKB.
*/
KeyboardInputScroller {
	id: root
}
