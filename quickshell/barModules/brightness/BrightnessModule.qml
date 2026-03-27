import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Io

import "../../Singletons" as Singletons

Rectangle {
    id: brightness
    color: 'transparent'
    Layout.fillWidth: true
    Layout.minimumWidth: 50
    Layout.maximumWidth: 50
    height: 24

    property alias brightnessUpdateProcess: brightnessProcess

    property int currentBrightness: 0
    Process {
        id: brightnessProcess
        running: true
        command: ["brightnessctl", "g"]
        
        stdout: StdioCollector {
            onStreamFinished: brightness.currentBrightness = parseInt(this.text.trim())
        }
    }
    Process {
        id: brightnessDown
        command: ["brightnessctl", "s", "5%-"]
        
        stdout: StdioCollector {
            onStreamFinished: brightnessProcess.running = true
        }
    }
    Process {
        id: brightnessUp
        command: ["brightnessctl", "s", "+5%"]
        
        stdout: StdioCollector {
            onStreamFinished: brightnessProcess.running = true
        }
    }

    Text {
        
        anchors.centerIn: parent
        text: "󰃠  " + Math.round(brightness.currentBrightness / 64507 * 100)
        font.bold: true
        font.pixelSize: 13
        color: Singletons.Colors.foreground
    }

    MouseArea {
        anchors.fill: parent
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                brightnessUp.running = true
            } else {
                brightnessDown.running = true
            }
        }
    }
}