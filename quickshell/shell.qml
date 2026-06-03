//@ pragma UseQApplication

import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Qt5Compat.GraphicalEffects

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
        top: 0
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

                    Item {
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        color: 'transparent'
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 50
                        Layout.maximumWidth: 50

                        Behavior on x {
                            NumberAnimation {
                                duration: 180
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                            font.pixelSize: 14
                            color: BatteryState.battery.percentage * 100 < 20 ? '#e03030' : Colors.foregroundDim

                            text: {
                                BatteryState.battery.state === UPowerDevice.Charging ? "󱐋 " + (BatteryState.battery.percentage * 100).toFixed(0) + "%" 
                                    : "󰁻 " + (BatteryState.battery.percentage * 100).toFixed(0) + "%"
                            }
                        }
                    }
                    Modules.TrayModule { }

                    Modules.TimeDateModule { id: timeModule }
                }
            }
        }
    } 
} 