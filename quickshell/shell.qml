//@ pragma UseQApplication

import Quickshell
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import "./Singletons" as Singletons
import "./barModules" as Modules 

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
            spacing: 12
        
            //LEFT
            Rectangle { 
                color: 'transparent'
                Layout.fillWidth: true
                height: 20

                Modules.WorkspacesModule { }
            }
            //CENTER
            Modules.MusicModule { }

            // //RIGHT
            Rectangle {
                color: 'transparent'
                Layout.fillWidth: true
                height: 20
 
                RowLayout {
                    anchors.fill: parent
                    anchors.left: parent.left

                    Item {
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        color: 'transparent'
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 50
                        Layout.maximumWidth: 50
                        visible: Singletons.BatteryState.battery.percentage * 100 <= 20

                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                            font.pixelSize: 14
                            color: '#e03030'

                            text: "󰁻 " + Singletons.BatteryState.battery.percentage * 100 + "%"
                        }
                    }
                    Modules.TrayModule { }

                    Modules.TimeDateModule { id: timeModule }
                }
            }
        }
    } 
} 