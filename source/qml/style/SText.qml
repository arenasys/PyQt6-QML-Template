import QtQuick
import QtQuick.Controls

import gui 1.0

Text {
    FontLoader {
        source: "../fonts/Cantarell-Regular.ttf"
    }
    FontLoader {
        source: "../fonts/Cantarell-Bold.ttf"
    }
    FontLoader {
        source: "../fonts/SourceCodePro-Regular.ttf"
    }

    property var pointSize: 10.8

    property var monospace: false
    font.family: monospace ? "Source Code Pro" : "Cantarell"
    font.pointSize: pointSize * COORDINATOR.scale
    color: COMMON.fg0

    Component.onCompleted: {
        if(font.bold && font.letterSpacing == 0) {
            font.letterSpacing = -1.0
        }
    }
}