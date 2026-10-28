import QtQuick.Layouts
import Quickshell
import QtQuick
import Quickshell.Hyprland

import "../../Singletons" as Singletons


Rectangle {
    color: Singletons.Colors.barModuleColor
    radius: 5
    width: root.implicitWidth + 10
    height: 20
    
    Row {
        id: root
        spacing: 0
        anchors.centerIn: parent

        Repeater {
            model: Hyprland.workspaces

            delegate: Rectangle {
                width: 30
                height: 20
                radius: 5
                color: modelData.focused ? Singletons.Colors.wsFocusBackground : modelData.urgent ? 
                        Singletons.Colors.wsUrgentBackground : Singletons.Colors.wsNotFocusBackground
                Text {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: modelData.id
                    color: modelData.focused ? Singletons.Colors.wsFocusForeground : modelData.urgent ? 
                        Singletons.Colors.wsUrgentForeground : Singletons.Colors.wsNotFocusForeground
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${modelData.name} })`)
                    }
                }
            
            }
        }
    }
}
