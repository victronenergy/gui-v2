/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	The metadata required for an AC input.
*/
QtObject {
	// True if the metadata is valid.
	required property bool valid

	// True if the input is considered to be connected.
	required property bool connected

	// The device instance of the input on its service.
	required property int deviceInstance

	// The service type of the device, e.g. "vebus".
	required property string serviceType

	// A VenusOS.AcInputs_InputSource value indicating the type of the input source
	required property int source

	// The minimum and maximum current values for the AC input.
	property real minimumCurrent: NaN
	property real maximumCurrent: NaN
}
