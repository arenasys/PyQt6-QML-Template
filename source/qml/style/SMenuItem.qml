import QtQuick
import QtQuick.Controls
import QtQuick.Effects

import gui 1.0

MenuItem {
    id: menuItem
    implicitWidth: 150
    implicitHeight: menuItemSize
    
    property var pointSize: 10.6
    property var color: COMMON.fg1

    height: visible ? menuItemSize : 0

    property var shortcut: ""
    property var global: false
    property real menuItemSize: 20

    Shortcut {
        enabled: menuItem.global
        sequence: menuItem.shortcut
        onActivated: menuItem.triggered()
    }

    indicator: Item {
        implicitWidth: menuItemSize
        implicitHeight: menuItemSize
        Rectangle {
            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 6
            visible: menuItem.checkable
            color: COMMON.bg6

            border.color: COMMON.bg5
            border.width: 3

            Image {
                id: img
                width: 20
                height: 20
                anchors.centerIn: parent
                source: "../icons/tick.svg"
                sourceSize: Qt.size(parent.width, parent.height)
                visible: false
            }

            MultiEffect {
                id: color
                source: img
                anchors.fill: img
                visible:  menuItem.checked
                colorization: 1.0
                colorizationColor: COMMON.fg2
            }
        }
    }

    arrow: Canvas {
        x: parent.width - width
        implicitWidth: 20
        implicitHeight: 20
        visible: menuItem.subMenu
        renderStrategy: Canvas.Cooperative
        onPaint: {
            var ctx = getContext("2d")
            ctx.fillStyle = menuItem.highlighted ? "#ffffff" : "#aaa"
            ctx.moveTo(10, 6)
            ctx.lineTo(width - 5, height / 2)
            ctx.lineTo(10, height - 6)
            ctx.closePath()
            ctx.fill()
        }
    }

    contentItem: Item {
        SText {
            id: label
            height: parent.height
            width: implicitWidth
            leftPadding: menuItem.checkable ? menuItem.indicator.width : 8
            text: menuItem.text
            color: menuItem.color
            pointSize: menuItem.pointSize
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }
        
        SText {
            height: parent.height
            anchors.right: parent.right
            width: parent.width - label.width
            rightPadding: 8
            text: menuItem.shortcut
            pointSize: menuItem.pointSize - 0.7
            color: COMMON.fg2
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }
    }

    background: Rectangle {
        implicitWidth: 150
        implicitHeight: menuItemSize
        color: backgroundMouseArea.containsMouse ? COMMON.bg4 : "transparent"

        MouseArea {
            id: backgroundMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            preventStealing: true
        }
    }
}