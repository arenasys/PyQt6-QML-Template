import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import gui 1.0

import "style"
import "components"

FocusReleaser {
    id: root
    anchors.fill: parent

    Connections {
        target: COORDINATOR
        function onProceed() {
            button.disabled = true
        }
    }

    Rectangle {
        anchors.fill: parent
        color: COMMON.bg00
    
        Column {
            anchors.centerIn: parent
            width: 300
            height: parent.height - 200

            SText {
                text: "Requirements"
                width: parent.width
                height: 40
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                pointSize: 10.8
                color: COMMON.fg1
            }

            Item {
                width: 300
                height: 200
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    anchors.bottomMargin: 0
                    border.color: COMMON.bg4
                    color: "transparent"
                    ListView {
                        id: packageList
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: COORDINATOR.packages
                        boundsBehavior: Flickable.StopAtBounds

                        ScrollBar.vertical: SScrollBarV {
                            id: scrollBar
                            policy: packageList.contentHeight > packageList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                        }

                        delegate: Rectangle {

                            color: (index % 2 == 0 ? COMMON.bg0 : COMMON.bg00)
                            width: packageList.width
                            height: 20

                            Rectangle {
                                color: "green"
                                anchors.fill: parent
                                opacity: 0.1
                                visible: COORDINATOR.installed.includes(modelData)
                            }

                            Rectangle {
                                color: "yellow"
                                anchors.fill: parent
                                opacity: 0.1
                                visible: COORDINATOR.installing == modelData
                                onVisibleChanged: {
                                    if(visible) {
                                        packageList.positionViewAtIndex(index, ListView.Contain)
                                    }
                                }
                            }

                            SText {
                                text: modelData.split(" @ ")[0]
                                width: parent.width
                                height: 20
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                pointSize: 9.8
                                color: COMMON.fg1
                            }
                        }
                    }
                }
            }

            SButton {
                id: button
                width: 300
                height: 30
                label: COORDINATOR.disable ? "Cancel" : (COORDINATOR.packages.length == 0 ? "Proceed" : "Install")
                
                onPressed: {
                    if(!COORDINATOR.disable) {
                        outputArea.text = ""
                    }
                    COORDINATOR.install()
                }   
            }

            SText {
                visible: COORDINATOR.needRestart
                text: "Restart required"
                width: parent.width
                height: 30
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                pointSize: 9.8
                color: COMMON.fg2
            }

            Item {
                width: parent.width
                height: 30
            }

            Rectangle {
                x: -parent.width
                width: parent.width*3
                height: 120
                border.width: 1
                border.color: COMMON.bg4
                color: "transparent"

                STextArea {
                    id: outputArea
                    anchors.fill: parent

                    area.color: COMMON.fg2
                    pointSize: 9.8
                    monospace: true

                    Connections {
                        target: COORDINATOR
                        function onOutput(output) {
                            outputArea.text += output + "\n"
                            outputArea.area.cursorPosition = outputArea.text.length-1
                        }
                    }
                }
            }

        }
    }
}