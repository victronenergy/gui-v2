/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix: BackendConnection.uidPrefix()

	function jsonObjectTree(nodeUid, nodeId) {
		const childValues = childValuesLoader.allChildValues(nodeUid, nodeId)

		// If this is the root delegate for a service, strip the service uid from the
		// sub-paths, else each sub-path is like "/com.victronenergy.vebus.ttyUSB0/DeviceInstance"
		// instead of just "/DeviceInstance".
		let pathPrefixToStrip = ""
		let rootUid = nodeUid
		if (root.bindPrefix === BackendConnection.uidPrefix()) {
			pathPrefixToStrip = "/" + nodeId
			if (BackendConnection.type === BackendConnection.MqttSource) {
				// On MQTT, also strip the device instance, which is the first child id.
				pathPrefixToStrip += "/" + childValuesLoader.firstChildId
				// And use the mock uid format for the root service uid. Use something like
				// com.victronenergy.vebus.mock_123456, since it is not straightforward
				// to find the real suffix that should be used after the service type.
				const rand = Math.floor(Math.random() * 100000)
				rootUid = `com.victronenergy.${nodeId}.mock_${rand}`
			}
		}
		let normalizedJson = {}
		if (pathPrefixToStrip) {
			for (const key in childValues) {
				const normalizedKey = key.startsWith(pathPrefixToStrip) ? key.substring(pathPrefixToStrip.length) : key
				normalizedJson[normalizedKey] = childValues[key]
			}
		} else {
			normalizedJson = childValues
		}

		let objectTree = {}
		objectTree[rootUid] = normalizedJson
		return objectTree
	}

	GradientListView {
		model: VeQItemTableModel {
			id: uidModel
			uids: [bindPrefix]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem | VeQItemTableModel.UseLocalValues
		}

		delegate: ListNavigation {
			id: rowDelegate

			required property string uid
			required property string id
			required property var value

			text: id
			secondaryText: interactive ? "" : (JSON.stringify(value) ?? "--")
			caption: interactive || value === undefined ? "" : typeof(value)
			interactive: subModel.rowCount > 0

			// When 'P' is pressed, dump the stringified object tree from this node.
			// (If Shift+P is pressed, use a pretty print.)
			// When pressed on the root node of a service, this uses a com.victronenergy.<service.*
			// format for the root key, so that the output can be used as a service configuration
			// file in data/mock/conf/services.
			Keys.onPressed: (event) => {
				if (event.key !== Qt.Key_P) {
					event.accepted = false
					return
				}
				let outputJson = {}
				if (interactive) {
					outputJson = root.jsonObjectTree(rowDelegate.uid, rowDelegate.id)
				} else {
					outputJson[rowDelegate.id] = value
				}
				if (event.modifiers & Qt.ShiftModifier) {
					console.info(JSON.stringify(outputJson, null, 2)) // pretty print
				} else {
					console.info(JSON.stringify(outputJson))
				}
			}

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/debug/PageDebugVeQItems.qml",
						{ title: text, bindPrefix: rowDelegate.uid })
			}

			VeQItemTableModel {
				id: subModel
				uids: [rowDelegate.uid]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem | VeQItemTableModel.UseLocalValues
			}
		}
	}

	Loader {
		id: childValuesLoader

		property string rootNodeUid
		property string firstChildId

		function allChildValues(nodeUid, nodeId) {
			rootNodeUid = nodeUid
			firstChildId = ""
			active = true

			const childrenModel = item
			const uidPrefix = nodeUid.substring(0, nodeUid.length - nodeId.length - 1)
			let json = {}
			for (let i = 0; i < childrenModel.rowCount; ++i) {
				if (!firstChildId) {
					firstChildId = childrenModel.data(childrenModel.index(i, 0), VeQItemTableModel.IdRole)
				}
				let childValue = childrenModel.getValue(i, VeQItemTableModel.ValueColumn)
				if (childValue === undefined) {
					const childItem = childrenModel.data(childrenModel.index(i, 0), VeQItemTableModel.ItemRole)
					if (childItem.isLeaf) {
						// Replace 'undefined' with 'null', else the value is discarded by
						// JSON.stringify() as 'undefined' is not a valid JSON value.
						childValue = null
					} else {
						// This is a parent node, so do not include it in the JSON output.
						continue
					}
				}
				const childUid = childrenModel.data(childrenModel.index(i, 0), VeQItemTableModel.UniqueIdRole)
				const childPath = childUid.substring(uidPrefix.length)
				json[childPath] = childValue
			}

			active = false
			rootNodeUid = ""
			return json
		}

		active: false
		sourceComponent: VeQItemTableModel {
			uids: [childValuesLoader.rootNodeUid]
			flags: VeQItemTableModel.AddAllChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem | VeQItemTableModel.UseLocalValues
		}
	}
}
