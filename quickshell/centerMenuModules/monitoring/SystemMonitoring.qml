import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import Quickshell

import "../../Singletons" as Singletons

Rectangle {
    Layout.fillWidth: true
    //Layout.fillHeight: true

    property bool opened: false

    implicitHeight: {
        if (opened){
            return 100;
        }
        return 35;
    }
    radius: Singletons.Colors.moduleBorderRadius
    color: Singletons.Colors.moduleBackgroundColor
    border.color: Singletons.Colors.moduleBorderColor
    clip: true

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 220
            easing.type: Easing.InOutCubic
        }
    }

    Process {
        id: getProcUsage
        command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print 100 - $8}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                Singletons.SystemMonitoring.procUsage = parseFloat(this.text.trim())
                canvasProcUsage.requestPaint()
            }
        }
    }
    Process {
        id: getProcTemp
        command: ["sh", "-c", "sensors -u | grep -m1 'temp1_input' | awk '{print $2}'"]

        stdout: StdioCollector {
            onStreamFinished: {
                Singletons.SystemMonitoring.procTemp = parseFloat(this.text.trim())
                canvasTemp.requestPaint()
            }
        }
    }
    Process {
        id: getRamUsage
        command: ["sh", "-c", "free -h | awk 'NR==2{print $3}' | cut -d'G' -f1"]
        stdout: StdioCollector {
            onStreamFinished: {
                Singletons.SystemMonitoring.ramUsage = parseFloat(this.text.trim())
                canvasRam.requestPaint()
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

    ColumnLayout {
        width: parent.width
        height: 100
        spacing: 10
        clip: true

        Text {
            text: "System "
            color: Singletons.Colors.foreground
            font.pixelSize: 12
            font.bold: true
            height: 10
            Layout.topMargin: 10
            verticalAlignment: Text.AlignVCenter
            Layout.leftMargin: 10
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    opened = !opened;
                    parent.text = opened ? "System " : "System "
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.bottomMargin: 10

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

                    property real strokeWidth: 4

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
                        const spread = Math.PI * Math.max(0, Math.min(1, Singletons.SystemMonitoring.procTemp / 100))

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, start, start - spread, true)
                        ctx.strokeStyle = Singletons.SystemMonitoring.procTemp > 70 ?'#e03030': "#bd939393"
                        ctx.stroke()

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, start, start + spread, false)
                        ctx.strokeStyle = Singletons.SystemMonitoring.procTemp > 70 ?'#e03030': "#bd939393"
                        ctx.stroke()
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: Singletons.SystemMonitoring.procTemp + "󰔄"
                    color: Singletons.Colors.foreground
                    font.pixelSize: 12
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

                    property real strokeWidth: 4

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
                        const spread = Math.PI * Math.max(0, Math.min(1, Singletons.SystemMonitoring.procUsage / 100))

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, start, start - spread, true)
                        ctx.strokeStyle = Singletons.SystemMonitoring.procUsage > 70 ?'#e03030': "#bd939393"
                        ctx.stroke()

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, start, start + spread, false)
                        ctx.strokeStyle = Singletons.SystemMonitoring.procUsage > 70 ?'#e03030': "#bd939393"
                        ctx.stroke()
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: Singletons.SystemMonitoring.procUsage + "%"
                    color: Singletons.Colors.foreground
                    font.pixelSize: 12
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

                    property real strokeWidth: 4

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
                        const spread = Math.PI * Math.max(0, Math.min(1, Singletons.SystemMonitoring.ramUsage / 27))

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, start, start - spread, true)
                        ctx.strokeStyle = Singletons.SystemMonitoring.ramUsage > 23 ?'#e03030': "#bd939393"
                        ctx.stroke()

                        ctx.beginPath()
                        ctx.arc(cx, cy, r, start, start + spread, false)
                        ctx.strokeStyle = Singletons.SystemMonitoring.ramUsage > 23 ?'#e03030': "#bd939393"
                        ctx.stroke()
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: Singletons.SystemMonitoring.ramUsage + "G"
                    color: Singletons.Colors.foreground
                    font.pixelSize: 12
                    font.bold: true
                }
            }
        }
    }
}