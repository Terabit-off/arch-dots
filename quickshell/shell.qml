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
        top: 3
    }
    implicitHeight: 24
    color: 'transparent'
    Menus.Volumes {
        id: volumesControlMenu
        panel: volumesPanel
        brightnessModule: brightnessBarModule
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
                height: 24


                RowLayout{
                    anchors {
                        fill: parent
                        centerIn: parent
                    }

                    //ARCH icon
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
                    //Separator
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
            Modules.MusicModule { }

            // //RIGHT
            Rectangle {
                color: 'transparent'
                Layout.fillWidth: true
                Layout.minimumWidth: 10
                Layout.preferredWidth: 50
                height: 24

                RowLayout {
                    anchors {
                        right: parent.right
                    }
                    spacing: 5
                    Modules.TrayModule { }
                    //Separator
                    Rectangle {
                        color: Singletons.Colors.moduleSeparatorColor
                        height: 15
                        width: 1
                    }
                    //Bluetooth
                    Modules.BluetoothModule { }
                    // TODO: Wi-Fi interface
                    Modules.WiFiModule { id: wifiModule }
                    //Separator
                    Rectangle {
                        color: Singletons.Colors.moduleSeparatorColor
                        height: 15
                        width: 1
                    }
                    // BRIGHTNESS, VOLUME, BATTERY
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 160
                        radius: 15
                        color: 'transparent'
                        RowLayout {
                            id: volumesPanel
                            anchors.fill: parent
                            anchors.centerIn: parent
                            Modules.BrightnessModule { id: brightnessBarModule }
                            Modules.AudioModule { }
                            Modules.BatteryModule { }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                volumesControlMenu.visible = true
                                volumesControlMenu.activeFocus = true
                            }
                            hoverEnabled: true
                            onEntered: parent.color = Singletons.Colors.buttonOffHoverColor
                            onExited: parent.color = 'transparent'
                        }
                        Behavior on color {
                            ColorAnimation { duration: 200; easing.type: Easing.InQuad }
                        }
                    }
                    //Separator
                    Rectangle {
                        color: Singletons.Colors.moduleSeparatorColor
                        height: 15
                        width: 1
                    }
                    Modules.TimeDateModule { }
                    //Separator
                    Rectangle {
                        color: Singletons.Colors.moduleSeparatorColor
                        height: 15
                        width: 1
                    }
                    Modules.PowerModule { }
                }
            }
        }
    }
}