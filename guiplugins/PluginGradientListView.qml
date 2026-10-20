/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQml.Models
import Victron.VenusOS

/*
	A scrolling list of rows, which fills its parent.

	Declare the rows directly inside it, for example:

		PluginGradientListView {
			PluginListSwitch { text: "Enabled" }
			PluginListNavigation { text: "Advanced"; pageUrl: Qt.resolvedUrl("AdvancedPage.qml") }
		}

	The rows are fixed when the list is created. To hide a row, set its preferredVisible to false:
	the row then takes no space, and key navigation skips it. Do not set 'visible' on a row.
*/
FocusScope {
	id: root

	// The rows of the list, in order. Each one is a Plugin* row, such as PluginListSwitch.
	default property list<PluginListRow> rows

	width: parent?.width ?? 0
	height: parent?.height ?? 0
	focus: true

	GradientListView {
		id: listView

		model: ObjectModel {
			id: rowModel
		}
	}

	Component.onCompleted: {
		// Fill the model once, when every row exists. The model is not bound to 'rows', as the
		// rows are fixed when the list is created.
		for (let i = 0; i < root.rows.length; ++i) {
			rowModel.append(root.rows[i])
		}
	}
}
