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
				preferredVisible: dataItem.isValid
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

					delegate: ListQuantityGroup {
						text: modelData
						model: QuantityObjectModel {
							QuantityObject { object: error; key: "textValue" }
							QuantityObject { object: errorTimestamp; key: "textValue" }
						}

						VeQuickItem {
							id: error
							readonly property string textValue: isValid ? BmsError.description(value) : invalidText
							uid: root.bindPrefix + "/Diagnostics/LastErrors/" + (model.index + 1) + "/Error"
						}

						VeQuickItem {
							id: errorTimestamp
							readonly property string textValue: isValid ? Qt.formatDateTime(new Date(value * 1000), "yyyy-MM-dd hh:mm") : "--"
							uid: root.bindPrefix + "/Diagnostics/LastErrors/" + (model.index + 1) + "/Time"
						}
					}
				}
			}
		}
	}
}
