import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Rectangle {
    color: 'transparent'
    Layout.fillWidth: true
    Layout.minimumWidth: 50
    Layout.maximumWidth: 50
    height: 24

    PwObjectTracker {
        id: audioTracker
        objects: [Pipewire.defaultAudioSink]
    }
    property PwNode sink: Pipewire.defaultAudioSink
    Text {
        anchors.centerIn: parent
        property var icon: {
            if(parent.sink.audio.muted) return "󰝟"
            return "󰕾"
        }
        text: parent.sink.audio.muted ? "󰝟  0" :  "󰕾  "+ Math.round(parent.sink.audio.volume * 100)
        color:colors.foreground
        font.pixelSize: 14
        font.bold: true
    }
    MouseArea {
        anchors.fill: parent
        scrollGestureEnabled: true
        onClicked: {
            if (parent.sink) {
                // Инвертируем текущее состояние mute
                parent.sink.audio.muted = !parent.sink.audio.muted;
            }
        }

        onWheel: (wheel) => {
            if (parent.sink) {
                // Определяем шаг изменения (например, 5%)
                let step = 0.05;
                
                if (wheel.angleDelta.y > 0) {
                    // Крутим вверх - прибавляем (но не выше 1.0)
                    parent.sink.audio.volume = Math.min(parent.sink.audio.volume + step, 1.0);
                } else {
                    // Крутим вниз - убавляем (но не ниже 0.0)
                    parent.sink.audio.volume = Math.max(parent.sink.audio.volume - step, 0.0);
                }
            }
        }
    }
}