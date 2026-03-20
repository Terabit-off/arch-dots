import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import "../Singletons" as Singletons

Rectangle {
    color: 'transparent'
    Layout.fillWidth: true
    Layout.minimumWidth: 50
    Layout.maximumWidth: 50
    height: 24
 
    Text {
        anchors.centerIn: parent
        property var icon: {
            if(Singletons.AudioState.sink.audio.muted) return "󰝟"
            return "󰕾"
        }
        text: Singletons.AudioState.sink.audio.muted ? "󰝟  0" :  "󰕾  "+ Math.round(Singletons.AudioState.sink.audio.volume * 100)
        color:Singletons.Colors.foreground
        font.pixelSize: 13
        font.bold: true
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        scrollGestureEnabled: true
        onClicked: {
            if (Singletons.AudioState.sink) {
                Singletons.AudioState.sink.audio.muted = !Singletons.AudioState.sink.audio.muted;
            }
        }

        onWheel: (wheel) => {
            if (Singletons.AudioState.sink) {
                let step = 0.05;  
                if (wheel.angleDelta.y > 0) {
                    Singletons.AudioState.sink.audio.volume = Math.min(Singletons.AudioState.sink.audio.volume + step, 1.0);
                } else {
                    Singletons.AudioState.sink.audio.volume = Math.max(Singletons.AudioState.sink.audio.volume - step, 0.0);
                }
            }
        }
    }
}