pragma Singleton
import QtQuick
import Quickshell // Убедитесь, что Mpris доступен здесь
import Quickshell.Services.Mpris


QtObject {
    readonly property var list: Mpris.players.values
    readonly property var active: list.length > 0 ? list[0] : null
    property var isPlaying: active && active.isPlaying
}
