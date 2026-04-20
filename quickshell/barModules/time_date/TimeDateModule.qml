import QtQuick.Layouts
import Quickshell
import QtQuick

import "../../Singletons" as Singletons
import "../../menus" as Menus

Rectangle {
    color: 'transparent'
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.maximumWidth: 120

    Menus.ControlCenter {
        id: controlCenterMenu
        panel: timeText
    }

    Text {
        id: timeText
        anchors {
            left: parent.left
            right: parent.right
            bottomMargin: 0
        }
        color: Singletons.Colors.foreground
        font.bold: true
        font.pixelSize: 15
    }
    Behavior on color {
        ColorAnimation { duration: 200; easing.type: Easing.InQuad }
    }

    Timer {
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            timeText.text = Qt.formatDateTime(new Date(), "HH:mm  ddd, dd");
            var now = new Date();
            var nextMinute = new Date(
                now.getFullYear(),
                now.getMonth(),
                now.getDate(),
                now.getHours(),
                now.getMinutes() + 1,
                0, 0, 0
            );

            interval = nextMinute.getTime() - now.getTime() + 500;
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            controlCenterMenu.visible = true
            controlCenterMenu.activeFocus = true
            controlCenterMenu.currentDate = new Date()
        }
    }
}