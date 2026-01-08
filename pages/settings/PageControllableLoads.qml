/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
    id: root

    property alias model : listModel

    property VeQuickItem loads: VeQuickItem {
        uid: BackendConnection.serviceUidForType("opportunityloads") + "/AvailableServices"
        invalidate: true
        onValueChanged: {
            for (let i = 0; i < value.length; ++i) {
                listModel.set(i, value[i])
            }
            return
        }
    }

    component Arrow : ListItemButton {
        icon.source: "qrc:/images/icon_arrow.svg"
        flat: false
        height: parent.height - 2*Theme.geometry_opportunityLoad_margin
    }

    component DevicePriorityListNavigation : ListNavigation {
        id: devicePriorityDelegate

        property string pageSource: ""
        property string iconSource: ""
        property alias text: primary.text
        property alias secondaryText: secondary.text
        property var pageProperties: ({"title": Qt.binding(function() { return devicePriorityDelegate.text }) })

        height: Theme.geometry_settingsListNavigation_height
        onClicked: Global.pageManager.pushPage(devicePriorityDelegate.pageSource, devicePriorityDelegate.pageProperties)

        Arrow {
            id: upArrow

            anchors {
                left: parent.left
                leftMargin: Theme.geometry_opportunityLoad_margin
                verticalCenter: parent.verticalCenter
            }
            enabled: index !== 0
            onClicked: {
                console.log("up arrow clicked", index)
                root.model.move(index, index - 1, 1)
                listModel.writeToBackEnd()
            }
        }

        Arrow {
            id: downArrow

            anchors {
                left: upArrow.right
                leftMargin: Theme.geometry_opportunityLoad_margin
                verticalCenter: parent.verticalCenter
            }
            enabled: index !== (listView.count - 1)
            rotation: 180
            onClicked: {
                console.log("down arrow clicked", index)
                root.model.move(index + 1, index, 1)
                listModel.writeToBackEnd()
            }
        }

        Column {
            anchors {
                left: downArrow.right
                leftMargin: Theme.geometry_listItem_content_horizontalMargin
                verticalCenter: parent.verticalCenter
            }

            Label {
                id: primary

                font.pixelSize: Theme.font_size_body2
                wrapMode: Text.Wrap
                text: devicePriorityDelegate.primaryText
            }

            Label {
                id: secondary

                font.pixelSize: Theme.font_size_body1
                wrapMode: Text.Wrap
                color: Theme.color_font_secondary
                text: devicePriorityDelegate.secondaryText
            }
        }
    }

    GradientListView {
        interactive: false
        clip: true
        model: VisibleItemModel {
            SettingsColumn {
                width: parent ? parent.width : 0

                SettingsListHeader {
                    text: "Device Priority"
                }

                ListView {
                    id: listView

                    model: listModel
                    width: parent.width
                    implicitHeight: contentHeight
                    delegate: DevicePriorityListNavigation {
                        text: model.label || model.uniqueIdentifier || ""
                    }
                    move: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            easing.type: Easing.InOutQuad
                        }
                    }
                    displaced: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: listModel

        function writeToBackEnd() {
            var newValue = []
            for (var i = 0; i < listModel.count; ++i) {
                newValue.push(listModel.get(i))
            }

            console.log("*************************** writing", JSON.stringify(newValue))
            loads.setValue(newValue)
        }

        objectName: "PageControllableLoads.model"
        onCountChanged: console.log(objectName, "count:", count)
    }
}
