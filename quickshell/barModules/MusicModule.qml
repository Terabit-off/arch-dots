import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root
    color: 'transparent'
    Layout.fillWidth: true
    Layout.minimumWidth: 10
    Layout.preferredWidth: 50
    Layout.maximumWidth: 300
    height: 24
    radius: 12
    anchors.centerIn: parent

    RowLayout {
        spacing: 5
        anchors.centerIn: parent

        Text {
            id: musicIcon
            text: "󰎆"
            font.pixelSize: 16
            color: colors.foreground
            visible: MusicSingleton.active !== null
            
            transformOrigin: Item.Center

            RotationAnimator {
                target: musicIcon
                from: 0
                to: 360
                duration: 3000
                loops: Animation.Infinite
                running: MusicSingleton.isPlaying
            }
        }

        Text {
            id: titleText
            Layout.maximumWidth: 250 
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            text: MusicSingleton.active ? MusicSingleton.active.metadata["xesam:title"] : ""
            color: colors.foreground
            font.bold: true
            font.pixelSize: 14
        }
    }
}