import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick

import "../../menus" as Menus
import "../../Singletons" as Singletons


Rectangle {
    color: Singletons.Colors.barModuleColor
    radius: 5
    Layout.fillHeight: true
    implicitWidth: wfText.implicitWidth + 15

    Menus.WifiPopup {
        id: wifiPopup

        anchorItem: wfText
    }

    Text {
        id: wfText
        anchors.centerIn: parent

        text: wifiPopup.connected ? "󰤨" : "󰤮"
        color: Singletons.Colors.foreground
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 15

    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: {
            wifiPopup.visible = !wifiPopup.visible
        }
    }
}