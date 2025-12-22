/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
    id: root

    property alias model : model

    ListModel {
        id: model
        ListElement {
            configModel:"battery"
            deviceInstance:0
            label:"Battery"
            serviceType:"com.victronenergy.system"
            uniqueIdentifier:"battery"
        }
        ListElement {
            configModel:"shelly"
            deviceInstance:56
            serviceType:"com.victronenergy.acload"
            uniqueIdentifier:"shellyPro2PMPVHeat2_56"
        }
        ListElement {
            configModel:"shelly"
            deviceInstance:54
            serviceType:"com.victronenergy.acload"
            uniqueIdentifier:"shellyPro2PMPVHeat1_54"
        }
        ListElement {
            configModel:"shelly"
            deviceInstance:55
            serviceType:"com.victronenergy.acload"
            uniqueIdentifier:"shellyPro2PMPVHeat2_55"
        }
    }

    property VeQuickItem loads: VeQuickItem {
        uid: BackendConnection.serviceUidForType("opportunityloads") + "/AvailableServices"
        onUidChanged: console.log(uid, JSON.stringify(value))
        onValueChanged: console.log(uid, JSON.stringify(value))
    }

    component Arrow : ListItemButton {
        icon.source: "qrc:/images/icon_arrow.svg"
        flat: false
        height: parent.height - 8
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

        Behavior on y { NumberAnimation {} }

        Arrow {
            id: upArrow

            anchors {
                left: parent.left
                leftMargin: Theme.geometry_opportunityLoad_horizontalSpacing
                verticalCenter: parent.verticalCenter
            }
            enabled: index !== 0
            onClicked: {
                console.log("up arrow clicked", index)
                root.model.move(index, index - 1, 1)
            }
        }

        Arrow {
            id: downArrow

            anchors {
                left: upArrow.right
                leftMargin: Theme.geometry_opportunityLoad_horizontalSpacing
                verticalCenter: parent.verticalCenter
            }
            enabled: index !== (repeater.count - 1)
            rotation: 180
            onClicked: {
                console.log("down arrow clicked", index)
                root.model.move(index + 1, index, 1)
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
        model: VisibleItemModel {
            SettingsColumn {
                width: parent ? parent.width : 0

                SettingsListHeader {
                    id: osLargeFeatures
                    text: "Device Priority"
                }

                Repeater {
                    id: repeater

                    model: root.model
                    delegate: DevicePriorityListNavigation {
                        text: label || uniqueIdentifier || ""
                    }
                }
            }
        }
    }
}
