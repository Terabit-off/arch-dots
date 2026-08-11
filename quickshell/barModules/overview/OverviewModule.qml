import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick

import "../../menus" as Menus

Rectangle {
    color: '#4b4b4b4b'
    radius: 5
    Layout.fillHeight: true
    implicitWidth: iconText.implicitWidth + 15

        Menus.OverviewPopup {
        id: overviewPopup

        anchorItem: iconText
    }

    Text {
        id: iconText
        anchors.centerIn: parent

        text: ""
        color: "#ffffff"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 15

    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: {
            overviewPopup.visible = !overviewPopup.visible
        }
    }
}