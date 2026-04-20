import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "../../Singletons" as Singletons

PopupWindow {
    id: powerMenu

    implicitWidth: 200
    implicitHeight: 50
    visible: false 
    color: 'transparent'

    property var panel
    property bool activeFocus

    anchor.item: panel
    anchor.edges: Qt.BottomEdge
    anchor.rect.x: panel.width - width / 2
    anchor.rect.y: panel.height + 5

    Process {
        id: doAction
    }


    Rectangle {
        anchors.fill: parent
        implicitHeight: 50
        implicitWidth: 200
        radius: 14
        color: Singletons.Colors.moduleBackgroundColor
        border.color: Singletons.Colors.moduleBorderColor


        NumberAnimation on y {
            duration: 250
            running: visible
            from: -300; to: 0
            easing.type: Easing.OutCubic
        }

        ColumnLayout {
            id: rootColumn
            anchors.fill: parent
            property var actionCommand
            spacing: 0


            RowLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumHeight: 50
                Layout.maximumHeight: 50
                Layout.minimumWidth: 200
                Layout.alignment: Qt.AlignTop
                spacing: 20

                Item {
                    Layout.fillWidth: true
                }
                // lock
                Text {
                    color: Singletons.Colors.foreground
                    font.pixelSize: 13
                    text: ""
                    MouseArea{
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            doAction.command = ["hyprlock"]
                            doAction.running=true
                        }       
                    }
                }
                //Separator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumHeight: 20
                    Layout.maximumWidth: 1
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    color: Singletons.Colors.moduleSeparatorColor
                }

                //Shut down
                Text {
                    color: Singletons.Colors.foreground
                    font.pixelSize: 13
                    text: ""
                    MouseArea{
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            rootColumn.actionCommand = ["shutdown", "0"]
                            powerMenu.implicitHeight = 100
                            confirmPanel.visible = true
                        }       
                    }
                }
                //Separator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumHeight: 20
                    Layout.maximumWidth: 1
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    color: Singletons.Colors.moduleSeparatorColor
                }

                // Reboot
                Text {
                    color: Singletons.Colors.foreground
                    font.pixelSize: 16
                    text: ""
                    MouseArea{
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            rootColumn.actionCommand = ["reboot"]
                            powerMenu.implicitHeight = 100
                            confirmPanel.visible = true
                        }       
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                id: confirmPanel
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumWidth: 200
                color: 'transparent'
                visible: false
                ColumnLayout {
                    anchors.fill: parent
                    anchors.centerIn: parent

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: 5
                        color: Singletons.Colors.foreground
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: "Sure?"
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.maximumWidth: 94
                            color: Singletons.Colors.foreground
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: ""

                            MouseArea{
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    doAction.command = rootColumn.actionCommand
                                    doAction.running = true
                                }       
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.maximumHeight: 20
                            Layout.maximumWidth: 1
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            color: Singletons.Colors.moduleSeparatorColor
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.maximumWidth: 94

                            color: Singletons.Colors.foreground
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: ""

                            MouseArea{
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    rootColumn.actionCommand = ""
                                    powerMenu.implicitHeight = 50
                                    confirmPanel.visible = false
                                }       
                            }
                        }
                    }
                    
                }
            }

        }
    }
    Behavior on implicitHeight {
        NumberAnimation { duration: 200; easing.type: Easing.InQuad }
    }



    HyprlandFocusGrab {
        id: focusGrab
        windows: [powerMenu]
        active: activeFocus

        onCleared: {
            powerMenu.visible = false
            confirmPanel.visible = false
            implicitHeight = 50
            activeFocus = false
        }
    }

    
}