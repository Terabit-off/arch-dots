//@ pragma UseQApplication

import Quickshell
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import QtQuick.Controls

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
        top: 5
    }
    implicitHeight: 30
    color: 'transparent'

    
    
    //Colors.qml
    Colors {
        id: colors
    }
    MediaCenterWindow {
        id: mediaCenter
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            mediaCenter.visible = true
        }
    }

    Rectangle {
        anchors.fill: parent
        color: colors.barBackground
        border.color: colors.barBorderColor
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

                //Workspaces
                Modules.WorkspacesModule { }
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

                RowLayout {
                    anchors {
                        right: parent.right
                    }
                    spacing: 5

                    Modules.TrayModule { }

                    //Separator
                    Rectangle {
                        color: colors.moduleSeparatorColor
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
                            color: colors.foreground
                        }
                    }
                    Modules.WiFiModule { id: wifiModule }

                    //Separator
                    Rectangle {
                        color: colors.moduleSeparatorColor
                        height: 15
                        width: 1
                    }

                    Modules.BrightnessModule { }
                    Modules.AudioVolumeModule { }
                    Modules.BatteryModule { }

                    //Separator
                    Rectangle {
                        color: colors.moduleSeparatorColor
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
                            color: colors.foreground
                            font.bold: true
                            font.pixelSize: 16
                        }
                    }

                    Timer {
                        interval: 10000  // every 10 sec
                        running: true
                        repeat: true
                        onTriggered: {
                            timeText.text = Qt.formatDateTime(new Date(), "HH:mm");
                            mediaCenter.updateTimeDate()
                            Modules.wifiProcess.running = true
                        }
                    }
                }
            }
        }
    }
}