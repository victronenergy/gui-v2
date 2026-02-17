/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ControlCard {
	id: root

	required property IOChannelGroup group
	readonly property Item currentItem: Global.keyNavigationEnabled && activeFocus ? channelGrid.currentItem : null

	implicitWidth: Math.max(channelGrid.width, Theme.geometry_controlCard_minimumWidth)
	icon.source: "qrc:/images/icon_switch_24.svg"
	title.text: root.group?.name ?? ""

	GridView {
		id: channelGrid

		readonly property int rowCount: Math.floor(height / cellHeight)
		readonly property int columnCount: Math.ceil(count / Math.max(1, rowCount))

		anchors {
			top: root.title.bottom
			bottom: parent.bottom
			topMargin: Theme.geometry_iochannel_topMargin
		}
		width: cellWidth * columnCount
		cellWidth: Theme.geometry_controlCard_minimumWidth
		cellHeight: (height - Theme.geometry_controlCard_contentMargins) / Theme.geometry_iochannel_row_count
		interactive: false
		flow: GridView.FlowTopToBottom
		focus: Global.keyNavigationEnabled
		keyNavigationEnabled: Global.keyNavigationEnabled
		model: root.group?.channels ?? []

		delegate: BaseListLoader {
			id: delegateLoader

			required property IOChannel modelData
			readonly property int type: modelData.type
			property string _lastLoadedUrl

			function _reload() {
				let componentUrl = ""
				if (type >= 0) {
					if (modelData.direction === IOChannel.Input) {
						componentUrl = "delegates/GenericInputCardDelegate_%1.qml".arg(type)
					} else {
						if (type >= VenusOS.SwitchableOutput_Type_ColorDimmerRgb
								&& type <= VenusOS.SwitchableOutput_Type_ColorDimmerRgbW) {
							// For color wheel delegates, the output type can be changed from within the
							// delegate, so load a type that encapsulates multiple types.
							componentUrl = "delegates/SwitchableOutputCardDelegate_color.qml"
						} else {
							// For other types, load a fixed filename according to the output type.
							componentUrl = "delegates/SwitchableOutputCardDelegate_%1.qml".arg(type)
						}
					}
				}

				// Only reload the source if the required file changes; otherwise, when a color
				// output changes while the ColorWheelDialog is open within the delegate, the UI
				// attempts to change the delegate source while its dialog is still open.
				if (_lastLoadedUrl !== componentUrl) {
					if (componentUrl) {
						if (modelData.direction === IOChannel.Input) {
							delegateLoader.setSource(componentUrl, {
								width: Qt.binding(function() { return channelGrid.cellWidth }),
								height: Qt.binding(function() { return channelGrid.cellHeight }),
								genericInput: modelData,
							})
						} else {
							delegateLoader.setSource(componentUrl, {
								width: Qt.binding(function() { return channelGrid.cellWidth }),
								height: Qt.binding(function() { return channelGrid.cellHeight }),
								switchableOutput: modelData,
								enabled: Qt.binding(function() { return !(modelData.status & VenusOS.SwitchableOutput_Status_Disabled) })
							})
						}
					} else {
						source = ""
					}
					_lastLoadedUrl = componentUrl
				}
			}

			// Allow this to receive the focus highlight for navigational purposes. The internal
			// loaded item should set its enabled=false when the output is disabled.
			KeyNavigationHighlight.active: activeFocus

			onStatusChanged: {
				if (status === Loader.Error) {
					if (modelData.direction === IOChannel.Input) {
						console.warn("Failed to load GenericInputDelegate for type '%1' from file: %2"
							.arg(VenusOS.genericInput_typeToText(modelData.type))
							.arg(source))
					} else {
						console.warn("Failed to load SwitchableOutputDelegate for type '%1' from file: %2"
							.arg(VenusOS.switchableOutput_typeToText(modelData.type))
							.arg(source))
					}
				}
			}

			onTypeChanged: _reload()
			Component.onCompleted: _reload()
		}
	}
}
