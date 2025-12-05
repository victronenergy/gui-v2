/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

MouseArea {

    property Item clickTarget: parent
    property bool sendMouse: false

    propagateComposedEvents: true
    onClicked: function(mouse) {
        if (sendMouse) {
            clickTarget.clicked(mouse)
        } else {
            clickTarget.clicked()
        }
    }
}
