import QtQuick
import QtQuick.Controls
import Quickshell.Services.UPower
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "../Singletons" as Singletons

PopupWindow {
    id: volumePopup

    implicitWidth: 205
    implicitHeight: 100
    visible: false
    color: 'transparent'

    property var panel
    property var brightnessModule
    property bool activeFocus

    anchor.item: panel
    anchor.edges: Qt.BottomEdge
    anchor.rect.x: -20
    anchor.rect.y: panel.height + 5

    Process {
        id: brightnessSet
        stdout: StdioCollector {
            onStreamFinished: brightnessModule.brightnessUpdateProcess.running = true
        }
    }


    Rectangle {
        height: 100
        width: 205
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
            anchors.fill: parent
            anchors.centerIn: parent
            anchors.margins: {
                left: 10
                right: 10
            }
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
                    value: Math.round(brightnessModule.currentBrightness/ 64507 * 100)

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
            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 10
                text: {
                    if (Singletons.BatteryState.battery.state === UPowerDevice.FullyCharged)
                        return "Full"
                    else if (Singletons.BatteryState.battery.state === UPowerDevice.Charging) 
                        return "Charging. " + formatTime(Singletons.BatteryState.battery.timeToFull) + " to full"
                    else 
                        return "Until discharge: " + formatTime(Singletons.BatteryState.battery.timeToEmpty)
                }
                color: Singletons.Colors.foreground
            }
        }
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

}