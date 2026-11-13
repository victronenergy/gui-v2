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

	name: "CombinedListModelTest"
	when: windowShown

	function createListModel(rows) {
		const model = listModelComponent.createObject(root)
		for (const row of rows) {
			model.append(row)
		}
		_objects.push(model)
		return model
	}

	function createNameModel(names) {
		return createListModel(names.map((name) => ({ name: name })))
	}

	// Returns a model that sorts and filters the rows of sourceModel when asked to.
	function createSortFilterModel(sourceModel) {
		const model = CombinedListModelTestHelper.createSortFilterModel()
		model.sourceModel = sourceModel
		_objects.push(model)
		return model
	}

	function createCombinedModel(firstModel, secondModel) {
		const model = combinedModelComponent.createObject(root, {
			firstModel: firstModel,
			secondModel: secondModel
		})
		CombinedListModelTestHelper.checkModel(model)
		_objects.push(model)
		return model
	}

	function createView(model) {
		const view = viewComponent.createObject(root, { model: model })
		_objects.push(view)
		view.forceLayout()
		return view
	}

	function roleNumber(model, roleName) {
		return CombinedListModelTestHelper.roleNumber(model, roleName)
	}

	// Returns the value of the role in each row of the model.
	function rowValues(model, roleName) {
		const role = roleNumber(model, roleName)
		let values = []
		for (let row = 0; row < model.rowCount(); ++row) {
			values.push(model.data(model.index(row, 0), role))
		}
		return values
	}

	function delegateTexts(view) {
		let texts = []
		for (let i = 0; i < view.count; ++i) {
			texts.push(view.itemAtIndex(i).text)
		}
		return texts
	}

	function cleanup() {
		for (const object of _objects.reverse()) {
			object.destroy()
		}
		_objects = []
		for (const spy of [modelResetSpy, layoutChangedSpy, secondModelChangedSpy]) {
			spy.clear()
			spy.target = null
		}
	}

	function test_rows() {
		const first = createListModel([{ name: "a", value: 1 }, { name: "b", value: 2 }])
		const second = createListModel([{ name: "c", url: "c.qml" }])
		const model = createCombinedModel(first, second)

		compare(model.count, 3)
		compare(rowValues(model, "fromSecondModel"), [false, false, true])
		compare(rowValues(model, "name"), ["a", "b", "c"])
		compare(rowValues(model, "value"), [1, 2, undefined])
		compare(rowValues(model, "url"), [undefined, undefined, "c.qml"])
	}

	function test_missingRows_data() {
		return [
			{ tag: "no models", first: null, second: null, names: [] },
			{ tag: "first model only", first: ["a", "b"], second: null, names: ["a", "b"] },
			{ tag: "second model only", first: null, second: ["c"], names: ["c"] },
			{ tag: "empty first model", first: [], second: ["c"], names: ["c"] },
			{ tag: "empty second model", first: ["a"], second: [], names: ["a"] },
		]
	}

	function test_missingRows(data) {
		const first = data.first === null ? null : createNameModel(data.first)
		const second = data.second === null ? null : createNameModel(data.second)
		const model = createCombinedModel(first, second)

		compare(model.count, data.names.length)
		compare(rowValues(model, "name"), data.names)
	}

	function test_rowChanges_data() {
		return [
			{
				tag: "insert into first model",
				change: (first, second) => first.insert(1, { name: "x" }),
				names: ["a", "x", "b", "c", "d"],
				fromSecondModel: [false, false, false, true, true]
			},
			{
				tag: "insert into second model",
				change: (first, second) => second.insert(0, { name: "x" }),
				names: ["a", "b", "x", "c", "d"],
				fromSecondModel: [false, false, true, true, true]
			},
			{
				tag: "remove from first model",
				change: (first, second) => first.remove(0),
				names: ["b", "c", "d"],
				fromSecondModel: [false, true, true]
			},
			{
				tag: "remove from second model",
				change: (first, second) => second.remove(1),
				names: ["a", "b", "c"],
				fromSecondModel: [false, false, true]
			},
			{
				tag: "clear first model",
				change: (first, second) => first.clear(),
				names: ["c", "d"],
				fromSecondModel: [true, true]
			},
			{
				tag: "move in first model",
				change: (first, second) => first.move(0, 1, 1),
				names: ["b", "a", "c", "d"],
				fromSecondModel: [false, false, true, true]
			},
			{
				tag: "move in second model",
				change: (first, second) => second.move(1, 0, 1),
				names: ["a", "b", "d", "c"],
				fromSecondModel: [false, false, true, true]
			},
			{
				tag: "change data in first model",
				change: (first, second) => first.setProperty(1, "name", "x"),
				names: ["a", "x", "c", "d"],
				fromSecondModel: [false, false, true, true]
			},
			{
				tag: "change data in second model",
				change: (first, second) => second.setProperty(0, "name", "x"),
				names: ["a", "b", "x", "d"],
				fromSecondModel: [false, false, true, true]
			},
		]
	}

	function test_rowChanges(data) {
		const first = createNameModel(["a", "b"])
		const second = createNameModel(["c", "d"])
		const model = createCombinedModel(first, second)

		data.change(first, second)
		compare(model.count, data.names.length)
		compare(rowValues(model, "name"), data.names)
		compare(rowValues(model, "fromSecondModel"), data.fromSecondModel)
	}

	function test_viewUpdatesChangedRoles() {
		// The two models give their roles the same numbers, so the view updates the right role only
		// if the changed role numbers are mapped to the role numbers of the combined model.
		const first = createListModel([{ name: "a" }])
		const second = createListModel([{ title: "b" }])
		compare(roleNumber(first, "name"), roleNumber(second, "title"))
		const view = createView(createCombinedModel(first, second))
		const secondModelDelegate = view.itemAtIndex(1)

		second.setProperty(0, "title", "c")
		compare(delegateTexts(view), ["a", "c"])
		verify(view.itemAtIndex(1) === secondModelDelegate)
	}

	function test_newRolesInListModel() {
		const first = createListModel([])
		const second = createListModel([{ url: "c.qml" }])
		const model = createCombinedModel(first, second)
		compare(roleNumber(model, "name"), -1)

		// A ListModel adds the roles of the first row that is added to it.
		first.append({ name: "a" })
		compare(rowValues(model, "name"), ["a", undefined])
		compare(rowValues(model, "url"), [undefined, "c.qml"])
	}

	function test_sourceModelReset() {
		const sortFilterModel = createSortFilterModel(createNameModel(["a", "b"]))
		const model = createCombinedModel(sortFilterModel, createNameModel(["c"]))
		modelResetSpy.target = model

		// The new rows have the same role names, so the model is not reset.
		sortFilterModel.sourceModel = createNameModel(["x"])
		compare(modelResetSpy.count, 0)
		compare(rowValues(model, "name"), ["x", "c"])

		// The new rows have other role names, so the model is reset to show them.
		sortFilterModel.sourceModel = createListModel([{ title: "y" }, { title: "z" }])
		compare(modelResetSpy.count, 1)
		compare(rowValues(model, "title"), ["y", "z", undefined])
		compare(rowValues(model, "name"), [undefined, undefined, "c"])
	}

	function test_sort_data() {
		return [
			{
				tag: "first model",
				sortSecond: false,
				unsortedNames: ["c", "a", "b"],
				names: ["a", "b", "c", "d"],
				keptRows: [2, 0, 1, 3]
			},
			{
				tag: "second model",
				sortSecond: true,
				unsortedNames: ["d", "a", "b"],
				names: ["c", "a", "b", "d"],
				keptRows: [0, 3, 1, 2]
			},
		]
	}

	function test_sort(data) {
		const sortFilterModel = createSortFilterModel(createNameModel(data.unsortedNames))
		const model = data.sortSecond
				? createCombinedModel(createNameModel(["c"]), sortFilterModel)
				: createCombinedModel(sortFilterModel, createNameModel(["d"]))
		layoutChangedSpy.target = model
		CombinedListModelTestHelper.keepIndexes(model)

		sortFilterModel.sortRole = roleNumber(sortFilterModel, "name")
		sortFilterModel.sort(0)
		compare(layoutChangedSpy.count, 1)
		compare(rowValues(model, "name"), data.names)
		compare(CombinedListModelTestHelper.keptRows(), data.keptRows)
	}

	function test_layoutChangeThatRemovesRows() {
		const names = createNameModel(["a", "b", "c"])
		const sortFilterModel = createSortFilterModel(names)
		sortFilterModel.filterRole = roleNumber(names, "name")
		sortFilterModel.filterRegularExpression = /^[^x]/
		const model = createCombinedModel(sortFilterModel, createNameModel(["d"]))
		CombinedListModelTestHelper.keepIndexes(model)

		// The model does not filter the changed row until it is invalidated, which changes its
		// layout.
		names.setProperty(1, "name", "x")
		compare(rowValues(model, "name"), ["a", "x", "c", "d"])
		sortFilterModel.invalidate()
		compare(rowValues(model, "name"), ["a", "c", "d"])

		// The rows of the first model were removed and inserted again. The row of the second
		// model was kept.
		compare(CombinedListModelTestHelper.keptRows(), [-1, -1, -1, 2])
	}

	function test_replaceModels() {
		const model = createCombinedModel(createNameModel(["a"]), createNameModel(["b"]))

		model.firstModel = createNameModel(["x", "y"])
		compare(rowValues(model, "name"), ["x", "y", "b"])
		model.secondModel = createListModel([{ title: "z" }])
		compare(rowValues(model, "name"), ["x", "y", undefined])
		compare(rowValues(model, "title"), [undefined, undefined, "z"])
		model.firstModel = null
		compare(rowValues(model, "title"), ["z"])
		compare(rowValues(model, "fromSecondModel"), [true])
	}

	function test_destroyedModel() {
		const first = createNameModel(["a", "b"])
		const model = createCombinedModel(first, createNameModel(["c"]))

		_objects.splice(_objects.indexOf(first), 1)
		first.destroy()
		tryCompare(model, "count", 1)
		compare(model.firstModel, null)
		compare(rowValues(model, "name"), ["c"])
	}

	function test_sameModel() {
		const shared = createNameModel(["a", "b"])
		const other = createNameModel(["c"])
		const warning = /firstModel and secondModel are the same model/

		ignoreWarning(warning)
		const model = createCombinedModel(shared, shared)
		compare(rowValues(model, "name"), ["a", "b"])
		compare(rowValues(model, "fromSecondModel"), [false, false])
		shared.insert(1, { name: "x" })
		shared.remove(0)
		compare(rowValues(model, "name"), ["x", "b"])

		// The rows of the second model are included again when the models are different.
		model.secondModel = other
		compare(rowValues(model, "name"), ["x", "b", "c"])
		ignoreWarning(warning)
		model.firstModel = other
		compare(rowValues(model, "name"), ["c"])
		model.firstModel = shared
		compare(rowValues(model, "name"), ["x", "b", "c"])
		compare(rowValues(model, "fromSecondModel"), [false, false, true])

		// Both models are cleared when the shared model is destroyed.
		ignoreWarning(warning)
		model.secondModel = shared
		secondModelChangedSpy.target = model
		_objects.splice(_objects.indexOf(shared), 1)
		shared.destroy()
		tryCompare(secondModelChangedSpy, "count", 1)
		compare(model.firstModel, null)
		compare(model.secondModel, null)
		compare(model.count, 0)
	}

	function test_viewKeepsDelegatesOfOtherModel_data() {
		return [
			{
				tag: "rows inserted",
				change: (names, sortFilterModel) => names.insert(0, { name: "x" }),
				texts: ["x", "a", "b", "c"]
			},
			{
				tag: "rows removed",
				change: (names, sortFilterModel) => names.remove(0),
				texts: ["b", "c"]
			},
			{
				tag: "model reset",
				change: (names, sortFilterModel) => sortFilterModel.sourceModel = createNameModel(["y"]),
				texts: ["y", "c"]
			},
			{
				tag: "rows sorted",
				change: (names, sortFilterModel) => sortFilterModel.sort(0, Qt.DescendingOrder),
				texts: ["b", "a", "c"]
			},
			{
				tag: "layout changed",
				change: (names, sortFilterModel) => sortFilterModel.invalidate(),
				texts: ["a", "b", "c"]
			},
		]
	}

	function test_viewKeepsDelegatesOfOtherModel(data) {
		const names = createNameModel(["a", "b"])
		const sortFilterModel = createSortFilterModel(names)
		sortFilterModel.sortRole = roleNumber(names, "name")
		const model = createCombinedModel(sortFilterModel, createListModel([{ title: "c" }]))
		const view = createView(model)
		const secondModelDelegate = view.itemAtIndex(2)
		compare(secondModelDelegate.text, "c")

		data.change(names, sortFilterModel)
		view.forceLayout()
		compare(delegateTexts(view), data.texts)
		verify(view.itemAtIndex(view.count - 1) === secondModelDelegate)
	}

	function test_viewReadsNewRoleNames() {
		// The model has no source model yet, so it has the default role names.
		const sortFilterModel = createSortFilterModel(null)
		const model = createCombinedModel(sortFilterModel, createListModel([{ title: "c" }]))
		const view = createView(model)
		compare(delegateTexts(view), ["c"])

		sortFilterModel.sourceModel = createNameModel(["a", "b"])
		view.forceLayout()
		compare(delegateTexts(view), ["a", "b", "c"])
	}

	SignalSpy {
		id: modelResetSpy
		signalName: "modelReset"
	}

	SignalSpy {
		id: layoutChangedSpy
		signalName: "layoutChanged"
	}

	SignalSpy {
		id: secondModelChangedSpy
		signalName: "secondModelChanged"
	}

	Component {
		id: listModelComponent

		ListModel {}
	}

	Component {
		id: combinedModelComponent

		CombinedListModel {}
	}

	Component {
		id: viewComponent

		ListView {
			width: 100
			height: 1000
			delegate: Item {
				required property bool fromSecondModel
				required property var model
				readonly property string text: (fromSecondModel ? model.title : model.name) ?? ""

				width: 100
				height: 10
			}
		}
	}
}
