import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../Singletons" as Singletons
import "." as Bar
import "../../menus" as Menus


Rectangle {
    id: root
    color: "transparent"
    height: 20
    width: 260

    Menus.CenterMenu {
        id: musicCenterWindow
        anchorItem: root
    }
    Rectangle {
        anchors.centerIn: parent
        color: Singletons.Colors.barModuleColor
        radius: 5
        implicitWidth: content.implicitWidth + 20
        height: parent.height


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
                color: Singletons.Colors.foreground
                font.pixelSize: 14
            }
        }
    }
}
