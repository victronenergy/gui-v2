/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
    id: root

    property alias model : model
    readonly property var backendValue: loads.valid ? loads.value : []
    property var _loads: ({})

    property var jsonArray: [
        {
            "controllable":true,
            "deviceInstance":0,
            "label":"Battery",
            "serviceType":"system",
            "uniqueIdentifier":"battery"
        },
        {
            "controllable":true,
            "deviceInstance":56,
            "serviceType":"acload",
            "uniqueIdentifier":
            "shellyPro2PMPVHeat2_56"
        },
        {
            "controllable":true,
            "deviceInstance":54,
            "serviceType":"acload",
            "uniqueIdentifier":"shellyPro2PMPVHeat1_54"
        },
        {
            "controllable":true,
            "deviceInstance":55,
            "serviceType":"acload",
            "uniqueIdentifier":"shellyPro2PMPVHeat2_55"
        }
    ]

    property var jsonArray2: [
        {
            controllable:true,
            deviceInstance:0,
            label:"Battery",
            serviceType:"system",
            uniqueIdentifier:"battery"
        },
        {
            controllable:true,
            deviceInstance:56,
            serviceType:"acload",
            uniqueIdentifier:"shellyPro2PMPVHeat2_56"
        },
        {
            controllable:true,
            deviceInstance:54,
            serviceType:"acload",
            uniqueIdentifier:"shellyPro2PMPVHeat1_54"
        },
        {
            controllable:true,
            deviceInstance:55,
            serviceType:"acload",
            uniqueIdentifier:"shellyPro2PMPVHeat2_55"
        }
    ]

    function writeModel() {
        var newValue = []
        let changesPending = model.count !== backendValue.length
        for (var i = 0; i < model.count && !changesPending; ++i) {
            newValue.push(model.get(i))
            changesPending |= (model.get(i) != backendValue[i])
        }

        if (changesPending) {
            console.log("writing", JSON.stringify(newValue))
            //loads.setValue(JSON.stringify(newValue))
        }
    }

    property VeQuickItem loads: VeQuickItem {
        uid: BackendConnection.serviceUidForType("opportunityloads") + "/AvailableServices"
        invalidate: true
        onValueChanged: {
            console.log(uid, "onValueChanged:", !!value ? value : "null", !!value && value.length ? value.length : "unknown length")
            let jsonObject
            try {
                jsonObject = JSON.parse(value)
            } catch (e) {
                console.warn("Unable to parse data from", uid)
                if (!!value && value.length) {
                    for (var i = 0; i < value.length; ++i) {
                        try {
                            console.log(JSON.stringify(value[i]))
                        } catch (e) {
                            console.warn("Unable to parse data from index", i)
                        }
                    }
                }

                return
            }
            _loads = jsonObject
            listView.model = Object.keys(jsonObject)
        }
        Component.onCompleted: {
            console.log("*** calling loads.setValue", JSON.stringify(jsonArray))
            //loads.setValue("")
            loads.setValue(JSON.stringify(jsonArray))
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
                writeModel()
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
                writeModel()
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

                    onModelChanged: {
                        console.log("********** onModelChanged:", JSON.stringify(model))
                    }

                    width: parent.width
                    implicitHeight: contentHeight
                    delegate: DevicePriorityListNavigation {

                        text: _loads[modelData].label || _loads[modelData].uniqueIdentifier || ""
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
        id: model

        objectName: "PageControllableLoads.model"
        onCountChanged: console.log(objectName, "count:", count)
        /*
        ListElement {
            controllable: true
            deviceInstance: 0
            label: "Battery"
            serviceType: "system"
            uniqueIdentifier:"battery"
        }
        ListElement {
            controllable:true
            deviceInstance:56
            serviceType:"acload"
            uniqueIdentifier:"shellyPro2PMPVHeat2_56"
        }
        ListElement {
            controllable:true
            deviceInstance:54
            serviceType:"acload"
            uniqueIdentifier:"shellyPro2PMPVHeat1_54"
        }
        ListElement {
            controllable:true
            deviceInstance:55
            serviceType:"acload"
            uniqueIdentifier:"shellyPro2PMPVHeat2_55"
        }
        */
    }
}
