/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListQuantityGroupNavigation {
	id: root

	required property string uid
	required property string name

	text: name
	quantityModel: QuantityObjectModel {
		// If Status=On, show the /Value. Otherwise, show the status text (On, Off, Fault, etc.)
		QuantityObject {
			object: input.status === VenusOS.GenericInput_Status_On ? valueItem : input
			key: input.status === VenusOS.GenericInput_Status_On ? "value" : "statusText"
			unit: input.status === VenusOS.GenericInput_Status_On ? input.unitType : VenusOS.Units_None
			decimals: input.decimals
		}
		QuantityObject {
			object: input
			key: "typeText"
			// If input is valid, set undefined to indicate the default color should be used.
			valueColor: input.hasValidType ? undefined : Theme.color_critical
		}
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/iochannel/PageGenericInput.qml", {
			genericInput: input,
			title: Qt.binding(function() { return root.text })
		})
	}

	VeQuickItem {
		id: valueItem
		uid: root.uid + "/Value"
		sourceUnit: Units.unitToVeUnit(input.unitType)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.toPreferredUnit(input.unitType))
	}

	GenericInput {
		id: input

		readonly property string statusText: VenusOS.genericInput_statusToText(status)
		readonly property string typeText: VenusOS.genericInput_typeToText(type)

		uid: root.uid
	}
}
