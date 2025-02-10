/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListModel {
	id: root

	readonly property Instantiator switchDevObjects: Instantiator {
		model: Global.switches.model.count

		onObjectRemoved: (index,object)=> {
			object.switchObjects.removeAll ()
		}

		delegate: QtObject {
			id: switchDevDelegate
			property SwitchDev device: Global.switches.model.deviceAt(index)
			property string devName: device ? device.name : ""
			onDevNameChanged:{
				if (devName.length>22) shortDevName = devName.substring(0,11) +"..." + devName.substring(devName.length - 8,devName.length)
				else shortDevName = devName
			}
			property string shortDevName

			readonly property Instantiator switchObjects:Instantiator {
				function removeAll (){
					for(let i=0;i<count;i++){
						objectAt(i).removeFromList()
					}
				}

				model: switchDevDelegate.device ? switchDevDelegate.device.channels : 0
				delegate: QtObject {
					property var _store: null  //holds the current group this switch object is in
					readonly property string switchuid: model.uid
					property bool customGp: _groupName.isValid && _groupName.value!==""
					property string groupName: customGp ? _groupName.value : devName
					property string name: _customName.valueValid
										 ? _customName.value
										 : customGp
										   //% "%2|Ch %1"
										   ? qsTrId("Switches_InGroupDefaultName").arg(index + 1).arg(shortDevName)
										   //% "Channel %1"
										   : qsTrId("Switches_NonGroupDefaultName").arg(index + 1)
					onNameChanged: {
						if (_store !== null){
							_store = updateList(switchuid, _store, groupName, name)
						}
					}
					readonly property VeQuickItem _groupName: VeQuickItem {
						uid: model.uid + "/GroupName"
						property bool valueValid: isValid &&  value!==""
					}
					onGroupNameChanged: {
						if (_store !== null){
							_store = updateList(switchuid, _store, groupName, name)
						}
					}
					readonly property VeQuickItem _customName: VeQuickItem {
						uid: model.uid + "/CustomName"
						property bool valueValid: isValid &&  value!==""
					}

					readonly property VeQuickItem _Function: VeQuickItem {
						uid: model.uid + "/Function"
						property bool valueValid: isValid &&  ((value==VenusOS.Switch_Function_Momentary)
													|| (value==VenusOS.Switch_Function_Latching)
													|| (value==VenusOS.Switch_Function_Dimmable))
						onValueValidChanged: {
							if (status === Component.Ready){
								if (valueValid){
									_store = updateList(switchuid, _store, groupName, name )
								}else{
									removeFromList()
									_store = null
								}
							}
						}
					}

					Component.onCompleted: {
						if (_Function.valueValid){
							_store = updateList(switchuid, groupName, groupName, name )
						}
					}

					function removeFromList(){
						let data = null
						for (let i = 0; i < root.count; i++) {
							data = root.get(i)
							for(let isub = 0; isub < data.viewModel.count; isub++){
								if (data.viewModel.get(isub).uid === switchuid){
									data.viewModel.remove(isub, 1)
									if (data.viewModel.count===0) remove(i)
									return
								}
							}
						}
					}

					function updateList(switchuid, oldGroupName, switchGroupName, name) {
						let groupIndex = 0
						let groupCount = 0
						let itemIndex = -1
						let i = 0
						let data = null
						let itemId = null
						let isub
						if (oldGroupName !== switchGroupName){
							for (i = 0; i < root.count; i++) {
								data = root.get(i)
								if (data.cardName === oldGroupName){
									for(isub = 0; isub < data.viewModel.count; isub++){
										itemId = data.viewModel.get(isub).uid
										if (data.viewModel.get(isub).uid === switchuid){
											data.viewModel.remove(isub, 1)
											if (data.viewModel.count===0) remove(i)
											break
										}
									}
									break
								}
							}
						}
						for (i = 0; i < root.count; i++) {
							data = root.get(i)
							if (data.cardName >= switchGroupName){
								if (data.cardName === switchGroupName){
									for(isub = 0; isub < data.viewModel.count; isub++){
										if (data.viewModel.get(isub).uid === switchuid){
											data.viewModel.remove(isub)
											break
										}
									}
									for(isub = 0; isub < data.viewModel.count; isub++){
										if (data.viewModel.get(isub).name > name){
											data.viewModel.insert(isub,{"uid": switchuid,"name": name})
											break
										}
									}
									if (isub === data.viewModel.count) data.viewModel.append({"uid": switchuid,"name": name})
									itemIndex = i
									break
								}else{
									//new group
									root.insert(i,{"cardName": switchGroupName,"viewModel":[{"uid": switchuid, "name": name}]})
									itemIndex = i
									break
								}
							}
						}
						if (i == root.count){
							root.append ({"cardName": switchGroupName,"viewModel":[{"uid": switchuid, "name": name}]})
						}
						return switchGroupName
					}
				}
			}
		}
	}
}
