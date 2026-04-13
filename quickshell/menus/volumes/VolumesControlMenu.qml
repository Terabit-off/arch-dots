import QtQuick
import QtQuick.Controls
import Quickshell.Services.UPower
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "../../Singletons" as Singletons
import "../../barModules" as Modules
import "../../menus" as Menus

PopupWindow {
    id: volumePopup

    implicitWidth: 250
    implicitHeight: 660
    visible: false
    color: 'transparent'

    property var panel
    property int currentBrightness: 0
    property bool activeFocus
    property date currentDate: new Date()

    anchor.item: panel
    anchor.edges: Qt.BottomEdge
    anchor.rect.x: panel.width - width / 2
    anchor.rect.y: panel.height + 5

    ColumnLayout {
        anchors.fill: parent
        anchors.centerIn: parent


        // Calendar
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: 260
            color: Singletons.Colors.moduleBackgroundColor
            border.color: Singletons.Colors.moduleBorderColor
            radius: 5


            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 4

                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    Text {
                        text: "<"
                        color: Singletons.Colors.foreground
                        font.pixelSize: 18
                        Layout.fillWidth: true
                        MouseArea {
                            anchors.fill: parent
                            onClicked: currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1)
                        }
                    }

                    Text {
                        text: Qt.formatDate(currentDate, "MMMM yyyy")
                        color: Singletons.Colors.foreground
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                    }

                    Text {
                        text: ">"
                        color: Singletons.Colors.foreground
                        font.pixelSize: 18
                        Layout.fillWidth: true
                        MouseArea {
                            anchors.fill: parent
                            onClicked: currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1)
                        }
                    }
                }

                RowLayout {
                    spacing: 4
                    Layout.fillWidth: true
                    Layout.minimumWidth: 230
                    Repeater {
                        model: ["Mo","Tu","We","Th","Fr","Sa","Su"]
                        delegate: Text {
                            text: modelData
                            color: Singletons.Colors.foreground
                            width: 29
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
                

                Grid {
                    columns: 7
                    spacing: 4

                    Repeater {
                        model: 42 // 6 weeks

                        delegate: Rectangle {
                            width: 29
                            height: 26
                            radius: 6
                            visible: true

                            property int day: {
                                var firstDay = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1)
                                var startOffset = (firstDay.getDay() + 6) % 7 // monday = 0
                                return index - startOffset + 1
                            }

                            color: {
                                var today = new Date()
                                if (day === today.getDate() &&
                                    currentDate.getMonth() === today.getMonth() &&
                                    currentDate.getFullYear() === today.getFullYear()) {
                                    return '#c1666666'
                                }
                                return "transparent"
                            }

                            border.color: "#444"

                            Text {
                                anchors.centerIn: parent
                                text: {
                                    var txt = (day > 0 && day <= new Date(currentDate.getFullYear(), currentDate.getMonth()+1, 0).getDate())
                                        ? day : ""
                                    if(txt === "") {
                                        parent.border.color = 'transparent'
                                        return ""
                                    }
                                    parent.border.color = '#444'
                                    return txt
                                }
                                color: Singletons.Colors.foreground
                            }
                        }
                    }
                }
                Item {Layout.fillHeight: true }
            }
            
        }
        // volumes
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: 100
            radius: 5
            color: Singletons.Colors.moduleBackgroundColor
            border.color: Singletons.Colors.moduleBorderColor


            ColumnLayout {
                anchors.fill: parent
                anchors.centerIn: parent
                anchors.margins: {
                    left: 10
                    right: 10
                }
                
                // sound
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumHeight: 10
                    Layout.maximumWidth: 220
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    Text{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumWidth: 30
                        color: Singletons.Colors.foreground
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter 
                        text: "󰕾"
                    }

                    Slider {
                        id: soundVolumeSlider
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 5
                        Layout.maximumHeight: 5
                        Layout.minimumWidth: 100
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        from: 0
                        to: 100
                        value:  Singletons.AudioState.sink.audio.volume * 100

                        HoverHandler {
                            target: null
                            cursorShape: Qt.PointingHandCursor
                        }

                        background: Rectangle {
                            x: parent.leftPadding
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            implicitHeight: 4
                            width: parent.availableWidth
                            height: implicitHeight
                            radius: 2
                            color: Singletons.Colors.sliderBackgroundColor

                            Rectangle {
                                width: parent.parent.visualPosition * parent.width
                                height: parent.height
                                color: Singletons.Colors.sliderBackgroundFillColor
                                radius: 2
                            }
                        }
                        handle: Rectangle {
                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            implicitWidth: 5
                            implicitHeight: 10
                            radius: 4
                            color: Singletons.Colors.sliderHandlerColor
                        }
                        onMoved: {
                            Singletons.AudioState.sink.audio.volume = value / 100
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 30
                        Layout.maximumWidth: 30
                        color: Singletons.Colors.foreground
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        text: Math.round(soundVolumeSlider.value) + "%"
                    }
                }
                // brightness
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumHeight: 10
                    Layout.maximumWidth: 220
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    Text{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumWidth: 30
                        color: Singletons.Colors.foreground
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter 
                        text: "󰃠 "
                    }

                    Slider {
                        id: brightnessVolumeSlider
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 100
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        from: 0
                        to: 100
                        value: Math.round(currentBrightness/ 64507 * 100)

                        HoverHandler {
                            target: null
                            cursorShape: Qt.PointingHandCursor
                        }

                        background: Rectangle {
                            x: parent.leftPadding
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            implicitHeight: 4
                            width: parent.availableWidth
                            height: implicitHeight
                            radius: 2
                            color: Singletons.Colors.sliderBackgroundColor

                            Rectangle {
                                width: parent.parent.visualPosition * parent.width
                                height: parent.height
                                color: Singletons.Colors.sliderBackgroundFillColor
                                radius: 2
                            }
                        }
                        handle: Rectangle {
                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            implicitWidth: 5
                            implicitHeight: 10
                            radius: 4
                            color: Singletons.Colors.sliderHandlerColor
                        }

                        onMoved: {
                            brightnessSet.command = ["brightnessctl", "s", value + "%"]
                            brightnessSet.running = true
                            brightnessProcess.running = true
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 30
                        Layout.maximumWidth: 30
                        color: Singletons.Colors.foreground
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        text: Math.round(brightnessVolumeSlider.value) + "%"
                    }
                }
                // battery
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumHeight: 10
                    Layout.maximumWidth: 170
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: {
                        if (Singletons.BatteryState.battery.state === UPowerDevice.FullyCharged)
                            return Math.round(Singletons.BatteryState.battery.percentage * 100) + "% - Full"
                        else if (Singletons.BatteryState.battery.state === UPowerDevice.Charging) 
                            return "󱐋 " +  Math.round(Singletons.BatteryState.battery.percentage * 100) + "% - " + formatTime(Singletons.BatteryState.battery.timeToFull) + " to full"
                        else 
                            return Math.round(Singletons.BatteryState.battery.percentage * 100) + "% - " + formatTime(Singletons.BatteryState.battery.timeToEmpty)
                    }
                    color: Singletons.Colors.foreground
                }
            }
        }

        // bluetooth
        Modules.BluetoothMenu { }

    }







    HyprlandFocusGrab {
        id: focusGrab
        windows: [volumePopup]
        active: activeFocus

        onCleared: {
            volumePopup.visible = false
            activeFocus = false
        }
    }

    function formatTime(seconds) {
        let hours = Math.floor(seconds / 3600)
        let minutes = Math.floor((seconds % 3600) / 60)
        let secs = seconds % 60
        
        return hours > 0 
            ? `${hours}h ${minutes.toString().padStart(2, '0')}m`
            : `${minutes}m`
    }

    Process {
        id: brightnessProcess
        running: true
        command: ["brightnessctl", "g"]
        
        stdout: StdioCollector {
            onStreamFinished: currentBrightness = parseInt(this.text.trim())
        }
    }
    Process {
        id: brightnessSet

    }
}