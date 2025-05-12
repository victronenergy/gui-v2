/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string outputUid

	VeQuickItem {
		id: validTypesItem

		property var options: []

		uid: root.outputUid + "/Settings/ValidTypes"
		onValueChanged:{
			let op = []
			for (let i = 0; i < 8; i++) {
				if (value & (1 << i)) {
					op.push({ display: VenusOS.switchableOutput_typeToText(i), value: i })
				}
			}
			options = op
		}
	}

	GradientListView {
		model: VisibleItemModel {
			ListTextField {
				//% "Name"
				text: qsTrId("page_switchable_output_name")
				dataItem.uid: root.outputUid + "/Settings/CustomName"
				dataItem.invalidate: false
				textField.maximumLength: 32
				preferredVisible: dataItem.valid
				placeholderText: CommonWords.custom_name
			}

			ListTextField {
				//% "Group"
				text: qsTrId("page_switchable_output_group")
				dataItem.uid: root.outputUid + "/Settings/Group"
				dataItem.invalidate: false
				textField.maximumLength: 32
				preferredVisible: dataItem.valid
				placeholderText: text
			}

			ListRadioButtonGroup {
				//% "Type"
				text: qsTrId("page_switchable_output_type")
				dataItem.uid: root.outputUid + "/Settings/Type"
				preferredVisible: dataItem.valid
				optionModel: validTypesItem.options
			}

			ListSwitch {
				//: Whether UI controls should be shown for this output
				//% "Show controls"
				text: qsTrId("page_switchable_show_controls")
				dataItem.uid: root.outputUid + "/Settings/ShowUIControl"
				preferredVisible: dataItem.valid
			}

			ListSpinBox {
				//% "Fuse rating"
				text:  qsTrId("page_switchable_output_fuse_rating")
				dataItem.uid: root.outputUid + "/Settings/FuseRating"
				decimals: 0 // backend does not allow for decimal precision
				suffix: Units.defaultUnitString(VenusOS.Units_Amp)
				preferredVisible: dataItem.valid
			}
		}
	}
}
