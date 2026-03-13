import QtQuick.Controls
import Quickshell.Io
import QtQuick
import Quickshell
import QtQuick.Layouts

import "../Singletons" as Singletons


RowLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumHeight: 10
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

    Text {
        text: "󰃠"
        Layout.maximumWidth: 30
        color: Singletons.Colors.foreground
        font.pixelSize: 14
        Layout.fillWidth: true
    }
    Slider {
        id: brightnessSlider
        from: 0
        to: 100
        value: 50
        Layout.fillWidth: true
        Layout.maximumWidth: 200

        background: Rectangle {
            x: parent.leftPadding
            y: parent.topPadding + parent.availableHeight / 2 - height / 2
            implicitWidth: 200
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
            implicitHeight: 13
            radius: Singletons.Colors.sliderHandlerBorderRadius
            color: Singletons.Colors.sliderHandlerColor
            border.color: Singletons.Colors.sliderHandlerBorderColor
        }
        
        onMoved: {
            brightnessUpdate.running = true
        }
    }
    Text {
        text: Math.round(brightnessSlider.value) + "%"
        color: Singletons.Colors.foreground
        font.bold: true
        Layout.fillWidth: true
        font.pixelSize: 14
        Layout.alignment: Qt.AlignHCenter
        Layout.maximumWidth: 30
    }

    Process {
        id: brightnessUpdate
        running: false
        command: ["brightnessctl", "set", brightnessSlider.value + "%"]
        stdout: StdioCollector {
            onStreamFinished: {
                brightnessUpdateProcess.running = true
            }
        }
    }
    Process {
        id: brightnessLoad
        running: true
        command: ["brightnessctl", "g"]
        stdout: StdioCollector {
            onStreamFinished: {
                let vol = parseInt(this.text.trim())
                brightnessSlider.value = vol
            }
        }
    }
}