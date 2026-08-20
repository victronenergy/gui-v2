/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Window
import QtTest

TestCase {
	id: root
	name: "delegateComponentModelTest"
	when: windowShown

	Window {
		id: win
		width: 800
		height: 600
		visible: true

		Rectangle {
			anchors.fill: parent
			color: "yellow"

			// --- Test A: all entries visible ---
			ListView {
				id: viewA
				anchors.fill: parent
				model: DelegateComponentModel {
					id: modelA
					DelegateComponent {
						id: entryA1
						delegate: Component { Rectangle { width: 800; height: 20; color: "red" } }
					}
					DelegateComponent {
						id: entryA2
						delegate: Component { Rectangle { width: 800; height: 20; color: "green" } }
					}
					DelegateComponent {
						id: entryA3
						delegate: Component { Rectangle { width: 800; height: 20; color: "blue" } }
					}
				}
			}

			// --- Test B: some entries hidden ---
			ListView {
				id: viewB
				anchors.fill: parent
				model: DelegateComponentModel {
					id: modelB
					DelegateComponent {
						id: entryB1
						property bool shouldBeVisible
						preferredVisible: shouldBeVisible
						delegate: Component { Rectangle { width: 800; height: 20; objectName: "B1" } }
					}
					DelegateComponent {
						id: entryB2
						delegate: Component { Rectangle { width: 800; height: 20; objectName: "B2" } }
					}
					DelegateComponent {
						id: entryB3
						delegate: Component { Rectangle { width: 800; height: 20; objectName: "B3" } }
					}
					DelegateComponent {
						id: entryB4
						preferredVisible: false
						delegate: Component { Rectangle { width: 800; height: 20; objectName: "B4" } }
					}
					DelegateComponent {
						id: entryB5
						delegate: Component { Rectangle { width: 800; height: 20; objectName: "B5" } }
					}
				}
			}

			// --- Test C: dynamic model swap ---
			ListView {
				id: viewC
				anchors.fill: parent
				DelegateComponentModel {
					id: modelC1
					DelegateComponent {
						delegate: Component { Rectangle { width: 800; height: 20 } }
					}
					DelegateComponent {
						delegate: Component { Rectangle { width: 800; height: 20 } }
					}
				}
				DelegateComponentModel {
					id: modelC2
					DelegateComponent {
						delegate: Component { Rectangle { width: 800; height: 20 } }
					}
				}
			}

			// --- Test D: preferredVisible from DC-owned model count ---
			ListView {
				id: viewD
				anchors.fill: parent
				model: DelegateComponentModel {
					id: modelD
					DelegateComponent {
						id: modelCountDrivenDC
						property ListModel sourceModel: ListModel {}
						readonly property int rowCount: sourceModel.count
						preferredVisible: rowCount > 0
						delegate: Component { Rectangle { width: 800; height: 20; objectName: "D1" } }
					}
				}
			}

			// --- Test E: preferredVisible from DC-owned state objects ---
			ListView {
				id: viewE
				anchors.fill: parent
				model: DelegateComponentModel {
					id: modelE
					DelegateComponent {
						id: errorStateDC
						property bool commValid: false
						property int commValue: 0
						property bool voltageValid: false
						property int voltageValue: 0
						preferredVisible: commValid || voltageValid
						delegate: Component { Rectangle { width: 800; height: 20; objectName: "E1" } }
					}
				}
			}

			// --- Test F: nested component uses DC-owned state ---
			ListView {
				id: viewF
				anchors.fill: parent
				model: DelegateComponentModel {
					id: modelF
					DelegateComponent {
						id: nestedStateDC
						property bool rowVisible: true
						property int sharedValue: 0
						property Component subPageComponent: Component {
							Item {
								required property var stateOwner
								readonly property int currentValue: stateOwner.sharedValue
								function toggle() {
									stateOwner.sharedValue = stateOwner.sharedValue === 0 ? 1 : 0
								}
							}
						}
						preferredVisible: rowVisible
						delegate: Component { Rectangle { width: 800; height: 20; objectName: "F1" } }
					}
				}
			}

			// --- Test G: delegates are actually constructed and destroyed ---
			//
			// Every other test here asserts only on count, and ListView.count is just
			// model.count, so they would all still pass if object() and release() did
			// nothing at all. These two count real construction and destruction, which
			// is the behaviour the model exists for.
			ListView {
				id: viewG
				anchors.fill: parent
				model: DelegateComponentModel {
					id: modelG
					DelegateComponent {
						id: builtDC
						property bool rowVisible: false
						preferredVisible: rowVisible
						delegate: Component {
							Rectangle {
								width: 800
								height: 20
								objectName: "G1"
								Component.onCompleted: root.delegatesBuilt++
								Component.onDestruction: root.delegatesDestroyed++
							}
						}
					}
				}
			}
		}
	}

	property int delegatesBuilt: 0
	property int delegatesDestroyed: 0

	function test_allEntriesVisible() {
		compare(modelA.count, 3)
		compare(viewA.count, 3)
	}

	function test_someEntriesHidden() {
		// entryB1 (shouldBeVisible=false) and entryB4 (preferredVisible=false) are hidden
		compare(modelB.count, 3)
		compare(viewB.count, 3)
	}

	function test_visibilityChanges() {
		// Make entryB4 visible
		entryB4.preferredVisible = true
		compare(modelB.count, 4)
		compare(viewB.count, 4)

		// Make entryB1 visible via its binding
		entryB1.shouldBeVisible = true
		compare(modelB.count, 5)
		compare(viewB.count, 5)

		// Hide entryB4 again
		entryB4.preferredVisible = false
		compare(modelB.count, 4)
		compare(viewB.count, 4)

		// Hide entryB1 again
		entryB1.shouldBeVisible = false
		compare(modelB.count, 3)
		compare(viewB.count, 3)
	}

	function test_dynamicModelSwap() {
		compare(viewC.count, 0)

		viewC.model = modelC1
		compare(viewC.count, 2)

		viewC.model = modelC2
		compare(viewC.count, 1)
	}

	function test_hideAllThenShow() {
		// Start from known state: 3 visible in modelA
		const entries = modelA.entries
		compare(entries.length, 3)
		compare(modelA.count, 3)

		// Hide all
		for (let i = 0; i < entries.length; ++i) {
			entries[i].preferredVisible = false
		}
		compare(modelA.count, 0)
		compare(viewA.count, 0)

		// Show the middle one
		entries[1].preferredVisible = true
		compare(modelA.count, 1)
		compare(viewA.count, 1)

		// Show the first one — it should appear before the middle
		entries[0].preferredVisible = true
		compare(modelA.count, 2)
		compare(viewA.count, 2)

		// Show the last one
		entries[2].preferredVisible = true
		compare(modelA.count, 3)
		compare(viewA.count, 3)
	}

	function test_preferredVisibleFromDcOwnedModelCount() {
		compare(modelCountDrivenDC.rowCount, 0)
		compare(modelD.count, 0)
		compare(viewD.count, 0)

		modelCountDrivenDC.sourceModel.append({ value: 1 })
		compare(modelCountDrivenDC.rowCount, 1)
		tryCompare(modelD, "count", 1)
		tryCompare(viewD, "count", 1)

		modelCountDrivenDC.sourceModel.clear()
		compare(modelCountDrivenDC.rowCount, 0)
		tryCompare(modelD, "count", 0)
		tryCompare(viewD, "count", 0)
	}

	function test_preferredVisibleFromDcOwnedStateObjects() {
		compare(modelE.count, 0)
		compare(viewE.count, 0)

		errorStateDC.commValid = true
		errorStateDC.commValue = 1
		tryCompare(modelE, "count", 1)
		tryCompare(viewE, "count", 1)

		errorStateDC.commValid = false
		errorStateDC.voltageValid = true
		errorStateDC.voltageValue = 1
		tryCompare(modelE, "count", 1)
		tryCompare(viewE, "count", 1)

		errorStateDC.voltageValid = false
		tryCompare(modelE, "count", 0)
		tryCompare(viewE, "count", 0)
	}

	function test_nestedComponentUsesDcOwnedState() {
		tryCompare(modelF, "count", 1)
		tryCompare(viewF, "count", 1)
		compare(nestedStateDC.sharedValue, 0)

		const subPage = nestedStateDC.subPageComponent.createObject(win, { stateOwner: nestedStateDC })
		verify(subPage !== null)

		subPage.toggle()
		compare(nestedStateDC.sharedValue, 1)

		nestedStateDC.rowVisible = false
		tryCompare(modelF, "count", 0)
		tryCompare(viewF, "count", 0)

		subPage.toggle()
		compare(nestedStateDC.sharedValue, 0)

		subPage.destroy()
	}

	// A hidden entry must not construct its delegate — that is the whole point of the
	// model, and nothing else in this file checks it.
	function test_hiddenEntryNeverConstructsItsDelegate() {
		compare(builtDC.rowVisible, false)
		tryCompare(modelG, "count", 0)
		compare(root.delegatesBuilt, 0)

		builtDC.rowVisible = true
		tryCompare(modelG, "count", 1)
		tryCompare(root, "delegatesBuilt", 1)
		verify(findChild(viewG, "G1") !== null)
	}

	// Hiding an entry must release and destroy the delegate it built, not merely cull
	// it. release() returning Destroyed is what makes the delegate's own lifetime
	// observable, so the destruction has to be asserted, not assumed.
	function test_hidingAnEntryDestroysItsDelegate() {
		builtDC.rowVisible = true
		tryCompare(modelG, "count", 1)
		tryCompare(root, "delegatesBuilt", 1)

		const destroyedBefore = root.delegatesDestroyed
		builtDC.rowVisible = false
		tryCompare(modelG, "count", 0)
		tryCompare(root, "delegatesDestroyed", destroyedBefore + 1)
		verify(findChild(viewG, "G1") === null)
	}
}
