import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../Singletons" as Singletons
import "." as Bar
import "../../menus" as Menus

Rectangle {
    id: root
    color: '#4b4b4b4b'
    radius: 5
    implicitWidth: content.implicitWidth + 20
    height: 20
    visible: true

    Menus.CenterMenu {
        id: musicCenterWindow
        anchorItem: root
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: {
            musicCenterWindow.visible = true
        }
    }

    RowLayout {
        id: content
        spacing: 5
        anchors.centerIn: parent

        Text {
            id: titleText
            Layout.maximumWidth: 250 
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            text: musicCenterWindow.active ? (!musicCenterWindow.active.isPlaying ?
                    "󰐊 " + musicCenterWindow.active.metadata["xesam:title"]
                    : musicCenterWindow.active.metadata["xesam:title"])
                    : "{---------}"
            color: "#ffffff"
            font.pixelSize: 14
        }
    }
}