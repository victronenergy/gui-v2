/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

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

	function showToastNotification(category, text) {
		var toast = toaster.createObject(this, { "category": category, "text": text })
		root._toastNotifications.push(toast)
		Utils.reactToSignalOnce(toast.dismissed, function() {
			var lastToast = root._toastNotifications.pop()
			lastToast.destroy()
		})
	}

	property var _toastNotifications: []
	Component {
		id: toaster
		ToastNotification { }
	}
}
