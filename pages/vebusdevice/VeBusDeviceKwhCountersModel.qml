/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml
import Victron.VenusOS

ListModel {
	// none of the following text is translated in gui-v1
	ListElement {displayText: "AC-IN1 to Inverter";			pathSuffix: "/AcIn1ToInverter"}
	ListElement {displayText: "AC-IN2 to Inverter";			pathSuffix: "/AcIn2ToInverter"}
	ListElement {displayText: "AC-IN1 to AC-OUT";			pathSuffix: "/AcIn1ToAcOut"}
	ListElement {displayText: "AC-IN2 to AC-OUT";			pathSuffix: "/AcIn2ToAcOut"}
	ListElement {displayText: "Inverter to AC-IN1";			pathSuffix: "/InverterToAcIn1"}
	ListElement {displayText: "Inverter to AC-IN2";			pathSuffix: "/InverterToAcIn2"}
	ListElement {displayText: "AC-OUT to AC-IN1";			pathSuffix: "/AcOutToAcIn1"}
	ListElement {displayText: "AC-OUT to AC-IN2";			pathSuffix: "/AcOutToAcIn2"}
	ListElement {displayText: "Inverter to AC-OUT";			pathSuffix: "/InverterToAcOut"}
	ListElement {displayText: "AC-OUT to Inverter";			pathSuffix: "/OutToInverter"}
}
