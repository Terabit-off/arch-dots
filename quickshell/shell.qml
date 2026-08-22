//@ pragma UseQApplication

import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Qt5Compat.GraphicalEffects
import Quickshell.Services.SystemTray 

import "./Singletons"
import "./barModules" as Modules 
import "./overview"


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

        Rectangle {
            anchors.fill: parent
            color: Colors.barBackground
            border.color: Colors.barBorderColor
            radius: 25

            RowLayout {
                anchors.fill: parent
                spacing: 12
            
                //LEFT
                //Modules.OverviewModule { }
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

                        Behavior on x {
                            NumberAnimation {
                                duration: 180
                                easing.type: Easing.OutCubic
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        Modules.WifiModule { }
                        Modules.BluetoothModule { }
                        Modules.VolumesModule { }  
                        //battery
                        Rectangle {
                            color: Colors.barModuleColor
                            radius: 5
                            Layout.fillHeight: true
                            implicitWidth: batteryText.implicitWidth + 10


                            Text {
                                id: batteryText
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                color: BatteryState.battery.percentage * 100 < 25 ? Colors.criticalColor : Colors.foreground

                                text: {
                                    return rootPanel.batteryIcon(BatteryState.battery.percentage * 100, BatteryState.battery.state === UPowerDevice.Charging) + (BatteryState.battery.percentage * 100).toFixed(0) + "%"
                                }
                            }
                        }
                        Modules.TrayModule { }
                        Modules.NotificationModule { }
                        Modules.TimeDateModule { }
                    }
                }
            }
        }


        function batteryIcon(level, charging) {
            if (charging)
                return "󰂄 "

            switch (true) {
            case level <= 25:
                return "󰁺"

            case level <= 50:
                return "󰁾 "

            case level <= 75:
                return "󰂀 "

            case level <= 100:
                return "󰁹 "
            }
        }
    }

    Overview { }

}

