import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import ".."

RowLayout {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    spacing: 4

    property real cpuLoad: 0
    property real ramUsed: 0
    property real ramTotal: 0
    property real temp: 0
    // CPU
    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth: 100

        Text { text: "CPU"; color: "#aaa"; font.pixelSize: 14; Layout.alignment: Qt.AlignHCenter }
        Text {
            id: cpuText
            font.pixelSize: 14; font.bold: true
            color: cpuLoad > 80 ? "#ff4444" : cpuLoad > 60 ? "#ffaa00" : colors.foreground
            text: cpuLoad + "%"
            Layout.alignment: Qt.AlignHCenter
        }
    }
    // SEPARATOR
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.maximumHeight: 20
        Layout.maximumWidth: 1
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        color: colors.moduleSeparatorColor
    }
    // RAM
    ColumnLayout {
        Layout.maximumWidth: 100
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        
        Text { text: "RAM"; color: "#aaa"; font.pixelSize: 14; Layout.alignment: Qt.AlignHCenter }
        Text {
            id: ramText
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 14; font.bold: true
            text: ramUsed + "/" + ramTotal + "GB"
            color: colors.foreground
        }
    }

    //SEPARATOR
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.maximumHeight: 20
        Layout.maximumWidth: 1
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        color: colors.moduleSeparatorColor
    }
    // TEMP
    ColumnLayout {
        Layout.maximumWidth: 100
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Text { text: "TEMP"; color: "#aaa"; font.pixelSize: 14; Layout.alignment: Qt.AlignHCenter }
        Text {
            id: tempText
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 14; font.bold: true
            color: temp > 80 ? "#ff4444" : temp > 70 ? "#ffaa00" : colors.foreground
            text: temp + "°"
        }
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
        interval: 4000 //4 sec
        running: true; repeat: true
        onTriggered: {
            memProc.running = true
            tempProc.running = true
            cpuProc.running = true
        }
    }
}
