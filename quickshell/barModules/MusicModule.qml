import QtQuick
import QtQuick.Layouts
import Quickshell

import "../musicCenter"
import "../Singletons" as Singletons

Rectangle {
    id: root
    color: 'transparent'
    anchors.fill: parent
    radius: 12
    anchors.centerIn: parent
    visible: MusicSingleton.active !== null

    MusicCenterWindow {
        id: musicCenterWindow
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: {
            musicCenterWindow.visible = true
        }
    }

    //Separator
    Rectangle {
        color: Singletons.Colors.moduleSeparatorColor
        height: 15
        width: 1
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
    }

    RowLayout {
        spacing: 5
        anchors.centerIn: parent


        Text {
            id: musicIcon
            text: "󰎆"
            font.pixelSize: 16
            color: Singletons.Colors.foreground
            
            
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
            color: Singletons.Colors.foreground
            font.bold: true
            font.pixelSize: 14
        }
    }
    //Separator
    Rectangle {
        color: Singletons.Colors.moduleSeparatorColor
        height: 15
        width: 1
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
    }
}