/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListRadioButtonGroup {
	id: root

	required property IOChannel ioChannel

	//% "Type"
	text: qsTrId("iochannel_type_buttongroup_type")
	dataItem.uid: root.ioChannel.uid + "/Settings/Type"
	preferredVisible: dataItem.valid
	secondaryLabel.color: root.ioChannel.hasValidType ? Theme.color_listItem_secondaryText : Theme.color_critical
	optionModel: {
		let options = []
		const maxType = root.ioChannel.direction === IOChannel.Input
				? VenusOS.GenericInput_Type_MaxSupportedType
				: VenusOS.SwitchableOutput_Type_MaxSupportedType
		for (let i = 0; i <= maxType; i++) {
			if (root.ioChannel.validTypes & (1 << i)) {
				options.push({
					display: root.ioChannel.direction === IOChannel.Input
							? VenusOS.genericInput_typeToText(i)
							: VenusOS.switchableOutput_typeToText(i, root.ioChannel.channelId),
					value: i
				})
			}
		}
		return options
	}
	interactive: optionModel.length > 1 || !root.ioChannel.hasValidType

	// Set the fallback text explicitly, in case the input/output Type is not supported by its
	// ValidTypes, which means the current Type is not one of the listed options and
	// thus cannot be displayed by ListRadioButtonGroup.
	defaultSecondaryText: root.ioChannel.direction === IOChannel.Input
			? VenusOS.genericInput_typeToText(root.ioChannel.type)
			: VenusOS.switchableOutput_typeToText(root.ioChannel.type, root.ioChannel.channelId)
}
