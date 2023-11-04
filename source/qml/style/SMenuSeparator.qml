import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import gui 1.0

MenuSeparator {
    height: visible ? 10 : 0
    contentItem: Item {
        Rectangle {
            x: -1
            width: parent.width+2
            height: 1
            color: COMMON.bg4
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}