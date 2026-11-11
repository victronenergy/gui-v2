/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A device that acts as an AC input.
*/
Device {
	required property AcInputInfo inputInfo

	// True if the input is considered operational (e.g. is currently active, or considered to be
	// always "on").
	required property bool operational

	// The connection status and service info, as provided by the inputInfo object.
	readonly property bool connected: inputInfo?.connected ?? false
	readonly property int source: inputInfo?.source ?? VenusOS.AcInputs_InputSource_NotAvailable

	// The overall quantity measurements for the AC input.
	required property real power
	required property real current

	// The per-phase data for the AC input.
	property PhaseModel phases

	// The uid where per-phase measurements are provided for this input, if available.
	property string measurementsUid
}
