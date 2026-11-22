/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest
import Victron.VenusOS

TestCase {
	id: root

	property var _objects: []

	name: "SlicedListModelTest"
	when: windowShown

	function createNameModel(names) {
		const model = listModelComponent.createObject(root)
		for (const name of names) {
			model.append({ name: name })
		}
		_objects.push(model)
		return model
	}

	function createSlicedModel(sourceModel, properties) {
		const model = slicedModelComponent.createObject(root, Object.assign({ sourceModel: sourceModel }, properties))
		SlicedListModelTestHelper.checkModel(model)
		_objects.push(model)
		return model
	}

	function createView(model) {
		const view = viewComponent.createObject(root, { model: model })
		_objects.push(view)
		view.forceLayout()
		return view
	}

	// Returns the name role of each row of the model.
	function names(model) {
		const role = SlicedListModelTestHelper.roleNumber(model, "name")
		let values = []
		for (let row = 0; row < model.rowCount(); ++row) {
			values.push(model.data(model.index(row, 0), role))
		}
		return values
	}

	function delegateNames(view) {
		let values = []
		for (let i = 0; i < view.count; ++i) {
			values.push(view.itemAtIndex(i).name)
		}
		return values
	}

	function cleanup() {
		for (const object of _objects.reverse()) {
			object.destroy()
		}
		_objects = []
	}

	function test_slice_data() {
		const source = ["a", "b", "c", "d", "e"]
		return [
			{ tag: "default: all rows", source: source, start: 0, count: -1, names: source },
			{ tag: "first rows", source: source, start: 0, count: 2, names: ["a", "b"] },
			{ tag: "middle rows", source: source, start: 1, count: 3, names: ["b", "c", "d"] },
			{ tag: "rest of the rows", source: source, start: 3, count: -1, names: ["d", "e"] },
			{ tag: "count past the end", source: source, start: 3, count: 10, names: ["d", "e"] },
			{ tag: "start past the end", source: source, start: 5, count: -1, names: [] },
			{ tag: "zero count", source: source, start: 1, count: 0, names: [] },
			{ tag: "negative start", source: source, start: -2, count: 2, names: ["a", "b"] },
			{ tag: "empty source", source: [], start: 0, count: 3, names: [] },
		]
	}

	function test_slice(data) {
		const model = createSlicedModel(createNameModel(data.source), { start: data.start, count: data.count })
		compare(names(model), data.names)
		compare(model.start, Math.max(data.start, 0))
	}

	function test_changeStartAndCount() {
		const model = createSlicedModel(createNameModel(["a", "b", "c", "d", "e"]), { count: 2 })
		compare(names(model), ["a", "b"])
		model.count = 4
		compare(names(model), ["a", "b", "c", "d"])
		model.start = 2
		compare(names(model), ["c", "d", "e"])
		model.count = -1
		compare(names(model), ["c", "d", "e"])
		model.start = 0
		compare(names(model), ["a", "b", "c", "d", "e"])
		model.count = 0
		compare(names(model), [])
	}

	function test_sourceRowsChanged() {
		const source = createNameModel(["a", "b", "c", "d", "e"])
		const first = createSlicedModel(source, { count: 2 })
		const rest = createSlicedModel(source, { start: 2 })

		// Rows inserted before the end of the first slice push its last rows into the rest.
		source.insert(0, { name: "x" })
		compare(names(first), ["x", "a"])
		compare(names(rest), ["b", "c", "d", "e"])

		// Rows inserted in the rest leave the first slice as it is.
		source.insert(4, { name: "y" })
		compare(names(first), ["x", "a"])
		compare(names(rest), ["b", "c", "y", "d", "e"])

		// Rows removed from the first slice pull rows from the rest into it.
		source.remove(0, 2)
		compare(names(first), ["b", "c"])
		compare(names(rest), ["y", "d", "e"])

		// Rows moved across the end of the first slice.
		source.move(4, 0, 1)
		compare(names(first), ["e", "b"])
		compare(names(rest), ["c", "y", "d"])

		// Changes to the data of a row are passed on.
		source.setProperty(0, "name", "z")
		compare(names(first), ["z", "b"])

		source.clear()
		compare(names(first), [])
		compare(names(rest), [])
	}

	function test_sourceModel() {
		const model = createSlicedModel(createNameModel(["a", "b", "c"]), { start: 1, count: 1 })
		compare(names(model), ["b"])
		model.sourceModel = createNameModel(["x", "y"])
		compare(names(model), ["y"])
		model.sourceModel = null
		compare(model.rowCount(), 0)
	}

	function test_viewKeepsDelegates() {
		const source = createNameModel(["a", "b", "c", "d"])
		const model = createSlicedModel(source, { count: 3 })
		const view = createView(model)
		compare(delegateNames(view), ["a", "b", "c"])
		const delegateA = view.itemAtIndex(0)
		const delegateB = view.itemAtIndex(1)

		// "c" moves out of the slice and "x" moves in; the delegates of "a" and "b" are kept.
		source.insert(0, { name: "x" })
		view.forceLayout()
		compare(delegateNames(view), ["x", "a", "b"])
		verify(view.itemAtIndex(1) === delegateA)
		verify(view.itemAtIndex(2) === delegateB)
	}

	Component {
		id: listModelComponent

		ListModel {}
	}

	Component {
		id: slicedModelComponent

		SlicedListModel {}
	}

	Component {
		id: viewComponent

		ListView {
			width: 100
			height: 1000
			delegate: Item {
				required property string name

				width: 100
				height: 10
			}
		}
	}
}
