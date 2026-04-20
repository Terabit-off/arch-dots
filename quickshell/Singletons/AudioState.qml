pragma Singleton
import QtQuick
import Quickshell.Services.Pipewire

Item {
    PwObjectTracker {
        id: audioTracker
        objects: [Pipewire.defaultAudioSink]
    }

    property PwNode sink: Pipewire.defaultAudioSink
}