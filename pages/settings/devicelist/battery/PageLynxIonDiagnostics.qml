/*
** Copyright (C) 2023 Victron Energy B.V.
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
				dataSource: root.bindPrefix + "/Diagnostics/ShutDownsDueError"
				visible: defaultVisible && dataValid
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
							error.value,
							errorTimestamp.valid ? Qt.formatDateTime(new Date(errorTimestamp.value * 1000), "yyyy-MM-dd hh:mm") : "--"
						]

						// TODO use this instead  when BMS error descriptions are available. See issue 302.
						// BmsError { id: errorValue }
						DataPoint {
							id: error
							source: root.bindPrefix + "/Diagnostics/LastErrors/" + (model.index + 1) + "/Error"
						}

						DataPoint {
							id: errorTimestamp
							source: root.bindPrefix + "/Diagnostics/LastErrors/" + (model.index + 1) + "/Time"
						}
					}
				}
			}
		}
	}
}
