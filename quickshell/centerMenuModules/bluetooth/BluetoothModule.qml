import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Hyprland


import "../../Singletons" as Singletons

Rectangle {
    id: bluetoothPopup

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.maximumHeight: {
        const s = 100 + Bluetooth.devices.values.length * 42;
        if (300 < s) return 300;
        return s;
    } 
    radius: 5
    color: Singletons.Colors.moduleBackgroundColor
    border.color: Singletons.Colors.moduleBorderColor


    Process {
        id: startApp
    }

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
                width: 226
                
                height: 42
                radius: 10
                color: modelData.connected ? '#393939' : Singletons.Colors.moduleBackgroundColor
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

                    Item {
                        Layout.fillWidth: true
                    }
                    //Device icon
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.rightMargin: 10
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Singletons.Colors.foreground
                        font.pixelSize: 16
                        text: getDeviceIcon(modelData.icon)
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

        Rectangle {
            Layout.fillWidth: true
            Layout.maximumWidth: 150
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            height: 25
            radius: 8
            color: 'transparent'

            RowLayout {
                anchors.fill: parent

                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumWidth: 75
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: Singletons.Colors.foreground
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    text: "More"

                    MouseArea {
                    anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            startApp.command = ["overskride"]
                            startApp.running = true
                        }
                    }
                }

                //Separator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumWidth: 1
                    Layout.maximumHeight: 15
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    color: Singletons.Colors.moduleSeparatorColor
                }


                Text {
                    id: scanButtonText
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumWidth: 75
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.discovering ? "Scanning" : "Scan" : ""
                    color: Singletons.Colors.foreground
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (Bluetooth.defaultAdapter){
                                if (Bluetooth.defaultAdapter.discovering) {
                                    Bluetooth.defaultAdapter.discovering = false
                                }
                                else {
                                    Bluetooth.defaultAdapter.discovering = true
                                    scanTimer.running = true
                                }
                            }
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
    function getDeviceIcon(name) {
        switch (name){
            case "audio-card":
            case "audio-headphones":
            case "audio-headset": return ""
            // ....
            default: return ""
        }
    }
}




// DEVICE ICONS CODES
//not sure

//"audio-card"              headphones or speakers
//"audio-headphones"        headphones
//"audio-headset"           headphones
//"phone"                   phone
//"tablet"                  tablet
//"input-keyboard"          keyboard
//"input-mouse"             mouse
//"input-gaming"            ds4 or something like that
//"camera-video"            web-camera
//"printer"                 printer
//"smartwatch"              watch
//"input-touchpad"          touchpad
//"computer"                laptop or other pc
//"audio-speakers"          speakers
//"bluetooth"               Generic device
//"phone-apple-iphone"      iphone
//"phone-samsung-galaxy"    samsung