import QtQuick
import QtQuick.Controls
import QtQuick.Effects

import gui 1.0

Rectangle {
    id: button
    color: COMMON.bg3
    property var icon
    property var iconColor: COMMON.bg6
    property var iconHoverColor: COMMON.fg0
    property bool disabled: false
    property var inset: 10
    property var tooltip: ""
    height: 35
    width: 35
    
    signal pressed();
    signal contextMenu();
    signal entered();
    signal exited();

    Rectangle {
        anchors.fill: parent
        visible: button.disabled
        color: "#c0101010"
    }

    MouseArea {
        anchors.fill: parent
        id: mouse
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: {
            if(disabled)
                return
            if (mouse.button === Qt.LeftButton) {
                button.pressed()
            } else {
                button.contextMenu()
            }
            
        }

        onEntered: {
            button.entered()
        }

        onExited: {
            button.exited()
        }
    }

    SToolTip {
        id: infoToolTip
        visible: !disabled && tooltip != "" && mouse.containsMouse
        delay: 100
        text: tooltip
    }

    Image {
        id: img
        source: icon
        width: parent.height - inset
        height: width
        sourceSize: Qt.size(parent.width, parent.height)
        anchors.centerIn: parent
        smooth: true
        antialiasing: true
        visible: false
    }

    MultiEffect {
        id: color
        source: img
        anchors.fill: img
        colorization: 1.0
        colorizationColor: disabled ? Qt.darker(iconColor) : (mouse.containsMouse ? iconHoverColor : iconColor)
    }
}
