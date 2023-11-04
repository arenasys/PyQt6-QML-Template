import QtQuick
import QtQuick.Effects

Item {
    required property var target
    anchors.fill: target
    anchors.margins: -5

    Rectangle {
        id: src
        anchors.fill: parent
        anchors.margins: 5
        visible: false
        color: "black"
    }

    MultiEffect {
        source: src
        anchors.fill: src
        shadowEnabled: true
        shadowBlur: 0.5
        shadowColor: "black"
    }
}