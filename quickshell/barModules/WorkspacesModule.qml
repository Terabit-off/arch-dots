import QtQuick.Layouts
import Quickshell
import QtQuick
import Quickshell.Hyprland

import "../Singletons" as Singletons

Row {
    id: root
    spacing: 5
    anchors.verticalCenter: parent.verticalCenter

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            width: modelData.focused ? 30 : 25
            height: 17
            radius: modelData.focused ? 8 : modelData.urgent ? 8 : 4

            Behavior on color {
                ColorAnimation { duration: 250 }
            }
            Behavior on radius {
                NumberAnimation { duration: 250 }
            }
            Behavior on width {
                NumberAnimation { duration: 250 }
            }

            color: modelData.focused ? Singletons.Colors.wsFocusBackground : modelData.urgent ? 
                Singletons.Colors.wsUrgentBackground : Singletons.Colors.wsNotFocusBackground

            
            Text {
                anchors.centerIn: parent
                text: modelData.id
                color: modelData.focused
                    ? Singletons.Colors.wsFocusForeground
                    : Singletons.Colors.wsNotFocusForeground
                font.bold: true
                font.pixelSize: 13
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (modelData) {
                        modelData.activate()
                    }
                }
            }
           
        }
    }
}