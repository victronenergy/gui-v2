/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property alias bindPrefix: dcMeterMode.bindPrefix

	GradientListView {
		model: PageDcMeterModel {
			id: dcMeterMode
		}
	}
}
