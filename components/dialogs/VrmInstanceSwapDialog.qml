/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls as C

ModalWarningDialog {
	id: root

	property ClassAndVrmInstance instanceA: ClassAndVrmInstance { id: _instanceA }
	property ClassAndVrmInstance instanceB: ClassAndVrmInstance { id: _instanceB }
	property int temporaryVrmInstance

	property alias instanceAUid: _instanceA.uid
	property alias instanceBUid: _instanceB.uid

	property bool _busy
	property bool _errorOccurred
	property int _instanceATargetInstance: -1
	property int _instanceBTargetInstance: -1

	signal swapFailed()

	// To swap VRM instances, e.g. if instanceA=123, instanceB=456, and we swap using temporaryVrmInstance=100:
	// 1. Set _instanceBTargetInstance to instanceA's current device instance (i.e. 123)
	//    and _instanceATargetInstance to instanceB's current device instance (i.e. 456)
	// 2. Set instanceB's VRM instance to temporaryVrmInstance (instanceB=456 -> instanceB=100)
	// 3. Set instanceA's VRM instance to instanceAInstance (instanceA=123 -> instanceA=456)
	// 4. Set instanceB's VRM instance to _instanceBTargetInstance (instanceB=100 -> instanceB=123)
	// Now instanceA=456, instanceB=123.
	function _runNextStep() {
		if (!_busy) {
			return
		}
		if (_instanceBTargetInstance < 0 && _instanceATargetInstance < 0) {
			// Step 1: record original device instances
			_instanceBTargetInstance = instanceA.vrmInstance
			_instanceATargetInstance = instanceB.vrmInstance
		}
		if (instanceB.vrmInstance === _instanceATargetInstance) {
			// Step 2: set the temporary device instance
			instanceB.setVrmInstance(temporaryVrmInstance)
		} else if (instanceB.vrmInstance === temporaryVrmInstance
				&& instanceA.vrmInstance !== _instanceATargetInstance) {
			// Step 3: Set target device instance
			instanceA.setVrmInstance(_instanceATargetInstance)
		} else if (instanceB.vrmInstance === temporaryVrmInstance
				&& instanceA.vrmInstance === _instanceATargetInstance) {
			// Step 4: Set final secondary device instance
			instanceB.setVrmInstance(_instanceBTargetInstance)
		} else if (instanceB.vrmInstance === _instanceBTargetInstance
				&& instanceA.vrmInstance === _instanceATargetInstance) {
			_done(false)
		} else {
			console.warn("Unrecognised device instance swap state! Tried to change",
					instanceA.serviceUid, "to", _instanceATargetInstance,
					instanceB.serviceUid, "to", _instanceBTargetInstance,
					"with temporary:", temporaryVrmInstance)
		}
	}

	function _done(errorOccurred) {
		dialogDoneOptions = VenusOS.ModalDialog_DoneOptions_OkOnly
		_errorOccurred = errorOccurred
		_busy = false
		_instanceATargetInstance = -1
		_instanceBTargetInstance = -1

		if (errorOccurred) {
			swapFailed()
		}
	}

	function _reset() {
		dialogDoneOptions = VenusOS.ModalDialog_DoneOptions_OkAndCancel
		_errorOccurred = false
		_busy = false
		_instanceATargetInstance = -1
		_instanceBTargetInstance = -1
	}

	title: dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_OkAndCancel
		  //% "Already in use"
		? qsTrId("deviceinstanceswap_already_assigned")
		: _errorOccurred
			//% "Swap error"
			? qsTrId("deviceinstanceswap_swap_error")
			  //% "Swap complete"
			: qsTrId("deviceinstanceswap_swap_completed")

	description: {
		if (dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_OkAndCancel) {
			if (_busy) {
				//% "Swapping device instances..."
				return qsTrId("deviceinstanceswap_busy")
			} else {
				if (instanceB.name) {
					//: %1 and %2 are unique device instance numbers, %3 = another device's name
					//% "Device instance %1 is already used by '%3'. Swap device instances and assign that to %2?"
					return qsTrId("deviceinstanceswap_already_assigned_description_with_name")
							.arg(instanceB.vrmInstance)
							.arg(instanceA.vrmInstance)
							.arg(instanceB.name)
				} else {
					//: %1 and %2 are unique device instance numbers
					//% "Device instance %1 is already used by another device of the same type. Swap device instances and assign that to %2?"
					return qsTrId("deviceinstanceswap_already_assigned_description")
						  .arg(instanceB.vrmInstance)
						  .arg(instanceA.vrmInstance)
				}
			}
		} else {    // 'OK' button only
			return _errorOccurred
					  //% "Cannot swap device instances: operation timed out."
					? qsTrId("deviceinstanceswap_timed_out")
					  //% "New device instances will be active on reboot."
					: qsTrId("deviceinstanceswap_active_on_reboot")
		}
	}

	acceptText: dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_OkAndCancel
		  //: Confirm that the two devices' instance number should be swapped.
		  //% "Swap"
		? qsTrId("deviceinstanceswap_swap")
		: CommonWords.ok

	icon.source: dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_OkAndCancel || _errorOccurred
				 ? "qrc:/images/icon_alarm_48.svg"
				 : "qrc:/images/icon_checkmark_48.svg"
	icon.color: dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_OkAndCancel || _errorOccurred
				? Theme.color_red
				: Theme.color_green

	closePolicy: _busy ? C.Popup.NoAutoClose : (C.Popup.CloseOnEscape | C.Popup.CloseOnPressOutside)
	footer.enabled: !_busy
	footer.opacity: _busy ? 0 : 1

	tryAccept: function() {
		if (dialogDoneOptions === VenusOS.ModalDialog_DoneOptions_OkOnly) {
			return true
		} else {
			_busy = true
			_runNextStep()
			return false
		}
	}

	onAboutToShow: {
		_reset()
	}

	Timer {
		id: timeout
		running: root._busy
		interval: 15 * 1000
		onTriggered: root._done(true)
	}

	Connections {
		target: instanceA || null
		enabled: root._busy

		function onVrmInstanceChanged() {
			root._runNextStep()
		}
	}

	Connections {
		target: instanceB || null
		enabled: root._busy

		function onVrmInstanceChanged() {
			root._runNextStep()
		}
	}
}
