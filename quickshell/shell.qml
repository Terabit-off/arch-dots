//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import QtQuick.Controls

import "./Singletons" as Singletons

import "./barModules" as Modules
import "./musicCenter"
import "./menus" as Menus

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
        }
        implicitHeight: 24
        color: 'transparent'

        Modules.ControlCenterWindow {
            id: controlCenter
        }
        Menus.BluetoothMenu {
            id: bluetoothMenu
            panel: bluetoothText    
        }

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
                    Layout.preferredWidth: 50
                    Layout.maximumWidth: 700
                    height: 24


                    RowLayout{
                        anchors {
                            fill: parent
                            centerIn: parent
                        }


                        Rectangle {
                            id: overviewButton
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Layout.minimumWidth: 25
                            Layout.maximumWidth: 25
                            color: 'transparent'
                            Text {
                                anchors.centerIn: parent
                                anchors.fill: parent
                                text: "󰣇"
                                font.pixelSize: 16
                                color: Singletons.Colors.foreground
                            }
                        }
                        Rectangle {
                            color: Singletons.Colors.moduleSeparatorColor
                            height: 15
                            width: 1
                        }

                        //Workspaces
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: 'transparent'
                            Modules.WorkspacesModule { }
                        }
                    }

                }
                //CENTER
                Rectangle {
                    id: centerSec
                    color: 'transparent'
                    Layout.fillWidth: true
                    Layout.minimumWidth: 10
                    Layout.preferredWidth: 50
                    Layout.maximumWidth: 300
                    height: 24
                    
                    Modules.MusicModule { }
                    
                }
                //RIGHT
                Rectangle {
                    color: 'transparent'
                    Layout.fillWidth: true
                    Layout.minimumWidth: 10
                    Layout.preferredWidth: 50
                    Layout.maximumWidth: 700
                    height: 24
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            controlCenter.visible = true
                        }
                    }

                    RowLayout {
                        anchors {
                            right: parent.right
                        }
                        spacing: 5

                        // TODO: Wi-Fi interface
                        
                        Modules.TrayModule { }

                        //Separator
                        Rectangle {
                            color: Singletons.Colors.moduleSeparatorColor
                            height: 15
                            width: 1
                        }

                        Rectangle {
                            color: 'transparent'
                            Layout.fillWidth: true
                            Layout.minimumWidth: 25
                            Layout.maximumWidth: 50
                            height: 24
                            
                            Text {
                                id: bluetoothText
                                anchors.centerIn: parent
                                text: "󰂯" // 󰂲
                                font.pixelSize: 17
                                color: Singletons.Colors.foreground
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    bluetoothMenu.visible = true
                                    bluetoothMenu.activeFocus = true
                                }
                            }
                        }
                        Modules.WiFiModule { id: wifiModule }

                        //Separator
                        Rectangle {
                            color: Singletons.Colors.moduleSeparatorColor
                            height: 15
                            width: 1
                        }

                        Modules.BrightnessModule { }
                        Modules.AudioVolumeModule { }
                        Modules.BatteryModule { }

                        //Separator
                        Rectangle {
                            color: Singletons.Colors.moduleSeparatorColor
                            height: 15
                            width: 1
                        }
                        //Time
                        Rectangle {
                            color: 'transparent'
                            Layout.fillWidth: true
                            Layout.minimumWidth: 140
                            height: 24

                            Text {
                                id: timeText
                                anchors.centerIn: parent
                                color: Singletons.Colors.foreground
                                font.bold: true
                                font.pixelSize: 14
                            }
                        }

                        Timer {
                            interval: 10000  // every 10 sec
                            running: true
                            repeat: true
                            onTriggered: {
                                Modules.wifiProcess.running = true
                                
                            }
                        }
                        Timer {
                            running: true
                            repeat: true
                            triggeredOnStart: true
                            onTriggered: {
                                timeText.text = Qt.formatDateTime(new Date(), "HH:mm  ddd,MM");
                                controlCenter.updateTimeDate()
                                var now = new Date();
                                var nextMinute = new Date(
                                    now.getFullYear(),
                                    now.getMonth(),
                                    now.getDate(),
                                    now.getHours(),
                                    now.getMinutes() + 1,
                                    0, 0, 0
                                );

                                interval = nextMinute.getTime() - now.getTime() + 500;
                            }
                        }
                    }
                }
            }
        }
    }
}