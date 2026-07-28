/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
	id: root

	name: "NotificationToastTest"

	readonly property string platformService: "com.victronenergy.platform"

	// Tracks the highest slot index that has been fully created by a test.
	property int _maxSlotCreated: -1

	// Helper to construct the full path for a notification slot field
	function slotPath(slotIndex, field) {
		return platformService + "/Notifications/" + slotIndex + "/" + field
	}

	// Helper to set up a complete notification slot in the mock backend.
	// Sets Description last (mimicking venus-platform behaviour).
	function setNotificationSlot(slotIndex, data) {
		if (slotIndex > _maxSlotCreated)
			_maxSlotCreated = slotIndex
		MockManager.setValue(slotPath(slotIndex, "DeviceName"), data.deviceName)
		MockManager.setValue(slotPath(slotIndex, "Service"), data.service || "")
		MockManager.setValue(slotPath(slotIndex, "Trigger"), data.trigger || "")
		MockManager.setValue(slotPath(slotIndex, "AlarmValue"), data.alarmValue || 0)
		MockManager.setValue(slotPath(slotIndex, "Value"), data.value || "")
		MockManager.setValue(slotPath(slotIndex, "DateTime"), data.dateTime || 1750000000)
		MockManager.setValue(slotPath(slotIndex, "Type"), data.type)
		MockManager.setValue(slotPath(slotIndex, "Silenced"), data.silenced || 0)
		MockManager.setValue(slotPath(slotIndex, "Acknowledged"), data.acknowledged || 0)
		MockManager.setValue(slotPath(slotIndex, "Active"), data.active || 0)
		// Description is set last, matching venus-platform behaviour.
		MockManager.setValue(slotPath(slotIndex, "Description"), data.description)
	}

	// Helper to update specific fields in a notification slot, with Description last.
	function updateNotificationSlot(slotIndex, data) {
		if (data.hasOwnProperty("deviceName"))
			MockManager.setValue(slotPath(slotIndex, "DeviceName"), data.deviceName)
		if (data.hasOwnProperty("service"))
			MockManager.setValue(slotPath(slotIndex, "Service"), data.service)
		if (data.hasOwnProperty("trigger"))
			MockManager.setValue(slotPath(slotIndex, "Trigger"), data.trigger)
		if (data.hasOwnProperty("alarmValue"))
			MockManager.setValue(slotPath(slotIndex, "AlarmValue"), data.alarmValue)
		if (data.hasOwnProperty("value"))
			MockManager.setValue(slotPath(slotIndex, "Value"), data.value)
		if (data.hasOwnProperty("dateTime"))
			MockManager.setValue(slotPath(slotIndex, "DateTime"), data.dateTime)
		if (data.hasOwnProperty("type"))
			MockManager.setValue(slotPath(slotIndex, "Type"), data.type)
		if (data.hasOwnProperty("silenced"))
			MockManager.setValue(slotPath(slotIndex, "Silenced"), data.silenced)
		if (data.hasOwnProperty("acknowledged"))
			MockManager.setValue(slotPath(slotIndex, "Acknowledged"), data.acknowledged)
		if (data.hasOwnProperty("active"))
			MockManager.setValue(slotPath(slotIndex, "Active"), data.active)
		// Description must be last (triggers handleDescriptionChanged which refreshes all fields).
		if (data.hasOwnProperty("description"))
			MockManager.setValue(slotPath(slotIndex, "Description"), data.description)
	}

	// Helper to find a toast by its notificationModelId
	function findToastForNotification(notificationModelId) {
		for (let i = 0; i < ToastModel.rowCount(); ++i) {
			const index = ToastModel.index(i, 0)
			if (ToastModel.data(index, ToastModel.ToastRoles.NotificationModelId) === notificationModelId) {
				return {
					type: ToastModel.data(index, ToastModel.ToastRoles.Type),
					description: ToastModel.data(index, ToastModel.ToastRoles.Description),
					modelId: ToastModel.data(index, ToastModel.ToastRoles.ModelId),
				}
			}
		}
		return null
	}

	// Helper: get the notification modelId for a specific slot index.
	function notificationModelIdForSlot(slotIndex) {
		const slotId = "" + slotIndex
		for (let i = 0; i < NotificationModel.rowCount(); ++i) {
			const index = NotificationModel.index(i, 0)
			const entry = NotificationModel.get(
				NotificationModel.data(index, NotificationModel.NotificationRoles.ModelId))
			if (entry.notificationId === slotId) {
				return entry.modelId
			}
		}
		return 0
	}

	// The NotificationLayer Connections handler that manages toasts.
	// We instantiate it here so we can test its behaviour.
	property Connections _toastController: Connections {
		target: NotificationModel

		function onAdded(modelId) {
			let entry = NotificationModel.get(modelId)
			if (!entry.acknowledged) {
				ToastModel.addNotification(
						modelId,
						entry.type,
						"" + entry.deviceName + "\n" + entry.description)
			}
		}

		function onChanged(modelId, roles) {
			let entry = NotificationModel.get(modelId)
			if (roles.indexOf(NotificationModel.NotificationRoles.Acknowledged) >= 0) {
				if (entry.acknowledged) {
					ToastModel.removeNotification(modelId)
				} else {
					if (!entry.acknowledged) {
						ToastModel.addNotification(
								modelId,
								entry.type,
								"" + entry.deviceName + "\n" + entry.description)
					}
				}
			} else if (roles.indexOf(NotificationModel.NotificationRoles.Type) >= 0) {
				if (ToastModel.removeNotification(modelId)) {
					ToastModel.addNotification(modelId, entry.type,
							"" + entry.deviceName + "\n" + entry.description)
				}
			} else if (roles.indexOf(NotificationModel.NotificationRoles.Description) >= 0
					|| roles.indexOf(NotificationModel.NotificationRoles.DeviceName) >= 0) {
				let text = "" + entry.deviceName + "\n" + entry.description
				ToastModel.updateNotification(modelId, text)
			}
		}

		function onRemoved(modelId) {
			ToastModel.removeNotification(modelId)
		}
	}

	function initTestCase() {
		// The C++ test runner creates the Notifications parent item (matching
		// venus-platform startup). NotificationModel.init() succeeds immediately
		// with no slot children. Tests create slots dynamically via setNotificationSlot.
		compare(ToastModel.rowCount(), 0, "initTestCase: no toasts")
	}

	function cleanup() {
		// Deactivate and acknowledge only slots that have been created.
		// Setting Acknowledged=1 then Active=0 triggers breakAssociation.
		for (let i = 0; i <= _maxSlotCreated; ++i) {
			MockManager.setValue(slotPath(i, "Acknowledged"), 1)
			MockManager.setValue(slotPath(i, "Active"), 0)
		}
		// Remove all remaining toasts
		while (ToastModel.rowCount() > 0) {
			ToastModel.removeFirst()
		}
	}

	// -----------------------------------------------------------------------
	// Test: A new active+unacknowledged notification creates a toast with
	// correct deviceName, description, and type.
	// -----------------------------------------------------------------------
	function test_newNotificationCreatesToast() {
		setNotificationSlot(0, {
			deviceName: "MultiPlus-II 48/10000/140",
			description: "Low battery voltage",
			type: VenusOS.Notification_Alarm,
			active: 1,
			acknowledged: 0,
		})
		wait(1) // one event-loop pump for childAdded QueuedConnection → watchSlot

		const modelId = notificationModelIdForSlot(0)
		verify(modelId > 0, "Notification was added to model")

		const toast = findToastForNotification(modelId)
		verify(toast !== null, "Toast was created")
		compare(toast.type, VenusOS.Notification_Alarm)
		compare(toast.description, "MultiPlus-II 48/10000/140\nLow battery voltage")
	}

	// -----------------------------------------------------------------------
	// Test: Acknowledged notification does NOT create a toast.
	// -----------------------------------------------------------------------
	function test_acknowledgedNotificationNoToast() {
		setNotificationSlot(0, {
			deviceName: "SmartShunt",
			description: "Low SOC",
			type: VenusOS.Notification_Warning,
			active: 1,
			acknowledged: 1,
		})
		wait(1) // one event-loop pump for childAdded QueuedConnection → watchSlot

		const modelId = notificationModelIdForSlot(0)
		verify(modelId > 0, "Notification was added to model")

		const toast = findToastForNotification(modelId)
		compare(toast, null, "No toast for acknowledged notification")
	}

	// -----------------------------------------------------------------------
	// Test: When deviceName changes via description refresh (slot reuse),
	// the toast text is updated correctly.
	// This exercises the fix for issue #3131: Active fires first (with stale
	// deviceName), then Description triggers the refresh that corrects it.
	// -----------------------------------------------------------------------
	function test_deviceNameChangeUpdatesToast() {
		// Create initial notification with Device A
		setNotificationSlot(0, {
			deviceName: "MPPT 450/200 HQ2531YK4PJ",
			description: "PV overcurrent",
			type: VenusOS.Notification_Alarm,
			active: 1,
			acknowledged: 0,
		})
		wait(1) // one event-loop pump for childAdded QueuedConnection → watchSlot

		let modelId = notificationModelIdForSlot(0)
		let toast = findToastForNotification(modelId)
		verify(toast !== null, "Toast exists after creation")
		compare(toast.description, "MPPT 450/200 HQ2531YK4PJ\nPV overcurrent")

		// Acknowledge and deactivate (breakAssociation removes entry)
		MockManager.setValue(slotPath(0, "Acknowledged"), 1)
		MockManager.setValue(slotPath(0, "Active"), 0)

		// Recycle: simulate the stale-data scenario.
		// Active fires first (DeviceName is still "MPPT 450/200 HQ2531YK4PJ"),
		// then Acknowledged=0 creates the toast with stale deviceName,
		// then DeviceName and Description update trigger the fix.
		MockManager.setValue(slotPath(0, "Active"), 1)
		MockManager.setValue(slotPath(0, "Acknowledged"), 0)

		// At this point, toast has stale deviceName. Now update fields:
		MockManager.setValue(slotPath(0, "DeviceName"), "MultiPlus-II 48/10000/140-100")
		// Description MUST change to trigger handleDescriptionChanged.
		MockManager.setValue(slotPath(0, "Description"), "Wrong phase rotation detected")

		modelId = notificationModelIdForSlot(0)
		toast = findToastForNotification(modelId)
		verify(toast !== null, "Toast still exists after description refresh")
		compare(toast.description, "MultiPlus-II 48/10000/140-100\nWrong phase rotation detected")
	}

	// -----------------------------------------------------------------------
	// Test: When description changes, the toast text is updated.
	// -----------------------------------------------------------------------
	function test_descriptionChangeUpdatesToast() {
		setNotificationSlot(0, {
			deviceName: "SmartShunt",
			description: "Initial description",
			type: VenusOS.Notification_Warning,
			active: 1,
			acknowledged: 0,
		})
		wait(1) // one event-loop pump for childAdded QueuedConnection → watchSlot

		const modelId = notificationModelIdForSlot(0)
		let toast = findToastForNotification(modelId)
		verify(toast !== null)
		compare(toast.description, "SmartShunt\nInitial description")

		updateNotificationSlot(0, {
			description: "Updated description",
		})

		toast = findToastForNotification(modelId)
		verify(toast !== null)
		compare(toast.description, "SmartShunt\nUpdated description")
	}

	// -----------------------------------------------------------------------
	// Test: When type changes during description refresh, the toast is
	// replaced with the correct type.
	// -----------------------------------------------------------------------
	function test_typeChangeReplacesToast() {
		setNotificationSlot(0, {
			deviceName: "Pro Battery",
			description: "High temperature",
			type: VenusOS.Notification_Warning,
			active: 1,
			acknowledged: 0,
		})
		wait(1) // one event-loop pump for childAdded QueuedConnection → watchSlot

		const modelId = notificationModelIdForSlot(0)
		let toast = findToastForNotification(modelId)
		verify(toast !== null)
		compare(toast.type, VenusOS.Notification_Warning)

		// Type changes from Warning to Alarm, with a new description
		// (Description must actually change to trigger the signal).
		updateNotificationSlot(0, {
			type: VenusOS.Notification_Alarm,
			description: "Critical temperature",
		})

		toast = findToastForNotification(modelId)
		verify(toast !== null, "Toast still exists after type change")
		compare(toast.type, VenusOS.Notification_Alarm, "Toast type updated to Alarm")
		compare(toast.description, "Pro Battery\nCritical temperature")
	}

	// -----------------------------------------------------------------------
	// Test: Acknowledging a notification removes its toast.
	// -----------------------------------------------------------------------
	function test_acknowledgeRemovesToast() {
		setNotificationSlot(0, {
			deviceName: "Cerbo GX",
			description: "Firmware update available",
			type: VenusOS.Notification_Info,
			active: 1,
			acknowledged: 0,
		})
		wait(1) // one event-loop pump for childAdded QueuedConnection → watchSlot

		const modelId = notificationModelIdForSlot(0)
		let toast = findToastForNotification(modelId)
		verify(toast !== null, "Toast exists before acknowledge")

		MockManager.setValue(slotPath(0, "Acknowledged"), 1)

		toast = findToastForNotification(modelId)
		compare(toast, null, "Toast removed after acknowledge")
	}

	// -----------------------------------------------------------------------
	// Test: Slot recycling — a previously acknowledged slot becomes active
	// again with new data (the acknowledged value goes to 0 after active).
	// -----------------------------------------------------------------------
	function test_slotRecyclingCreatesNewToast() {
		// First: create and acknowledge a notification
		setNotificationSlot(0, {
			deviceName: "Old Device",
			description: "Old alarm",
			type: VenusOS.Notification_Alarm,
			active: 1,
			acknowledged: 0,
		})
		wait(1) // one event-loop pump for childAdded QueuedConnection → watchSlot

		let modelId = notificationModelIdForSlot(0)
		MockManager.setValue(slotPath(0, "Acknowledged"), 1)
		MockManager.setValue(slotPath(0, "Active"), 0)

		let toast = findToastForNotification(modelId)
		compare(toast, null, "Old toast removed")

		// Now recycle the slot: new device, new description.
		// Sequence mirrors venus-platform: Active first, Acknowledged, then Description last.
		MockManager.setValue(slotPath(0, "DeviceName"), "New Device")
		MockManager.setValue(slotPath(0, "Type"), VenusOS.Notification_Warning)
		MockManager.setValue(slotPath(0, "Active"), 1)
		MockManager.setValue(slotPath(0, "Acknowledged"), 0)

		// At this point a toast should exist (created by the Acknowledged handler)
		const newModelId = notificationModelIdForSlot(0)
		verify(newModelId > modelId, "New notification entry created")

		toast = findToastForNotification(newModelId)
		verify(toast !== null, "New toast created for recycled slot")

		// Now description arrives (triggers full refresh)
		MockManager.setValue(slotPath(0, "Description"), "New warning")

		toast = findToastForNotification(newModelId)
		verify(toast !== null, "Toast persists after description update")
		compare(toast.description, "New Device\nNew warning")
		compare(toast.type, VenusOS.Notification_Warning)
	}

	// -----------------------------------------------------------------------
	// Test: Repeated slot recycling with hundreds of iterations.
	// Verifies that toast state remains correct across many recycles.
	// -----------------------------------------------------------------------
	function test_repeatedSlotRecycling() {
		const devices = [
			"MultiPlus-II 48/10000/140-100",
			"MPPT 450/200 HQ2531YK4PJ",
			"SmartShunt 500A",
			"Cerbo GX",
			"Lynx Smart BMS",
			"BlueSolar MPPT 150/35",
			"Phoenix Inverter 24/3000",
			"SmartSolar MPPT 250/100",
		]
		const descriptions = [
			"Wrong phase rotation detected",
			"Low battery voltage",
			"High temperature",
			"Overload",
			"Low SOC",
			"Grid failure",
			"BMS connection lost",
			"Firmware update available",
		]
		const types = [
			VenusOS.Notification_Alarm,
			VenusOS.Notification_Warning,
			VenusOS.Notification_Info,
		]

		// Initial slot setup
		setNotificationSlot(0, {
			deviceName: devices[0],
			description: descriptions[0],
			type: types[0],
			active: 1,
			acknowledged: 0,
		})
		wait(1) // one event-loop pump for childAdded QueuedConnection → watchSlot

		for (let iteration = 1; iteration < 200; ++iteration) {
			const modelIdBefore = notificationModelIdForSlot(0)

			// Acknowledge and deactivate current notification
			MockManager.setValue(slotPath(0, "Acknowledged"), 1)
			MockManager.setValue(slotPath(0, "Active"), 0)

			// Verify toast was removed
			let toast = findToastForNotification(modelIdBefore)
			compare(toast, null, "Iteration " + iteration + ": old toast removed")

			// Recycle the slot with new data
			const deviceIdx = iteration % devices.length
			const descIdx = iteration % descriptions.length
			const typeIdx = iteration % types.length
			const expectedDevice = devices[deviceIdx]
			const expectedDesc = descriptions[descIdx]
			const expectedType = types[typeIdx]

			MockManager.setValue(slotPath(0, "DeviceName"), expectedDevice)
			MockManager.setValue(slotPath(0, "Type"), expectedType)
			MockManager.setValue(slotPath(0, "DateTime"), 1750000000 + iteration)
			MockManager.setValue(slotPath(0, "Active"), 1)
			MockManager.setValue(slotPath(0, "Acknowledged"), 0)

			// A toast should be created by the Acknowledged handler
			const newModelId = notificationModelIdForSlot(0)
			verify(newModelId > modelIdBefore,
					"Iteration " + iteration + ": new entry created (got " + newModelId + " > " + modelIdBefore + ")")

			// Description arrives last (refreshes all stale fields)
			MockManager.setValue(slotPath(0, "Description"), expectedDesc)

			// Verify the toast has the correct data
			toast = findToastForNotification(newModelId)
			verify(toast !== null, "Iteration " + iteration + ": toast exists")
			compare(toast.description, expectedDevice + "\n" + expectedDesc,
					"Iteration " + iteration + ": toast text correct")
			compare(toast.type, expectedType,
					"Iteration " + iteration + ": toast type correct")
		}
	}

	// -----------------------------------------------------------------------
	// Test: Multiple slots active simultaneously with different data.
	// -----------------------------------------------------------------------
	function test_multipleSlots() {
		setNotificationSlot(0, {
			deviceName: "Battery Monitor",
			description: "Low SOC",
			type: VenusOS.Notification_Alarm,
			active: 1,
			acknowledged: 0,
		})
		setNotificationSlot(1, {
			deviceName: "Solar Charger",
			description: "High voltage",
			type: VenusOS.Notification_Warning,
			active: 1,
			acknowledged: 0,
		})
		setNotificationSlot(2, {
			deviceName: "System",
			description: "Update available",
			type: VenusOS.Notification_Info,
			active: 1,
			acknowledged: 0,
		})
		wait(1) // one event-loop pump for childAdded QueuedConnection → watchSlot

		// All three should have toasts
		compare(ToastModel.rowCount(), 3, "Three toasts created")

		// Verify each toast has correct data by checking the notification model entries
		const count = NotificationModel.rowCount()
		verify(count >= 3, "At least 3 notification entries")

		// Check each notification entry has a corresponding toast with correct data
		for (let i = count - 3; i < count; ++i) {
			const index = NotificationModel.index(i, 0)
			const modelId = NotificationModel.data(index, NotificationModel.NotificationRoles.ModelId)
			const expectedDevice = NotificationModel.data(index, NotificationModel.NotificationRoles.DeviceName)
			const expectedDesc = NotificationModel.data(index, NotificationModel.NotificationRoles.Description)
			const expectedType = NotificationModel.data(index, NotificationModel.NotificationRoles.Type)

			const toast = findToastForNotification(modelId)
			verify(toast !== null, "Toast exists for modelId " + modelId)
			compare(toast.description, expectedDevice + "\n" + expectedDesc)
			compare(toast.type, expectedType)
		}
	}

	// -----------------------------------------------------------------------
	// Test: Slot recycling where new notification has the same description
	// but different deviceName (the exact issue #3131 scenario).
	// Repeated many times to verify reliability.
	// -----------------------------------------------------------------------
	function test_sameDescriptionDifferentDevice() {
		const description = "Wrong phase rotation detected"
		const deviceA = "MultiPlus-II 48/10000/140-100"
		const deviceB = "MPPT 450/200 HQ2531YK4PJ"

		for (let iteration = 0; iteration < 100; ++iteration) {
			const isEven = (iteration % 2 === 0)
			const expectedDevice = isEven ? deviceA : deviceB
			const expectedType = isEven ? VenusOS.Notification_Alarm : VenusOS.Notification_Warning

			if (iteration === 0) {
					// First iteration: create the slot
					setNotificationSlot(0, {
						deviceName: expectedDevice,
						description: description,
						type: expectedType,
						active: 1,
						acknowledged: 0,
					})
					wait(1) // one event-loop pump for childAdded QueuedConnection → watchSlot
				} else {
					// Subsequent iterations: recycle the slot
					MockManager.setValue(slotPath(0, "Acknowledged"), 1)
					MockManager.setValue(slotPath(0, "Active"), 0)

					// Set new values (Description arrives last)
					MockManager.setValue(slotPath(0, "DeviceName"), expectedDevice)
					MockManager.setValue(slotPath(0, "Type"), expectedType)
					MockManager.setValue(slotPath(0, "DateTime"), 1750000000 + iteration)
					MockManager.setValue(slotPath(0, "Active"), 1)
					MockManager.setValue(slotPath(0, "Acknowledged"), 0)
					// Description is the same as before — this is the crux of issue #3131
					MockManager.setValue(slotPath(0, "Description"), description)
				}

			const modelId = notificationModelIdForSlot(0)
			const toast = findToastForNotification(modelId)
			verify(toast !== null, "Iteration " + iteration + ": toast exists")
			compare(toast.description, expectedDevice + "\n" + description,
					"Iteration " + iteration + ": correct deviceName in toast")
			compare(toast.type, expectedType,
					"Iteration " + iteration + ": correct type in toast")
		}
	}

	// -----------------------------------------------------------------------
	// Test: Both deviceName and description change simultaneously.
	// -----------------------------------------------------------------------
	function test_bothDeviceNameAndDescriptionChange() {
		setNotificationSlot(0, {
			deviceName: "Device A",
			description: "Description A",
			type: VenusOS.Notification_Alarm,
			active: 1,
			acknowledged: 0,
		})
		wait(1) // one event-loop pump for childAdded QueuedConnection → watchSlot

		const modelId = notificationModelIdForSlot(0)
		let toast = findToastForNotification(modelId)
		verify(toast !== null)
		compare(toast.description, "Device A\nDescription A")

		// Both change at once (triggered by description refresh)
		updateNotificationSlot(0, {
			deviceName: "Device B",
			description: "Description B",
		})

		toast = findToastForNotification(modelId)
		verify(toast !== null)
		compare(toast.description, "Device B\nDescription B")
	}

	// -----------------------------------------------------------------------
	// Test: Type change from Info to Alarm correctly updates toast type.
	// -----------------------------------------------------------------------
	function test_typeChangeInfoToAlarm() {
		setNotificationSlot(0, {
			deviceName: "Cerbo GX",
			description: "System notification",
			type: VenusOS.Notification_Info,
			active: 1,
			acknowledged: 0,
		})
		wait(1) // one event-loop pump for childAdded QueuedConnection → watchSlot

		const modelId = notificationModelIdForSlot(0)
		let toast = findToastForNotification(modelId)
		verify(toast !== null)
		compare(toast.type, VenusOS.Notification_Info)

		// Type changes and description changes (description must change
		// to trigger the descriptionChanged signal in the backend).
		updateNotificationSlot(0, {
			type: VenusOS.Notification_Alarm,
			description: "Critical system failure",
		})

		toast = findToastForNotification(modelId)
		verify(toast !== null)
		compare(toast.type, VenusOS.Notification_Alarm, "Type changed to Alarm")
		compare(toast.description, "Cerbo GX\nCritical system failure")
	}

	// -----------------------------------------------------------------------
	// Test: Hundreds of sequential notifications cycling through slots 0-19,
	// mimicking real venus-platform behaviour where notifications fill slots
	// sequentially and wrap around.
	// -----------------------------------------------------------------------
	function test_sequentialSlotCycling() {
		const devices = [
			"MultiPlus-II 48/10000/140-100",
			"MPPT 450/200 HQ2531YK4PJ",
			"SmartShunt 500A",
			"Cerbo GX",
			"Lynx Smart BMS",
			"BlueSolar MPPT 150/35",
			"Phoenix Inverter 24/3000",
			"SmartSolar MPPT 250/100",
			"Quattro 48/15000/200-100",
			"EasySolar-II GX",
		]
		const descriptions = [
			"Wrong phase rotation detected",
			"Low battery voltage",
			"High temperature",
			"Overload",
			"Low SOC",
			"Grid failure",
			"BMS connection lost",
			"Firmware update available",
			"High DC ripple",
			"PV overcurrent",
			"Ground relay fault",
			"AC input not connected",
		]
		const types = [
			VenusOS.Notification_Alarm,
			VenusOS.Notification_Warning,
			VenusOS.Notification_Info,
		]

		const slotCount = 20
		const totalNotifications = 300

		for (let n = 0; n < totalNotifications; ++n) {
			const slotIndex = n % slotCount
			const expectedDevice = devices[n % devices.length]
			const expectedDesc = descriptions[n % descriptions.length]
			const expectedType = types[n % types.length]

			if (n < slotCount) {
				// First pass: create complete slot (triggers childAdded → watchSlot).
				setNotificationSlot(slotIndex, {
					deviceName: expectedDevice,
					description: expectedDesc,
					type: expectedType,
					active: 1,
					acknowledged: 0,
					dateTime: 1750000000 + n,
				})
				wait(1) // one event-loop pump for childAdded QueuedConnection → watchSlot
			} else {
				// Subsequent passes: recycle existing slot with new data.
				MockManager.setValue(slotPath(slotIndex, "Acknowledged"), 1)
				MockManager.setValue(slotPath(slotIndex, "Active"), 0)
				MockManager.setValue(slotPath(slotIndex, "DeviceName"), expectedDevice)
				MockManager.setValue(slotPath(slotIndex, "Type"), expectedType)
				MockManager.setValue(slotPath(slotIndex, "DateTime"), 1750000000 + n)
				MockManager.setValue(slotPath(slotIndex, "Active"), 1)
				MockManager.setValue(slotPath(slotIndex, "Acknowledged"), 0)
				MockManager.setValue(slotPath(slotIndex, "Description"), expectedDesc)
			}

			const modelId = notificationModelIdForSlot(slotIndex)
			verify(modelId > 0, "N=" + n + " slot=" + slotIndex + ": entry exists")

			const toast = findToastForNotification(modelId)
			verify(toast !== null, "N=" + n + " slot=" + slotIndex + ": toast exists")
			compare(toast.description, expectedDevice + "\n" + expectedDesc,
					"N=" + n + " slot=" + slotIndex + ": toast text correct")
			compare(toast.type, expectedType,
					"N=" + n + " slot=" + slotIndex + ": toast type correct")
		}
	}
}
