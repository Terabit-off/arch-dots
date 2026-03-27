import Quickshell
import QtQuick
import QtQuick.Layouts

import "../../Singletons" as Singletons
import "../../menus" as Menus

Rectangle {
    color: 'transparent'
    Layout.fillWidth: true
    Layout.minimumWidth: 24
    Layout.maximumWidth: 24
    radius: 15
    height: 24

    Menus.PowerMenu {
        id: powerMenu
        panel: powerMenuButton
    }

    Text {
        id: powerMenuButton

        anchors.centerIn: parent
        color: Singletons.Colors.foreground
        font.bold: true
        font.pixelSize: 17
        text: '⏻'
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            powerMenu.visible = true
            powerMenu.activeFocus = true
        }
        hoverEnabled: true
        onEntered: parent.color = Singletons.Colors.buttonOffHoverColor
        onExited: parent.color = 'transparent'
    }
    Behavior on color {
        ColorAnimation { duration: 200; easing.type: Easing.InQuad }
    }
}