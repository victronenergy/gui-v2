/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Instantiator {
	id: root

	property bool hasVisibleItem

	function _hasVisibleItem() {
		for (let i = 0; i < count; ++i) {
			const obj = objectAt(i);
			if (!!obj && obj.visible) {
				return true;
			}
		}
		return false;
	}

	delegate: Connections {
		target: modelData
		function onVisibleChanged() {
			root.hasVisibleItem = !!modelData && (modelData.visible || root._hasVisibleItem());
		}
	}

	Component.onCompleted: {
		root.hasVisibleItem = root._hasVisibleItem();
	}
}
