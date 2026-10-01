/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Instantiator {
	id: root

	property bool hasVisibleItem

	// Instantiator's default property is delegate; do not add child Connections.
	property var _containingPage

	function _detachModel() { root.model = null }

	// Connect synchronously: forceCompletion then aboutToBeDiscarded share a stack.
	// Instantiator has no QML parent; walk QObject parents to the Page.
	function _updateContainingPage() {
		const page = FastUtils.containingPage(root)
		if (_containingPage === page) {
			return
		}
		if (_containingPage) {
			_containingPage.aboutToBeDiscarded.disconnect(_detachModel)
		}
		_containingPage = page
		if (_containingPage) {
			_containingPage.aboutToBeDiscarded.connect(_detachModel)
		}
	}

	function _hasVisibleItem() {
		for (let i = 0; i < count; ++i) {
			const obj = objectAt(i)
			if (!!obj && obj.visible) {
				return true
			}
		}
		return false
	}

	delegate: Connections {
		target: modelData
		function onVisibleChanged() {
			root.hasVisibleItem = !!modelData && (modelData.visible || root._hasVisibleItem())
		}
	}

	Component.onCompleted: {
		_updateContainingPage()
		root.hasVisibleItem = root._hasVisibleItem()
	}
}
