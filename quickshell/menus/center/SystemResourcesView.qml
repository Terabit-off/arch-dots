import QtQuick
import Quickshell.Io
import QtQuick.Layouts
import QtQuick.Controls

import "../../Singletons" as Singletons

Item {
    id: sysRoot

    property real cpuUsage: 0
    property real ramUsage: 0
    property string temp: "0"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        Text {
            text: "System"
            font.family: "JetBrainsMono Nerd Font"
            color: Singletons.Colors.foreground
            font.pixelSize: 16
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Singletons.Colors.foreground
            opacity: 0.1
        }

        Item { Layout.fillHeight: true } // Spacer
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle{
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: "transparent"
                

                Canvas {
                    id: canvasTemp
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height

                    property real strokeWidth: 8

                    onPaint: {
                        const ctx = getContext("2d")
                        const cx = width / 2
                        const cy = height / 2
                        const r = Math.min(width, height) / 2 - strokeWidth

                        ctx.reset()

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, 0, Math.PI * 2)
                        ctx.lineWidth = strokeWidth
                        ctx.strokeStyle = "#3a3a3a"
                        ctx.stroke()

                        const start = Math.PI / 2
                        const spread = Math.PI * Math.max(0, Math.min(1, temp / 100))

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, start, start - spread, true)
                        ctx.strokeStyle = temp > 70 ?'#e03030': "#bd939393"
                        ctx.stroke()

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, start, start + spread, false)
                        ctx.strokeStyle = temp > 70 ?'#e03030': "#bd939393"
                        ctx.stroke()
                    }
                }

                Text {
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.centerIn: parent
                    text: temp + "°C"
                    color: Singletons.Colors.foreground
                    font.pixelSize: 16
                    font.bold: true
                }
            }
            
            // separator
            Rectangle {
                width: 2
                height: 20
                color: Singletons.Colors.moduleSeparatorColor 
            }

            Rectangle{
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: "transparent"
                

                Canvas {
                    id: canvasProcUsage
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height

                    property real strokeWidth: 8

                    onPaint: {
                        const ctx = getContext("2d")
                        const cx = width / 2
                        const cy = height / 2
                        const r = Math.min(width, height) / 2 - strokeWidth

                        ctx.reset()

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, 0, Math.PI * 2)
                        ctx.lineWidth = strokeWidth
                        ctx.strokeStyle = "#3a3a3a"
                        ctx.stroke()

                        const start = Math.PI / 2
                        const spread = Math.PI * Math.max(0, Math.min(1, cpuUsage / 100))

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, start, start - spread, true)
                        ctx.strokeStyle = cpuUsage > 70 ?'#e03030': "#bd939393"
                        ctx.stroke()

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, start, start + spread, false)
                        ctx.strokeStyle = cpuUsage > 70 ?'#e03030': "#bd939393"
                        ctx.stroke()
                    }
                }

                Text {
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.centerIn: parent
                    text: cpuUsage + "%"
                    color: Singletons.Colors.foreground
                    font.pixelSize: 16
                    font.bold: true
                }
            }

            // separator
            Rectangle {
                width: 2
                height: 20
                color: Singletons.Colors.moduleSeparatorColor 
            }

            Rectangle{
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: "transparent"
                

                Canvas {
                    id: canvasRam
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height

                    property real strokeWidth: 8

                    onPaint: {
                        const ctx = getContext("2d")
                        const cx = width / 2
                        const cy = height / 2
                        const r = Math.min(width, height) / 2 - strokeWidth

                        ctx.reset()

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, 0, Math.PI * 2)
                        ctx.lineWidth = strokeWidth
                        ctx.strokeStyle = "#3a3a3a"
                        ctx.stroke()

                        const start = Math.PI / 2
                        const spread = Math.PI * Math.max(0, Math.min(1, ramUsage / 27))

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, start, start - spread, true)
                        ctx.strokeStyle = ramUsage > 23 ?'#e03030': "#bd939393"
                        ctx.stroke()

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, start, start + spread, false)
                        ctx.strokeStyle = ramUsage > 23 ?'#e03030': "#bd939393"
                        ctx.stroke()
                    }
                }

                Text {
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.centerIn: parent
                    text: ramUsage + "G"
                    color: Singletons.Colors.foreground
                    font.pixelSize: 16
                    font.bold: true
                }
            }
        }
    }


    Process {
        id: getProcUsage
        command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print 100 - $8}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                cpuUsage = parseFloat(this.text.trim())
                canvasTemp.requestPaint()
            }
        }
    }
    Process {
        id: getProcTemp
        command: ["sh", "-c", "sensors -u | grep -m1 'temp1_input' | awk '{print $2}'"]

        stdout: StdioCollector {
            onStreamFinished: {
                temp = parseFloat(this.text.trim())
                canvasTemp.requestPaint()
            }
        }
    }
    Process {
        id: getRamUsage
        command: ["sh", "-c", "free -h | awk 'NR==2{print $3}' | cut -d'G' -f1"]
        stdout: StdioCollector {
            onStreamFinished: {
                ramUsage = parseFloat(this.text.trim())
                canvasTemp.requestPaint()
            }
        }
    }
    Timer {
        running: true
        interval: 3000
        repeat: true
        onTriggered: {
            getProcUsage.running = true
            getProcTemp.running = true
            getRamUsage.running = true
        }
    }
}
