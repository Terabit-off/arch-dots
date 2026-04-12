import QtQuick
import QtQuick.Controls
import Quickshell.Services.UPower
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "../../Singletons" as Singletons
import "../../barModules" as Modules

PopupWindow {
    id: volumePopup

    implicitWidth: 200
    implicitHeight: 400
    visible: false
    color: 'transparent'

    property var panel
    property int currentBrightness: 0
    property bool activeFocus

    anchor.item: panel
    anchor.edges: Qt.BottomEdge
    anchor.rect.x: panel.width - width / 2
    anchor.rect.y: panel.height + 5

    ColumnLayout {
        anchors.fill: parent
        anchors.centerIn: parent
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
                    Layout.maximumWidth: 170
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    Text{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumWidth: 30
                        color: Singletons.Colors.foreground
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
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
                        Layout.minimumWidth: 40
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
                    Layout.maximumWidth: 170
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    Text{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumWidth: 30
                        color: Singletons.Colors.foreground
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter 
                        text: "󰃠 "
                    }

                    Slider {
                        id: brightnessVolumeSlider
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 100
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
                        Layout.minimumWidth: 40
                        color: Singletons.Colors.foreground
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
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
                    text: {
                        if (Singletons.BatteryState.battery.state === UPowerDevice.FullyCharged)
                            return Math.round(parent.battery.percentage * 100) + "% - Full"
                        else if (Singletons.BatteryState.battery.state === UPowerDevice.Charging) 
                            return "󱐋 " +  Math.round(parent.battery.percentage * 100) + "% - " + formatTime(Singletons.BatteryState.battery.timeToFull) + " to full"
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