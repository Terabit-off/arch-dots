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
    implicitWidth: 25

    Menus.ControlCenter {
        id: popup

        anchorItem: parent
    }

    Behavior on x {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutCubic
        }
    }

    Image {
        anchors.centerIn: parent
        width: 12
        height: 12
        fillMode: Image.PreserveAspectFit

        source: "icon.svg"
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