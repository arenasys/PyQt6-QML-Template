import QtQuick
import QtQuick.Controls

import gui 1.0

import "../style"

SMenuBar {
    id: root

    SMenu {
        id: menu
        title: "File"
        clipShadow: true
        SMenuItem {
            text: "Quit"
            shortcut: "Ctrl+Q"
            global: true
            onTriggered: {
                GUI.quit()
            }
        }
    }
    SMenu {
        title: "Edit"
        clipShadow: true
        SMenuItem {
            checkable: true
            text: "None"
        }
    }
    SMenu {
        title: "View"
        clipShadow: true
        SMenuItem {
            text: "None"
        }
    }
    SMenu {
        title: "Help"
        clipShadow: true
        SMenuItem {
            text: "About"
            onTriggered: {
                GUI.openLink("https://github.com/arenasys")
            }
        }
    }
}