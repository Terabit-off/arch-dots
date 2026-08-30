//@ pragma UseQApplication

import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Qt5Compat.GraphicalEffects
import Quickshell.Services.SystemTray
import Quickshell.Wayland

import "./Singletons" as Singletons
import "./barModules" as Modules 
import "./overview"
import "./launcher"


ShellRoot {
    id: root
    
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
            top: 3
            bottom: 3
        }
        implicitHeight: 20
        color: 'transparent'
        WlrLayershell.namespace: "qs-blur"
        WlrLayershell.layer: WlrLayer.Top


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
                    height: 20
                    Layout.fillWidth: true

                    Modules.WorkspacesModule { }
                }
                //CENTER
                Modules.MusicModule { }

                //RIGHT
                Rectangle {
                    color: 'transparent'
                    height: 20     
                    Layout.fillWidth: true
    
                    RowLayout {
                        anchors.fill: parent
                        anchors.left: parent.left
                        spacing: 10
                        
                        Item {
                            Layout.fillWidth: true
                        }
                        Modules.WifiModule { }
                        Modules.BluetoothModule { }
                        Modules.VolumesModule { }  
                        Modules.BatteryModule { }
                        Modules.TrayModule { }
                        Modules.NotificationModule { }
                        Modules.TimeDateModule { }
                    }
                }
            }
        }


        
    }

    //Overview { }
    Launcher { } 
}
