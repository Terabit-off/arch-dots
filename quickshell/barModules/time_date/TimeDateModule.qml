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

    Text {
        id: timeText
        anchors.centerIn: parent
        color: Singletons.Colors.foreground
        font.bold: true
        font.pixelSize: 14
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
}