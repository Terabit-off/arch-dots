import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Hyprland

import "../Singletons" as Singletons

PopupWindow {
    id: bluetoothPopup

    implicitWidth: 200
    implicitHeight: 300
    visible: false
    color: 'transparent'

    property var panel
    property bool activeFocus

    anchor.item: panel
    anchor.edges: Qt.BottomEdge
    anchor.rect.x: panel.width - width / 2
    anchor.rect.y: panel.height + 15

    Process {
        id: startApp
    } 

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: Singletons.Colors.moduleBackgroundColor
        border.color: Singletons.Colors.moduleBorderColor

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            //HEADER
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Bluetooth"
                    color: Singletons.Colors.foreground
                    font.pixelSize: 12
                    font.bold: true
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            startApp.command = ["overskride"]
                            startApp.running = true
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Toggle Bluetooth
                Rectangle {
                    width: 21
                    height: 11
                    radius: 8
                    color: Bluetooth.defaultAdapter?.enabled ? Singletons.Colors.buttonOnBackground : Singletons.Colors.buttonOffBackground

                    Rectangle {
                        width: 9
                        height: 9
                        radius: 9
                        anchors.verticalCenter: parent.verticalCenter
                        x: Bluetooth.defaultAdapter?.enabled ? 11 : 0
                        color: Bluetooth.defaultAdapter?.enabled ? '#000000' : '#cccccc'
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (Bluetooth.defaultAdapter)
                                Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                        }
                    }
                }
            }

            //DEVICES LIST
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 10

                model: Bluetooth.devices

                delegate: Rectangle {
                    width: parent.width
                    
                    height: 42
                    radius: 10
                    color: Singletons.Colors.moduleBackgroundColor
                    border.color: Singletons.Colors.buttonBorderColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        spacing: 10
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 120

                            Text {
                                text: modelData.name || modelData.deviceName || "Unknown device"
                                color: Singletons.Colors.foreground
                                elide: Text.ElideRight
                                font.pixelSize: 11
                            }

                            Text {
                                text: deviceStatus(modelData)
                                visible: text !== ""
                                color: "#aaa"
                                font.pixelSize: 8
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.connected) {
                                modelData.disconnect()
                            } else {
                                modelData.connect()
                            }
                        }
                    }
                }
            }

            //SCAN BUTTON
            Rectangle {
                Layout.fillWidth: true
                Layout.maximumWidth: 150
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                height: 25
                radius: 8
                color: 'transparent'
                //visible: !Bluetooth.defaultAdapter.discovering

                Text {
                    id: scanButtonText
                    anchors.centerIn: parent
                    text: Bluetooth.defaultAdapter.discovering ? "Scanning" : "Scan"
                    color: "white"
                }


                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (Bluetooth.defaultAdapter){
                            Bluetooth.defaultAdapter.discovering = true
                            scanTimer.running = true
                        }
                    }
                }
            }
        }
    }

    // Timeout scan
    Timer {
        id: scanTimer
        running: true
        interval: 10000
        onTriggered: {
            Bluetooth.defaultAdapter.discovering = false
        }
    }
    function deviceStatus(d) {
        if (d.connected)
            return "Connected"
        if (d.paired)
            return "Paired"
        if (d.state)
            return d.state
        return ""
    }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [bluetoothPopup]
        active: activeFocus

        onCleared: {
            bluetoothPopup.visible = false
            activeFocus = false
        }
    }
}