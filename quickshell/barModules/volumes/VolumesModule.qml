import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick
import QtQuick.Controls


import "../../Singletons" as Singletons
import "../../menus" as Menus

Rectangle {
    id: rootRec
    color: Singletons.Colors.barModuleColor
    radius: 5
    Layout.fillHeight: true
    implicitWidth: root.implicitWidth + 10
    property int currentBrightness: 0

    Menus.VolumesPopup {
        id: popup
        anchorItem: rootRec
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            popup.visible = true
        }
    }
   

    RowLayout {
        id: root
        spacing: 15
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 5
        }



        Text {
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignHCenter
            text: "󰃠 " + Math.round(currentBrightness/ 64507 * 100)
            color: Singletons.Colors.foreground
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onWheel: function(wheel) {
                    if (wheel.angleDelta.y > 0) {

                        brightnessSet.command = ["brightnessctl", "s", "+5%"]
                        brightnessSet.running = true
                        brightnessProcess.running = true
                    }
                    else{

                        brightnessSet.command = ["brightnessctl", "s", "5%-"]
                        brightnessSet.running = true
                        brightnessProcess.running = true
                    }

                    wheel.accepted = true
                }
                onClicked: {
                    popup.visible = true 
                }
            }
        }

        Text {
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignHCenter
            text: {
                return "󰕾 " + (Singletons.AudioState.sink ? Math.round(Singletons.AudioState.sink.audio.volume * 100) + "%" : 0 + "%")
            }
            color: Singletons.Colors.foreground
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onWheel: function(wheel) {
                    if (wheel.angleDelta.y > 0) {
                        if (Singletons.AudioState.sink.audio.muted) Singletons.AudioState.sink.audio.muted = false;
                        Singletons.AudioState.sink.audio.volume =
                            Math.min(1.0, Singletons.AudioState.sink.audio.volume + 0.05)
                    }
                    else{
                        if (Singletons.AudioState.sink.audio.muted) Singletons.AudioState.sink.audio.muted = false;
                        Singletons.AudioState.sink.audio.volume -= 0.05
                    }

                    wheel.accepted = true
                }
                onClicked: {
                    popup.visible = true
                }
            }
        }
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