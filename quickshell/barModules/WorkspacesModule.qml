import QtQuick.Layouts
import Quickshell
import QtQuick
import Quickshell.Hyprland

Row {
    spacing: 5
    anchors.verticalCenter: parent.verticalCenter
    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            width: modelData.focused ? 30 : 25
            height: 20
            radius: modelData.focused ? 8 : modelData.urgent ? 8 : 0

            Behavior on color {
                ColorAnimation { duration: 250 }
            }
            Behavior on radius {
                NumberAnimation { duration: 250 }
            }
            Behavior on width {
                NumberAnimation { duration: 250 }
            }

            color: modelData.focused ? colors.wsFocusBackground :
                    modelData.urgent ? colors.wsUrgentBackground : colors.wsNotFocusBackground

            Text {
                anchors.centerIn: parent
                text: modelData.id
                color: modelData.focused
                    ? colors.wsFocusForeground
                    : colors.wsNotFocusForeground
                font.bold: true
                font.pixelSize: 14
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (modelData) {
                        modelData.activate()
                    }
                }
            }
        }
    }
}