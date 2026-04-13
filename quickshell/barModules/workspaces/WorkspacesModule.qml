import QtQuick.Layouts
import Quickshell
import QtQuick
import Quickshell.Hyprland

import "../../Singletons" as Singletons

Row {
    id: root
    spacing: 5

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            width: 20
            height: 15
            color: 'transparent'
            Text {
                anchors.centerIn: parent
                text: modelData.id
                color: Singletons.Colors.wsNotFocusForeground
                font.bold: true
                font.pixelSize: 15
            }
            Rectangle {
                height: 2
                radius: 2
                width: parent.width
                anchors {
                    top: parent.top
                    topMargin: -2
                }

                Behavior on color {
                    ColorAnimation { duration: 250 }
                }   
                color: modelData.focused ? Singletons.Colors.wsFocusBackground : modelData.urgent ? 
                    Singletons.Colors.wsUrgentBackground : Singletons.Colors.wsNotFocusBackground
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