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
		model: VisibleItemModel {
			ListText {
				//% "Shutdowns due error"
				text: qsTrId("lynxiondiagnostics_shutdowns_due_error")
				dataItem.uid: root.bindPrefix + "/Diagnostics/ShutDownsDueError"
				preferredVisible: dataItem.valid
			}

			SettingsColumn {
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

					delegate: ListQuantityGroup {
						id: errorDelegate

						required property int index
						required property var modelData
						readonly property string bindPrefix: `${root.bindPrefix}/Diagnostics/LastErrors/${index + 1}`

						text: modelData
						model: QuantityObjectModel {
							QuantityObject { object: error; key: "textValue" }
							QuantityObject { object: errorTimestamp; key: "textValue" }
						}

						VeQuickItem {
							id: error
							readonly property string textValue: valid ? BmsError.description(value) : invalidText
							uid: errorDelegate.bindPrefix + "/Error"
						}

						VeQuickItem {
							id: errorTimestamp
							readonly property string textValue: valid ? Qt.formatDateTime(new Date(value * 1000), "yyyy-MM-dd hh:mm") : "--"
							uid: errorDelegate.bindPrefix + "/Time"
						}
					}
				}
			}
		}
	}
}
