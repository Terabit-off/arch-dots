//@ pragma UseQApplication

import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Qt5Compat.GraphicalEffects
import Quickshell.Services.SystemTray 

import "./Singletons"
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
            Rectangle { 
                color: 'transparent'
                height: 20
                Layout.fillWidth: true

                Modules.WorkspacesModule { }
            }
            //CENTER
            Modules.MusicModule { }

            // //RIGHT
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
                    Modules.BluetoothModule { }
                    Modules.VolumesModule { }  
                    //battery
                    Rectangle {
                        color: '#4b4b4b4b'
                        radius: 5
                        Layout.fillHeight: true
                        implicitWidth: batteryText.implicitWidth + 10


                        Text {
                            id: batteryText
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "JetBrainsMono Nerd Font"
                            font.bold: false
                            font.pixelSize: 14
                            color: BatteryState.battery.percentage * 100 < 25 ? '#f38ba8' : "#ffffff"

                            text: {
                                return batteryIcon(BatteryState.battery.percentage * 100, BatteryState.battery.state === UPowerDevice.Charging) + (BatteryState.battery.percentage * 100).toFixed(0) + "%"
                            }
                        }
                    }
                    Modules.TrayModule { }
                    Modules.TimeDateModule { id: timeModule }
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
