/*
 * Copyright (C) 2025 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

/*
	Tests MockManager.missingValues(), which backs the --mock-coverage option.

	A "missing" value is one that the UI asked the mock backend for, but that the loaded mock
	configuration does not provide, so it reads as 'undefined' in QML. A value that a configuration
	deliberately set to undefined (a JSON null, i.e. a path the mocked device does not publish) is
	not missing, and must not be reported.

	Each test uses its own service uid, so that the tests do not see each other's values and can run
	in any order.
*/
TestCase {
	id: root

	name: "MockCoverageTest"

	Component {
		id: quickItemComponent
		VeQuickItem {}
	}

	// The uids that the UI has asked for but that are not provided, within one service.
	function missingUnder(serviceUid) {
		return MockManager.missingValues().filter(uid => uid.startsWith(serviceUid + "/"))
	}

	// Asks the backend for a uid, the way a binding in the UI would.
	function createVeQuickItem(uid) {
		return quickItemComponent.createObject(root, { uid: uid })
	}

	function test_valueNotProvidedIsReported() {
		const service = "mock/com.victronenergy.coverage.notprovided"
		MockManager.setValue(service + "/Provided", 1)

		const provided = createVeQuickItem(service + "/Provided")
		const notProvided = createVeQuickItem(service + "/NotProvided")

		compare(provided.valid, true, "the provided value should be valid")
		compare(notProvided.valid, false, "the missing value should read as undefined")
		compare(missingUnder(service), [service + "/NotProvided"])

		provided.destroy()
		notProvided.destroy()
	}

	function test_valueUnderAnUnknownServiceIsReported() {
		// Nothing has ever set a value under this service, so the whole branch is created by the
		// request itself. The service and the intermediate path are not values in their own right
		// and must not be reported; only the requested uid is.
		const service = "mock/com.victronenergy.coverage.unknownservice"
		const item = createVeQuickItem(service + "/Deep/Path/Value")

		compare(item.valid, false)
		compare(missingUnder(service), [service + "/Deep/Path/Value"])

		item.destroy()
	}

	function test_requestedPathIsStillReportedAfterItGainsChildren() {
		// Asking for a uid below one that was already requested adds children to it, which clears
		// its isLeaf(). It is still a requested path with no value, so it must still be reported.
		const service = "mock/com.victronenergy.coverage.withchildren"
		const parentItem = createVeQuickItem(service + "/Missing")
		compare(missingUnder(service), [service + "/Missing"])

		const childItem = createVeQuickItem(service + "/Missing/Child")

		compare(parentItem.valid, false)
		compare(childItem.valid, false)
		compare(missingUnder(service),
				[service + "/Missing", service + "/Missing/Child"],
				"a requested path does not stop being missing when it gains a child")

		parentItem.destroy()
		childItem.destroy()
	}

	function test_deliberatelyUndefinedIsNotReported() {
		const service = "mock/com.victronenergy.coverage.undefined"
		// A JSON null in a configuration arrives here as an undefined value.
		MockManager.setValue(service + "/NotPublished", undefined)

		const item = createVeQuickItem(service + "/NotPublished")

		compare(item.valid, false, "a deliberately undefined value still reads as undefined")
		compare(missingUnder(service), [], "a deliberate omission is not a gap")

		item.destroy()
	}

	function test_providingAValueLaterClearsTheReport() {
		const service = "mock/com.victronenergy.coverage.latervalue"
		const item = createVeQuickItem(service + "/Value")
		compare(missingUnder(service), [service + "/Value"])

		MockManager.setValue(service + "/Value", 42)

		compare(item.value, 42)
		compare(missingUnder(service), [], "a value that is now provided is not a gap")

		item.destroy()
	}

	function test_requestedPathThatAlreadyExistedIsReported() {
		// Known limitation. The "requested path" flag can only be recorded when an item is added
		// to the tree, and asking for a uid that already exists as a structural parent does not
		// add anything, so there is nothing to hook. Recording it properly needs a hook where the
		// request is actually resolved, in VeQItem::itemGetOrCreate(), which lives in veutil.
		//
		// The effect is that coverage depends on the order the UI asks for things: asking for
		// "/Missing/Child" first and "/Missing" second reports only the child, where the reverse
		// order reports both. This test states the behaviour we want; remove the expectFail() when
		// veutil can tell us about a request for an existing item.
		const service = "mock/com.victronenergy.coverage.existingparent"
		const childItem = createVeQuickItem(service + "/Missing/Child")
		compare(missingUnder(service), [service + "/Missing/Child"])

		const parentItem = createVeQuickItem(service + "/Missing")

		compare(parentItem.valid, false)
		expectFail("", "a path that already existed as a structural parent is not recorded as requested")
		compare(missingUnder(service),
				[service + "/Missing", service + "/Missing/Child"],
				"asking for a path that already exists should still report it")

		parentItem.destroy()
		childItem.destroy()
	}

	function test_valueSetToUndefinedAtRuntimeIsNotReported() {
		// A mock configuration is not the only thing that sets values: the application writes to
		// them at runtime too, through VeQuickItem. Clearing a value that way is just as
		// deliberate as a JSON null, so it is not a gap either.
		const service = "mock/com.victronenergy.coverage.runtimeundefined"
		MockManager.setValue(service + "/Value", 1)

		const item = createVeQuickItem(service + "/Value")
		compare(item.valid, true, "the value should start out valid")

		item.setValue(undefined)

		compare(item.valid, false, "the value should now read as undefined")
		compare(missingUnder(service), [], "a value the application cleared is not a gap")

		item.destroy()
	}

	function test_removedValueIsReportedAgain() {
		// The deliberate-omission markers are keyed by uid, so removing a value has to forget its
		// marker. Otherwise a uid that was once deliberately undefined stays whitelisted for the
		// rest of the run, and a real gap at that uid is never reported.
		const service = "mock/com.victronenergy.coverage.removed"
		const uid = service + "/NotPublished"

		MockManager.setValue(uid, undefined)
		compare(missingUnder(service), [], "a deliberate omission is not a gap")

		MockManager.removeValue(uid)

		// Nothing provides this value now, so asking for it again is a real gap.
		const item = createVeQuickItem(uid)
		compare(item.valid, false)
		compare(missingUnder(service), [uid], "a recreated value is no longer a deliberate omission")

		item.destroy()
	}

	function test_removedServiceIsReportedAgain() {
		// As above, but for removeServices(), which deletes a whole service subtree at once.
		// The omission is several levels below the service, so this also covers the recursion.
		const service = "mock/com.victronenergy.coveragesvc.removed"
		const uid = service + "/Deep/Path/NotPublished"

		MockManager.setValue(service + "/Provided", 1)
		MockManager.setValue(uid, undefined)
		compare(missingUnder(service), [], "a deliberate omission is not a gap")

		MockManager.removeServices("coveragesvc")

		const item = createVeQuickItem(uid)
		compare(item.valid, false)
		compare(missingUnder(service), [uid], "a recreated value is no longer a deliberate omission")

		item.destroy()
	}
}
