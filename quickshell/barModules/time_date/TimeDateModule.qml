import QtQuick.Layouts
import Quickshell
import QtQuick

import "../../Singletons" as Singletons
import "../../menus" as Menus

Rectangle {
    color: 'transparent'
    Layout.fillWidth: true
    Layout.minimumWidth: 120
    radius: 15
    height: 24

    Menus.ControlCenterMenu {
        id: controlCenterMenu
    }

    Text {
        id: timeText
        anchors.centerIn: parent
        color: Singletons.Colors.foreground
        font.bold: true
        font.pixelSize: 14
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            controlCenterMenu.visible = true
            Singletons.Properties.notificationIsRead = true
        }
        hoverEnabled: true
        onEntered: parent.color = Singletons.Colors.buttonOffHoverColor
        onExited: parent.color = 'transparent'
    }

    Rectangle {
        anchors {
            right: parent.right
        }
        height: 7
        width: 7
        radius: 5
        color: '#c33c3c'
        visible: !Singletons.Properties.notificationIsRead
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
            controlCenterMenu.updateTimeDate()
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
}