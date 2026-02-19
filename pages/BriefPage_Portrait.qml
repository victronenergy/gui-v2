/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

SwipeViewPage {
	id: root

	navButtonText: CommonWords.brief_page
	navButtonIcon: "qrc:/images/brief.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/BriefPage.qml"
	backgroundColor: Theme.color_briefPage_background
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
}
