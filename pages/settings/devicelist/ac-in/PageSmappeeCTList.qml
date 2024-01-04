/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

Page {
	id: root

	property string bindPrefix

	title: CommonWords.current_transformers

	GradientListView {
		model: VeQItemTableModel {
			uids: [ root.bindPrefix + "/CT" ]
			flags: VeQItemTableModel.AddChildren
				   | VeQItemTableModel.AddNonLeaves
				   | VeQItemTableModel.DontAddItem
		}

		delegate: ListNavigationItem {
			id: menu

			readonly property int ctIndex: model.id

			//: %1 = device number, %2 = device type
			//% "%1: %2"
			text: qsTrId("smappee_ct_list_type").arg(ctIndex + 1).arg(typeLookup.typeName)
			secondaryText: phase.value === undefined ? "" : "L%1".arg(phase.value + 1)
			visible: type.isValid
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageSmappeeCTSetup.qml",
						{ "bindPrefix": root.bindPrefix, ctIndex: menu.ctIndex })
			}

			VeQuickItem {
				id: type
				uid: model.uid + "/Type"
			}

			VeQuickItem {
				id: phase
				uid: model.uid + "/Phase"
			}

			VeQuickItem {
				id: typeLookup

				property string typeName

				uid: type.value === undefined ? "" : root.bindPrefix + "/CTTypes"

				onValueChanged: {
					if (isNaN(type.value)) {
						typeName = ""
						return
					}
					const typeModel = Utils.jsonSettingsToModel(value, true)
					const match = typeModel.find(function(obj) { return obj.value === type.value })
					typeName = match ? match.display : ""
				}
			}
		}
	}
}
