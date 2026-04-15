/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

BaseListView {
	id: root

	required property bool animationEnabled

	orientation: Theme.screenSize === Theme.Portrait ? ListView.Vertical : ListView.Horizontal
	spacing: Theme.screenSize === Theme.Portrait ? Theme.geometry_levelsPage_gauge_spacing_tiny : Gauges.spacing(count)
	delegate: TankGaugePanel {
		id: tankDelegate

		required property Tank device

		width: root.orientation === ListView.Vertical
			   ? ListView.view.width
			   : Gauges.width(root.model.count, Theme.geometry_levelsPage_max_tank_count, Theme.geometry_screen_width)
		height: root.orientation === ListView.Vertical
			   ? implicitHeight
			   : ListView.view.height
		animationEnabled: root.animationEnabled
		tank: device
		tankModel: null
		isGroup: false
	}
}
