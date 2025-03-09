/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListModel {
	id: root

	readonly property Instantiator switchDevObjects: Instantiator {
		model: Global.switches.model

		onObjectRemoved: (index,object) => {
			object.switchObjects.removeAll()
		}

		delegate: QtObject {
			id: switchDevDelegate
			property SwitchDevice device: Global.switches.model.deviceAt(index)
			property string devName: device ? device.name : ""
			onDevNameChanged:{
				//if device name likely overlap status in SwitchDeligate elide text to 22 char long
				// retain start and end of text as version and instance are likely to be on end
				// ie default name with VRM instance of 5 "Energy Solutions Smart Switch 11" shortens to "Energy Solut...Switch 5"
				if (devName.length > 22) {
					shortDevName = devName.substring(0,11) +"..." + devName.substring(devName.length - 8,devName.length)
				} else {
					shortDevName = devName
				}
			}
			property string shortDevName

			readonly property Instantiator switchObjects:Instantiator {
				function removeAll () {
					for(let i = 0; i < count; i++){
						objectAt(i).removeFromList()
					}
				}

				model: switchDevDelegate.device ? switchDevDelegate.device.switchableOutputs : 0
				delegate: QtObject {
					property var _store: null  //holds the current group this switch object is in
					readonly property string switchuid: model.uid
					property bool customGp: _groupName.isValid && _groupName.value!==""
					property string groupName: customGp ? _groupName.value : devName
					property string name: _customName.valueValid
										 ? _customName.value
										 : customGp
										   //: %1 is the channel of the device, %2 is the device name
										   //% "%2|Ch %1"
										   ? qsTrId("Switches_InGroupDefaultName").arg(index + 1).arg(shortDevName)
										   //% "Channel %1"
										   : qsTrId("Switches_NonGroupDefaultName").arg(index + 1)
					onNameChanged: {
						if (_store !== null) {
							_store = updateList(switchuid, _store, groupName, name)
						}
					}
					readonly property VeQuickItem _groupName: VeQuickItem {
						uid: model.uid + "/Settings/Group"
						property bool valueValid: isValid &&  value!==""
					}
					onGroupNameChanged: {
						if (_store !== null){
							_store = updateList(switchuid, _store, groupName, name)
						}
					}
					readonly property VeQuickItem _customName: VeQuickItem {
						uid: model.uid + "/Settings/CustomName"
						property bool valueValid: isValid &&  value!==""
					}

					readonly property VeQuickItem _Type: VeQuickItem {
						uid: model.uid + "/Settings/Type"
						property bool valueValid: isValid &&  ((value == VenusOS.SwitchableOutput_Function_Momentary)
													|| (value == VenusOS.SwitchableOutput_Function_Latching)
													|| (value == VenusOS.SwitchableOutput_Function_Dimmable))
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
						if (_Type.valueValid){
							_store = updateList(switchuid, groupName, groupName, name )
						}
					}
					// remove this switchable service from the model
					function removeFromList() {
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
					//model is structured to provide a an ordered list of all the different groupNames
					//with each list containing a ordered list of switchable services which are to be populated on the card with that groupName
					function updateList(switchuid, oldGroupName, switchGroupName, name) {
						let groupIndex = 0
						let groupCount = 0
						let itemIndex = -1
						let i = 0
						let data = null
						let itemId = null
						let isub
						//if groupname changed used its switch uid to remove old group list
						if (oldGroupName !== switchGroupName) {
							for (i = 0; i < root.count; i++) {
								data = root.get(i)
								if (data.cardName === oldGroupName){
									for (isub = 0; isub < data.viewModel.count; isub++)  {
										itemId = data.viewModel.get(isub).uid
										if (data.viewModel.get(isub).uid === switchuid) {
											data.viewModel.remove(isub, 1)
											if (data.viewModel.count===0) remove(i)
											break
										}
									}
									break
								}
							}
						}
						//find list that switchable service should be add to
						for (i = 0; i < root.count; i++) {
							data = root.get(i)
							if (data.cardName >= switchGroupName){ // find Alphabetical place
								if (data.cardName === switchGroupName){
									//Add to existing group list
									//posible name change remove from list using uid
									for (isub = 0; isub < data.viewModel.count; isub++) {
										if (data.viewModel.get(isub).uid === switchuid) {
											data.viewModel.remove(isub)
											break
										}
									}
									//find Alphabetical place and insert in correct position
									for(isub = 0; isub < data.viewModel.count; isub++){
										if (data.viewModel.get(isub).name > name) {
											data.viewModel.insert(isub,{"uid": switchuid,"name": name})
											break
										}
									}
									//Alphabetical place beyond end of list so append to end
									if (isub === data.viewModel.count) data.viewModel.append({"uid": switchuid,"name": name})
									itemIndex = i
									break
								} else {
									//new group
									root.insert(i,{"cardName": switchGroupName,"viewModel":[{"uid": switchuid, "name": name}]})
									itemIndex = i
									break
								}
							}
						}
						//Groups Alphabetical place beyond end of list so create new group list
						if (i == root.count) {
							root.append ({"cardName": switchGroupName,"viewModel":[{"uid": switchuid, "name": name}]})
						}
						return switchGroupName
					}
				}
			}
		}
	}
}
