/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root
	anchors.fill: parent

	property ModalWarningDialog warningNotification: ModalWarningDialog {}
	property ESSMinimumSOCDialog essMinimumSOCDialog: ESSMinimumSOCDialog {}
	property InputCurrentLimitDialog inputCurrentLimitDialog: InputCurrentLimitDialog {}
	property InverterChargerModeDialog inverterChargerModeDialog: InverterChargerModeDialog {}
	property GeneratorDisableAutostartDialog generatorDisableAutostartDialog: GeneratorDisableAutostartDialog {}
	property GeneratorDurationSelectorDialog generatorDurationSelectorDialog: GeneratorDurationSelectorDialog {}

	function showWarning(title, description) {
		warningNotification.title = title
		warningNotification.description = description
		warningNotification.open()
	}
}
