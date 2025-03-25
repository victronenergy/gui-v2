/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property int spacing: Theme.geometry_controlCardsPage_spacing
	//publish below properties as internal properties are access externally
	property SwitchableOutputCardModel switchableOutputModel: SwitchableOutputCardModel {}
	property Instantiator modelGen

	implicitWidth: cards.implicitWidth

	Row {
		id:cards
		height: parent.height
		spacing: root.spacing

		Repeater {
			model: switchableOutputModel
			// delegate:Rectangle{
			// 	width: 200
			// 	height: 200
			// 	Column{
			// 		Label {
			// 			text: group
			// 		}
			// 		Repeater{
			// 			model:childModel
			// 			delegate: Label {
			// 				text: name
			// 			}
			// 		}
			// 	}
			// 	Component.onCompleted: {
			// 		console.log("SwO group>",group)
			// 		console.log("SwO childModel count>",childModel.rowCount())
			// 	}
			// }

			delegate: SwitchAuxCard {
				title.text: group
				model: childModel
			}
		}
	}

	modelGen: Instantiator {

		model: VeQItemSortTableModel {
			id: sortTable
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterFlags: VeQItemSortTableModel.FilterOffline
			filterRegExp: "\.SwitchableOutput\.[0-9]$"
			model: VeQItemTableModel {
				uids: BackendConnection.uidPrefix()
				flags: VeQItemTableModel.AddAllChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}

		onObjectRemoved: (index,object) => {
			object.removeFromList()
		}

		delegate: SwitchableOutputData {
			id: del
			readonly property string switchuid: model.uid
			onNameChanged: {
				if (status === Component.Ready){
					root.switchableOutputModel.setSwitchableOutputValue(switchuid, SwitchableOutputModel.NameRole, name)
				}
			}
			onGroupNameChanged: {
				if (status === Component.Ready){

					root.switchableOutputModel.setSwitchableOutputValue(switchuid, SwitchableOutputModel.GroupRole, groupName)
				}
			}
			onTypeChanged:{
				if (status === Component.Ready){
					root.switchableOutputModel.setSwitchableOutputValue(switchuid, SwitchableOutputModel.TypeRole, type)
				}
			}

			onOverviewVisibleChanged: {
				if (status === Component.Ready){
					if (overviewVisible){
						const values = {
							group: del.groupName,
							name: del.name,
							ch: del.switchChannel,
							switchType: del.type
						}
						if (!root.switchableOutputModel.setSwitchableOutput(model.uid, values))
						root.switchableOutputModel.addSwitchableOutput(model.uid, values)
					}else{
						root.switchableOutputModel.remove(model.uid)
					}
				}
			}

			Component.onCompleted: {
				const values = {
					group: del.groupName,
					name: del.name,
					refId: del.switchChannel,
					switchType: del.type
				}
				if (overviewVisible) root.switchableOutputModel.addSwitchableOutput(model.uid, values)
				//console.log(model.uid, del.groupName, del.name, switchChannel)
			}
			function removeFromList(){
				root.switchableOutputModel.remove(switchid)
			}
		}
	}
}
