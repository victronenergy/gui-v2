/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListTextItem {
				//% "Shutdowns due error"
				text: qsTrId("lynxiondiagnostics_shutdowns_due_error")
				dataItem.uid: root.bindPrefix + "/Diagnostics/ShutDownsDueError"
				visible: defaultVisible && dataItem.isValid
			}

			Column {
				width: parent ? parent.width : 0

				Repeater {
					model: [
						//% "Last error"
						qsTrId("lynxiondiagnostics_last_error"),
						//% "2nd last error"
						qsTrId("lynxiondiagnostics_2nd_last_error"),
						//% "3rd last error"
						qsTrId("lynxiondiagnostics_3rd_last_error"),
						//% "4th last error"
						qsTrId("lynxiondiagnostics_4th_last_error"),
					]

					delegate: ListTextGroup {
						text: modelData
						textModel: [
							error.isValid ? BmsError.description(error.value) : error.invalidText,
							errorTimestamp.isValid ? Qt.formatDateTime(new Date(errorTimestamp.value * 1000), "yyyy-MM-dd hh:mm") : "--"
						]

						VeQuickItem {
							id: error
							uid: root.bindPrefix + "/Diagnostics/LastErrors/" + (model.index + 1) + "/Error"
						}

						VeQuickItem {
							id: errorTimestamp
							uid: root.bindPrefix + "/Diagnostics/LastErrors/" + (model.index + 1) + "/Time"
						}
					}
				}
			}
		}
	}
}
