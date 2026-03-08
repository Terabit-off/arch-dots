import Quickshell.Io
import QtQuick
import Quickshell
import QtQuick.Layouts

Rectangle {
    color: 'transparent'
    Layout.fillWidth: true
    Layout.minimumWidth: 25
    Layout.maximumWidth: 50
    height: 24


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
        color: colors.foreground
    }
}