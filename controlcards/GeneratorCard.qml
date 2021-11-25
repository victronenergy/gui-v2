/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	icon.source: "qrc:/images/generator.svg"
	//% "Generator"
	title.text: qsTrId("controlcard_generator")

	//% "Stopped"
	status.text: qsTrId("controlcard_stopped")
}
