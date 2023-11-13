/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property alias bindPrefix: dcMeterMode.bindPrefix
	property alias serviceType: dcMeterMode.serviceType

	GradientListView {
		model: PageDcMeterModel {
			id: dcMeterMode
		}
	}
}
