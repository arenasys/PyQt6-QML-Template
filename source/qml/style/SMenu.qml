import QtQuick
import QtQuick.Controls

import gui 1.0

Menu {
    id: root
    readonly property real menuItemSize: 20
    topPadding: 2
    bottomPadding: 2
    property var clipShadow: false

    property var pointSize: 10.6
    property var color: COMMON.fg1

    delegate: SMenuItem {
        pointSize: root.pointSize
        color: root.color
        menuItemSize: root.menuItemSize
    }

    background: Item {
        implicitWidth: 150
        implicitHeight: menuItemSize

        Item {
            clip: root.clipShadow
            anchors.fill: parent
            anchors.margins: -10
            anchors.topMargin: 0

            Item {
                id: src
                anchors.fill: parent
                anchors.margins: 10
                anchors.topMargin: 0
            }

            SGlow {
                target: src
            }
        }
        
        Rectangle {
            anchors.fill: parent
            color: COMMON.bg3
            border.width: 1
            border.color: COMMON.bg4
        }
    }

    
}
