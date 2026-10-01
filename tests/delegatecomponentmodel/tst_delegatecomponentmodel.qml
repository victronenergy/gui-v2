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

	component ViewportRow: DelegateComponent {
		id: viewportRow
		property string rowName
		delegate: Component {
			Rectangle {
				width: 200
				height: 20
				objectName: viewportRow.rowName
				Component.onCompleted: root.viewportDelegatesBuilt++
				Component.onDestruction: root.viewportDelegatesDestroyed++
			}
		}
	}

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

			// --- Test G: preferredVisible constructs and destroys ---
			//
			// ListView.count is just model.count, so the other tests would still
			// pass if object() and release() did nothing. These two count real
			// construction and destruction when preferredVisible changes. This
			// view is large enough that its one effective row is always in view;
			// viewport virtualization is Test K.
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

			// --- Test H: showAccessLevel filters without constructing ---
			ListView {
				id: viewH
				anchors.fill: parent
				model: DelegateComponentModel {
					id: modelH
					DelegateComponent {
						id: userLevelDC
						delegate: Component {
							Rectangle {
								width: 800
								height: 20
								objectName: "HUser"
								Component.onCompleted: root.userDelegatesBuilt++
							}
						}
					}
					DelegateComponent {
						id: serviceLevelDC
						showAccessLevel: VenusOS.User_AccessType_Service
						delegate: Component {
							Rectangle {
								width: 800
								height: 20
								objectName: "HService"
								Component.onCompleted: root.serviceDelegatesBuilt++
							}
						}
					}
				}
			}

			// --- Test I: an explicit effectiveVisible binding replaces the default ---
			ListView {
				id: viewI
				anchors.fill: parent
				model: DelegateComponentModel {
					id: modelI
					DelegateComponent {
						id: overriddenDC
						preferredVisible: true
						effectiveVisible: overrideVisible
						property bool overrideVisible: false
						delegate: Component {
							Rectangle {
								width: 800
								height: 20
								objectName: "I1"
							}
						}
					}
				}
			}

			// --- Test J: Component.onCompleted hides its own entry ---
			ListView {
				id: viewJ
				anchors.fill: parent
				model: DelegateComponentModel {
					id: modelJ
					DelegateComponent {
						delegate: Component {
							Rectangle {
								width: 800
								height: 20
								objectName: "JKeep"
							}
						}
					}
					DelegateComponent {
						id: selfHidingDC
						delegate: Component {
							Rectangle {
								width: 800
								height: 20
								objectName: "JHide"
								Component.onCompleted: {
									root.selfHideBuilt++
									selfHidingDC.preferredVisible = false
								}
								Component.onDestruction: root.selfHideDestroyed++
							}
						}
					}
				}
			}

			// --- Test K: viewport virtualization ---
			//
			// A short ListView with many visible rows. object() must not build
			// off-screen delegates, and release() must destroy them when they
			// scroll out. cacheBuffer is 0 so only the viewport is instantiated.
			ListView {
				id: viewK
				width: 200
				height: 50
				cacheBuffer: 0
				reuseItems: false
				interactive: false
				keyNavigationEnabled: false
				highlightFollowsCurrentItem: false
				// Default currentIndex 0 keeps that delegate alive after it
				// scrolls out of view, which would hide a missing release().
				currentIndex: -1
				model: DelegateComponentModel {
					id: modelK
					ViewportRow { rowName: "K0" }
					ViewportRow { rowName: "K1" }
					ViewportRow { rowName: "K2" }
					ViewportRow { rowName: "K3" }
					ViewportRow { rowName: "K4" }
					ViewportRow { rowName: "K5" }
					ViewportRow { rowName: "K6" }
					ViewportRow { rowName: "K7" }
					ViewportRow { rowName: "K8" }
					ViewportRow { rowName: "K9" }
				}
			}
		}
	}

	property int delegatesBuilt: 0
	property int delegatesDestroyed: 0
	property int userDelegatesBuilt: 0
	property int serviceDelegatesBuilt: 0
	property int selfHideBuilt: 0
	property int selfHideDestroyed: 0
	property int viewportDelegatesBuilt: 0
	property int viewportDelegatesDestroyed: 0

	// DCM delegates are visual children of the content item; they are not
	// always QObject children of the ListView, so TestCase.findChild can miss
	// them. Search the item tree instead.
	function listDelegate(view, name) {
		const children = view.contentItem.children
		for (let i = 0; i < children.length; ++i) {
			if (children[i].objectName === name) {
				return children[i]
			}
		}
		return null
	}

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

	// Default showAccessLevel is User, so the row stays in the model even when the
	// access-level setting is not connected (unit tests have no backend).
	function test_userAccessLevelRowStaysInTheModel() {
		compare(modelH.count, 1)
		compare(viewH.count, 1)
		tryCompare(root, "userDelegatesBuilt", 1)
		verify(findChild(viewH, "HUser") !== null)
	}

	// A Service-only row must be omitted without constructing its delegate when the
	// current access level is unknown or only User.
	function test_serviceAccessLevelRowIsOmittedWithoutConstructing() {
		compare(serviceLevelDC.effectiveVisible, false)
		compare(modelH.count, 1)
		compare(root.serviceDelegatesBuilt, 0)
		verify(findChild(viewH, "HService") === null)
	}

	function test_explicitEffectiveVisibleBindingReplacesTheDefault() {
		compare(overriddenDC.preferredVisible, true)
		compare(overriddenDC.effectiveVisible, false)
		compare(modelI.count, 0)

		overriddenDC.overrideVisible = true
		tryCompare(modelI, "count", 1)
		tryVerify(function() { return findChild(viewI, "I1") !== null })

		overriddenDC.overrideVisible = false
		tryCompare(modelI, "count", 0)
		tryVerify(function() { return findChild(viewI, "I1") === null })
	}

	// completeCreate() can hide this same entry from Component.onCompleted.
	// The model must destroy that delegate without publishing createdItem for a
	// row that is no longer in visibleEntries.
	function test_completedHidingOwnEntryDoesNotPublishTheDelegate() {
		tryCompare(modelJ, "count", 1)
		tryCompare(root, "selfHideBuilt", 1)
		tryCompare(root, "selfHideDestroyed", 1)
		tryVerify(function() { return findChild(viewJ, "JKeep") !== null })
		tryVerify(function() { return findChild(viewJ, "JHide") === null })
	}

	// A constrained ListView must not construct every effective row. Off-screen
	// delegates are built on scroll and released when they leave the viewport.
	function test_offScreenDelegatesAreNotBuiltUntilScrolledIntoView() {
		compare(modelK.count, 10)
		compare(viewK.count, 10)

		viewK.forceLayout()
		waitForRendering(viewK)
		tryVerify(function() { return listDelegate(viewK, "K0") !== null })
		verify(listDelegate(viewK, "K9") === null)
		verify(root.viewportDelegatesBuilt > 0)
		verify(root.viewportDelegatesBuilt < 10)

		const builtBeforeScroll = root.viewportDelegatesBuilt
		const destroyedBeforeScroll = root.viewportDelegatesDestroyed

		viewK.positionViewAtIndex(9, ListView.End)
		viewK.forceLayout()
		waitForRendering(viewK)

		tryVerify(function() { return listDelegate(viewK, "K9") !== null })
		tryVerify(function() { return listDelegate(viewK, "K0") === null })
		verify(root.viewportDelegatesBuilt > builtBeforeScroll)
		verify(root.viewportDelegatesDestroyed > destroyedBeforeScroll)

		viewK.positionViewAtIndex(0, ListView.Beginning)
		viewK.forceLayout()
		waitForRendering(viewK)

		tryVerify(function() { return listDelegate(viewK, "K0") !== null })
		tryVerify(function() { return listDelegate(viewK, "K9") === null })
	}
}
