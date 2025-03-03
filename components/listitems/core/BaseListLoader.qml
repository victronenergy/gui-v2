/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A convenience base type for loaders of list items, with key navigation support.

	See BaseListItem for information regarding preferredVisible and effectiveVisible.
*/
Loader {
	property bool preferredVisible: active
	readonly property bool effectiveVisible: preferredVisible && status === Loader.Ready

	// Allow item to receive focus within its focus scope.
	focus: true

	// Allow Utils.acceptsKeyNavigation() to accept moving focus to this item.
	// TODO from Qt 6.7 can change this to set focusPolicy instead.
	activeFocusOnTab: true
}
