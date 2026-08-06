import QtQuick.Layouts
import Quickshell
import QtQuick
import Quickshell.Hyprland

import "../../Singletons" as Singletons


Rectangle {
    color: '#4b4b4b4b'
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
                color: 'transparent'
                Text {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottomMargin: 0
                    }
                    horizontalAlignment: Text.AlignHCenter
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
