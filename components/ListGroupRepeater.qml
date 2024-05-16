/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

Repeater {
	id: root

	property bool allowed: true
	property ListGroupMetrics _metrics

	onAllowedChanged: root._initialize()
	onWindowChanged: function (window) { if (window) _initialize() }
	Component.onCompleted: _initialize()

	function update() {
		if (_metrics) {
			_metrics.update(root)
		}
	}

	function _initialize() {
		if (allowed) {
			if (!_metrics) {
				var p = parent
				while (p) {
					if (p.hasOwnProperty("_gradient_list_view")) {
						_metrics = p._listGroupMetrics
						_metrics.updated.connect(_updated)
						break
					}
					p = p.parent
				}

				if (_metrics) {
					_metrics.update(root)
				}
			}
		} else if (_metrics) {
			_metrics.remove(root)
			_metrics = null
		}
	}

	function _updated(columnWidths) {
		var offset = 0
		for (var i = 1; i <= count; i++) {
			const item = itemAt(count - i)
			if (item && i <= columnWidths.length) {
				if (item.showValue !== undefined && !item.showValue) {
					offset = offset + 1
					continue
				}
				item.columnWidth = columnWidths[columnWidths.length - i + offset]
			}
		}
	}
}
