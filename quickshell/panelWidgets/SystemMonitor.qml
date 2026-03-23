import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../Singletons" as Singletons

RowLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.maximumHeight: 5
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    spacing: 25

    property real cpuLoad: 0
    property real ramUsed: 0
    property real ramTotal: 0
    property real temp: 0
    // CPU
    Text {
        id: cpuText
        font.pixelSize: 14; font.bold: true
        color: cpuLoad > 80 ? "#ff4444" : cpuLoad > 60 ? "#ffaa00" : Singletons.Colors.foreground
        text: "   " + cpuLoad + "%"
        Layout.alignment: Qt.AlignHCenter
    }
    
    // SEPARATOR
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.maximumHeight: 20
        Layout.maximumWidth: 1
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        color: Singletons.Colors.moduleSeparatorColor
    }
    // RAM
    Text {
        id: ramText
        Layout.alignment: Qt.AlignHCenter
        font.pixelSize: 14; font.bold: true
        text: "   " + ramUsed + "GB"
        color: Singletons.Colors.foreground
    } 
    //SEPARATOR
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.maximumHeight: 20
        Layout.maximumWidth: 1
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        color: Singletons.Colors.moduleSeparatorColor
    }
    // TEMP
    Text {
        id: tempText
        Layout.alignment: Qt.AlignHCenter
        font.pixelSize: 14; font.bold: true
        color: temp > 80 ? "#ff4444" : temp > 70 ? "#ffaa00" : Singletons.Colors.foreground
        text: " " +temp + "°"
    }

    Process {
        id: tempProc
        command: ["sh", "-c", "sensors -j | jq '.. | .temp1_input? // empty' | head -1"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.temp = this.text
            }
        }
    }
    Process {
        id: memProc
        command: ["free", "-h"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.split("\n")
                let memLine = lines[1] // Mem строка
                let parts = memLine.trim().split(/\s+/)
                root.ramUsed = parseFloat(parts[2])
                root.ramTotal = parseFloat(parts[1])
            }
        }
    }
    Process {
        id: cpuProc
        command: ["sh", "-c", "mpstat -o JSON 1 1 | jq '.sysstat.hosts[0].statistics[0][\"cpu-load\"][0].idle'"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                let idle = parseFloat(this.text);
                if (!isNaN(idle)) {
                    root.cpuLoad = Math.round(100 - idle);
                }
            }
        }
    }

    Timer {
        interval: 5000 //4 sec
        running: true; repeat: true
        onTriggered: {
            memProc.running = true
            tempProc.running = true
            cpuProc.running = true
        }
    }
}
