import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import gui 1.0

import "style"
import "components"

FocusReleaser {
    property var window
    anchors.fill: parent  
    
    Component.onCompleted: {
        window.title = Qt.binding(function() { return GUI.title; })
    }

    Rectangle {
        id: root
        anchors.fill: parent
        color: COMMON.bg0
    }

    WindowBar {
        id: windowBar
        anchors.left: root.left
        anchors.right: root.right
    }

    Item {
        id: main
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: windowBar.bottom
        anchors.bottom: parent.bottom

        Item {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 20

            width: Math.max(200, parent.width - 40)
            height: Math.max(200, parent.height - 40)

            Rectangle {
                id: imageBox
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: textBox.top
                anchors.bottomMargin: 5

                border.width: 1
                border.color: COMMON.bg4
                color: COMMON.bg0
                clip: true

                Rectangle {
                    id: imageBoxHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 25
                    border.width: 1
                    border.color: COMMON.bg4
                    color: COMMON.bg3
                    
                    SText {
                        anchors.fill: parent
                        text: "Image area"
                        color: COMMON.fg1_5
                        leftPadding: 5
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MovableItem {
                    id: imageBoxArea
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: imageBoxHeader.bottom
                    anchors.bottom: parent.bottom
                    anchors.margins: 2
                    anchors.topMargin: 1
                    
                    itemWidth: 200
                    itemHeight: 200

                    SGlow {
                        target: imageBoxArea.item
                    }

                    Rectangle {
                        anchors.fill: imageBoxArea.item
                        color: COMMON.bg0
                        border.width: 1
                        border.color: COMMON.bg4

                        Image {
                            source: "icons/placeholder_color.svg"
                            height: parent.width/2
                            width: height
                            sourceSize: Qt.size(width*1.25, height*1.25)
                            anchors.centerIn: parent
                        }
                    }
                }
            }

            Rectangle {
                id: textBox
                anchors.right: sqlBox.left
                anchors.bottom: parent.bottom
                width: Math.max(150, sqlBox.x - 5)
                height: 150
                anchors.rightMargin: 5

                border.width: 1
                border.color: COMMON.bg4
                color: COMMON.bg0
                clip: true

                Rectangle {
                    id: textBoxHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 25
                    border.width: 1
                    border.color: COMMON.bg4
                    color: COMMON.bg3
                    
                    SText {
                        anchors.fill: parent
                        text: "Text area"
                        color: COMMON.fg1_5
                        leftPadding: 5
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                STextArea {
                    id: textBoxArea
                    color: COMMON.bg1
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: textBoxHeader.bottom
                    anchors.bottom: parent.bottom
                    anchors.margins: 1
                    text: "Blah Blah"
                }
            }

            Rectangle {
                id: sqlBox
                anchors.right: updateBox.left
                anchors.bottom: parent.bottom
                anchors.rightMargin: 5
                height: 150
                width: 300

                border.width: 1
                border.color: COMMON.bg4
                color: COMMON.bg0
                clip: true

                Rectangle {
                    id: sqlBoxHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 25
                    border.width: 1
                    border.color: COMMON.bg4
                    color: COMMON.bg3
                    
                    SText {
                        anchors.fill: parent
                        text: "SQL area"
                        color: COMMON.fg1_5
                        leftPadding: 5
                        verticalAlignment: Text.AlignVCenter
                    }

                    SIconButton {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.margins: 1
                        height: 23
                        width: 23
                        tooltip: "Populate"
                        icon: "../icons/placeholder.svg"
                        inset: 8
                        onPressed: {
                            GUI.populateDatabase()
                        }
                    }
                }

                Rectangle {
                    id: sqlBoxArea
                    color: COMMON.bg1
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: sqlBoxHeader.bottom
                    anchors.bottom: parent.bottom
                    anchors.margins: 1
                    anchors.topMargin: 0

                    ListView {
                        id: sqlListView
                        interactive: false
                        boundsBehavior: Flickable.StopAtBounds
                        displayMarginBeginning: 1
                        displayMarginEnd: 1
                        clip: true
                        width: parent.width
                        height: Math.min(contentHeight, parent.height)

                        model: Sql {
                            query: "SELECT * FROM data ORDER BY idx DESC;"
                        }

                        ScrollBar.vertical: SScrollBarV {
                            id: scrollBar
                            stepSize: 1/Math.ceil(sqlListView.contentHeight/20)
                            policy: sqlListView.contentHeight > sqlListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            onWheel: (wheel)=> {
                                if(wheel.angleDelta.y < 0) {
                                    scrollBar.increase()
                                } else {
                                    scrollBar.decrease()
                                }
                            }
                        }

                        delegate: Item {
                            width: sqlListView.width
                            height: 20

                            Rectangle {
                                anchors.fill: parent
                                anchors.leftMargin: 11
                                anchors.rightMargin: 11
                                color: (index % 2 == 0 ? COMMON.bg1 : COMMON.bg0)

                                Row {
                                    anchors.fill: parent
                                    property var size: width / 3 - 1
                                    Rectangle {
                                        width: 1
                                        height: 20
                                        color: COMMON.bg4
                                    }
                                    SText {
                                        text: sql_a
                                        height: 20
                                        width: parent.size
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        pointSize: 9.8
                                        color: COMMON.fg1
                                    }
                                    Rectangle {
                                        width: 1
                                        height: 20
                                        color: COMMON.bg4
                                    }
                                    SText {
                                        text: sql_b
                                        height: 20
                                        width: parent.size
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        pointSize: 9.8
                                        color: COMMON.fg1
                                    }
                                    Rectangle {
                                        width: 1
                                        height: 20
                                        color: COMMON.bg4
                                    }
                                    SText {
                                        text: sql_idx
                                        height: 20
                                        width: parent.size
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        pointSize: 9.8
                                        color: COMMON.fg1
                                    }
                                    Rectangle {
                                        width: 1
                                        height: 20
                                        color: COMMON.bg4
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: updateBox
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 150
                width: 300

                border.width: 1
                border.color: COMMON.bg4
                color: COMMON.bg0
                clip: true

                Rectangle {
                    id: updateBoxHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 25
                    border.width: 1
                    border.color: COMMON.bg4
                    color: COMMON.bg3
                    
                    SText {
                        anchors.fill: parent
                        text: "Update area"
                        color: COMMON.fg1_5
                        leftPadding: 5
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Rectangle {
                    id: updateBoxArea
                    color: COMMON.bg1
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: updateBoxHeader.bottom
                    anchors.bottom: parent.bottom
                    anchors.margins: 1

                    SText {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: updateButton.top
                        text: GUI.versionInfo
                        pointSize: 9.8
                        color: COMMON.fg1
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    SButton {
                        id: updateButton
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 30
                        label: disabled ? "" : "Update"
                        disabled: GUI.updating || GUI.needRestart

                        onPressed: {
                            GUI.update()
                        }

                        SText {
                            anchors.fill: parent
                            visible: GUI.needRestart
                            text: "Restart required"
                            color: COMMON.accent(0)
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            pointSize: 9.0
                        }

                        LoadingSpinner {
                            anchors.centerIn: parent
                            height: 20
                            width: height
                            size: 20
                            running: GUI.updating
                            source: "../icons/loading_big.svg"
                        }
                    }
                }
            }
        }

    }

    onReleaseFocus: {
        keyboardFocus.forceActiveFocus()
    }

    Item {
        id: keyboardFocus
        Keys.onPressed: (event) => {
            event.accepted = false
        }
        Keys.forwardTo: [main]
    }
}