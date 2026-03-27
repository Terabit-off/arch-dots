import Quickshell.Io
import QtQuick
import Quickshell
import QtQuick.Layouts

import "../../Singletons" as Singletons

Rectangle {
    color: 'transparent'
    Layout.fillWidth: true
    Layout.minimumWidth: 25
    Layout.maximumWidth: 50
    height: 24

     property alias wifiUpdateProcess: wifiProcess

    Process {
        id: wifiProcess
        command: ["nmcli", "-t", "-f", "active", "dev", "wifi"]
        running: true
        
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.startsWith("yes")) {
                    wifiText.text = "󰖩"
                } else {
                    wifiText.text = "󰖪"
                }
            }
        }
    }

    Text {
        id: wifiText
        anchors.centerIn: parent
        text: "󰖪"//"󰖩"
        font.pixelSize: 15
        color: Singletons.Colors.foreground
    }


    Timer {
        interval: 10000  // every 10 sec
        running: true
        repeat: true
        onTriggered: {
            wifiUpdateProcess.running = true              
        }
    }
}