//@ pragma UseQApplication

import Quickshell
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import "./Singletons" as Singletons
import "./barModules" as Modules
import "./menus" as Menus

PanelWindow {
    id: rootPanel
    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        left: 25
        right: 25
        top: 0
    }
    implicitHeight: 20
    color: 'transparent'
    

    Rectangle {
        anchors.fill: parent
        color: Singletons.Colors.barBackground
        border.color: Singletons.Colors.barBorderColor
        radius: 25

        RowLayout {
            anchors.fill: parent
            anchors {
                leftMargin: 10
            }
            spacing: 12
        
            //LEFT
            Rectangle { 
                color: 'transparent'
                Layout.fillWidth: true
                Layout.minimumWidth: 10
                height: 20

                Modules.WorkspacesModule { }
            }
            //CENTER
            Modules.MusicModule { }

            // //RIGHT
            Rectangle {
                color: 'transparent'
                Layout.fillWidth: true
                Layout.minimumWidth: 10
                height: 20
 
                RowLayout {
                    anchors.fill: parent
                    anchors.left: parent.left

                    Item {
                        Layout.fillWidth: true
                    }
                    Modules.TrayModule { }

                    Modules.TimeDateModule { id: timeModule }
                }
            }
        }
    }
}