/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListText {
	id: root

	preferredVisible: dataItem.valid
	text: CommonWords.error
	secondaryText: {
		switch (dataItem.value) {
		case VenusOS.Genset_ErrorCode_NoError: return CommonWords.formatError(CommonWords.no_error,
																			  VenusOS.Genset_ErrorCode_NoError)
		//% "Remote switch control disabled"
		case VenusOS.Genset_ErrorCode_RemoteSwitchControlDisabled: return CommonWords.formatError(qsTrId("list_generator_error_remote_switch_control_disabled"),
																								  VenusOS.Genset_ErrorCode_RemoteSwitchControlDisabled)
		//% "Generator in fault condition"
		case VenusOS.Genset_ErrorCode_GeneratorInFaultCondition: return CommonWords.formatError(qsTrId("list_generator_error_generator_in_fault_condition"),
																								VenusOS.Genset_ErrorCode_GeneratorInFaultCondition)
		//% "Generator not detected at AC input"
		case VenusOS.Genset_ErrorCode_GeneratorNotDetectedAtAcInput: return CommonWords.formatError(qsTrId("list_generator_error_generator_not_detected"),
																									VenusOS.Genset_ErrorCode_GeneratorNotDetectedAtAcInput)
		//% "Custom enabled gensets group is empty"
		case VenusOS.Genset_ErrorCode_EmptyCustomEnabledGensetsGroup: return CommonWords.formatError(qsTrId("list_generator_error_empty_group"),
																									 VenusOS.Genset_ErrorCode_EmptyCustomEnabledGensetsGroup)

		default: return ""
		}
	}
}
