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
            top: 5
        }
        implicitHeight: 30
        color: 'transparent'

        // INIT PROCESS
        
        Modules.ControlCenterWindow {
            id: controlCenter
        }

        Process {
            id: startApp
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
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Layout.minimumWidth: 25
                            Layout.maximumWidth: 25
                            color: 'transparent'
                            Text {
                                anchors.centerIn: parent
                                anchors.fill: parent
                                text: "󰣇"
                                font.pixelSize: 18
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

                        //TODO: do bluetooth
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
                                onClicked: {
                                    startApp.command = ["overskride"]
                                    startApp.running = true
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
                            Layout.minimumWidth: 70
                            Layout.maximumWidth: 70
                            height: 24

                            Text {
                                id: timeText
                                anchors.centerIn: parent
                                text: Qt.formatDateTime(new Date(), "hh:mm")
                                color: Singletons.Colors.foreground
                                font.bold: true
                                font.pixelSize: 16
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
                                timeText.text = Qt.formatDateTime(new Date(), "HH:mm");
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