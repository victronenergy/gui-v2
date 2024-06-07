/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

SwipeViewPage {
	id: root

	//% "Log Out"
	navButtonText: qsTrId("nav_logout")
	navButtonIcon: "qrc:/images/logout.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/LogoutPage.qml"
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive

	onIsCurrentPageChanged: if (isCurrentPage) BackendConnection.logout()
}
