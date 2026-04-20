pragma Singleton
import QtQuick
import Quickshell.Services.Pipewire

Item {
    PwObjectTracker {
        id: audioTracker
        objects: [Pipewire.defaultAudioSink]
    }
    PwObjectTracker {
        id: nodesTracker
        objects: streamNodes
    }

    property PwNode sink: Pipewire.defaultAudioSink
    property var streamNodes: {
        const out = [];

        if (!Pipewire.ready || !Pipewire.nodes || !Pipewire.nodes.values)
            return out;

        for (const node of Pipewire.nodes.values) {
            if (node.isStream && node.audio) {
                out.push(node);
            }
        }
        return out;
    }
}