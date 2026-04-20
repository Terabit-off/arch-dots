import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../Singletons" as Singletons
import "." as Bar
import "./menus" as Menus

Rectangle {
    id: root
    color: 'transparent'
    Layout.fillWidth: true
    Layout.minimumWidth: 10
    Layout.preferredWidth: 50
    Layout.maximumWidth: 300
    height: 24
    visible: Singletons.MusicSingleton.active !== null

    Bar.MusicCenterWindow {
        id: musicCenterWindow
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: {
            musicCenterWindow.visible = true
        }
    }

    RowLayout {
        spacing: 5
        anchors.centerIn: parent

        Text {
            id: titleText
            Layout.maximumWidth: 250 
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            text: musicCenterWindow.active? musicCenterWindow.active.metadata["xesam:title"]: "Unknown"
            color: Singletons.Colors.foreground
            font.bold: true
            font.pixelSize: 13
        }
    }
}