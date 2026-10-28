import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick

import "../../Singletons" as Singletons
import "../../menus" as Menus

Rectangle {
    color: Singletons.Colors.barModuleColor
    radius: 5
    Layout.fillHeight: true
    implicitWidth: btText.implicitWidth + 15

    Menus.BluetoothPopup {
        id: popup

        anchorItem: btText
    }

    Behavior on x {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutCubic
        }
    }

    Text {
        id: btText
        anchors.centerIn: parent

        text: "󰂯"
        color: Singletons.Colors.foreground
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 15

    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: {
            popup.visible = true
            //startApp.command = ["overskride"]
            //startApp.running = true
        }
    }

    Process {
        id: startApp
    }
}