/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
	id: root
	name: "PagePreloaderTest"

	property var _preloaders: []

	// Tiny types already in the VenusOS module. Compilation does not instantiate them.
	readonly property string validRelativeUrl: "/components/EmptyPageItem.qml"
	readonly property string validQrcUrl: "qrc:/qt/qml/Victron/VenusOS/components/FittedQuantityLabel.qml"
	readonly property string missingUrl: "qrc:/pagepreloader-missing.qml"

	Component {
		id: preloaderComponent
		PagePreloader {}
	}

	function createPreloader(props) {
		const p = preloaderComponent.createObject(root, props)
		verify(p)
		_preloaders.push(p)
		return p
	}

	function init() {
		Global.pagePreloadComplete = false
		_preloaders = []
	}

	function cleanup() {
		for (let i = 0; i < _preloaders.length; ++i) {
			const p = _preloaders[i]
			if (p) {
				p.active = false
				p.destroy()
			}
		}
		_preloaders = []
		Global.pagePreloadComplete = false
	}

	function test_skipCompileDefaultsToUiTestConfiguration() {
		const p = createPreloader({})
		compare(UiTest.status, UiTest.NotConfigured)
		compare(p.skipCompile, false)
	}

	function test_skipCompileDoesNotCompileUrls() {
		const p = createPreloader({
			skipCompile: true,
			pageUrls: [missingUrl],
		})
		p.active = true
		compare(Global.pagePreloadComplete, true)
		compare(p.compiledCount, 0)
	}

	function test_emptyUrlsCompletesWithoutCompile() {
		const p = createPreloader({
			skipCompile: false,
			pageUrls: [],
		})
		p.active = true
		compare(Global.pagePreloadComplete, true)
		compare(p.compiledCount, 0)
	}

	function test_compilesInjectedUrlsAndCompletes() {
		const p = createPreloader({
			skipCompile: false,
			pageUrls: [validRelativeUrl, validQrcUrl],
			timeoutMs: 5000,
		})
		p.active = true
		tryCompare(Global, "pagePreloadComplete", true)
		compare(p.compiledCount, 2)
	}

	function test_badUrlDoesNotStall() {
		ignoreWarning(/PagePreloader: failed to compile/)
		const p = createPreloader({
			skipCompile: false,
			pageUrls: [validRelativeUrl, missingUrl],
			timeoutMs: 5000,
		})
		p.active = true
		tryCompare(Global, "pagePreloadComplete", true)
		compare(p.compiledCount, 1)
	}

	function test_timeoutCompletesWhenCompileDoesNotAdvance() {
		ignoreWarning(/PagePreloader: timed out after/)
		const p = createPreloader({
			skipCompile: false,
			pageUrls: [validRelativeUrl],
			timeoutMs: 50,
			compileOnActive: false,
		})
		p.active = true
		compare(Global.pagePreloadComplete, false)
		compare(p.compiledCount, 0)
		tryCompare(Global, "pagePreloadComplete", true)
		compare(p.compiledCount, 0)
	}

	function test_doesNotRecompileOnceComplete() {
		const p = createPreloader({
			skipCompile: false,
			pageUrls: [validRelativeUrl],
			timeoutMs: 5000,
		})
		p.active = true
		tryCompare(Global, "pagePreloadComplete", true)
		compare(p.compiledCount, 1)
		p.active = false
		p.active = true
		compare(p.compiledCount, 1)
	}
}
