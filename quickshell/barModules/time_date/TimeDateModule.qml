import QtQuick.Layouts
import Quickshell
import QtQuick

import "../../Singletons" as Singletons
import "../../menus" as Menus

Rectangle {
    color: Singletons.Colors.barModuleColor
    radius: 5
    Layout.fillHeight: true
    implicitWidth: timeText.implicitWidth + 10

    property bool timeWithDate: false
    
    Text {
        id: timeText
        anchors {
            centerIn: parent
            bottomMargin: 0
        }
        color: Singletons.Colors.foreground
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
    }
    Behavior on color {
        ColorAnimation { duration: 200; easing.type: Easing.InQuad }
    }

    Timer {
        id: timeTimer
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            timeText.text = Qt.formatDateTime(new Date(), timeWithDate ? "HH:mm | ddd.dd" : "HH:mm");
            var now = new Date();
            var nextMinute = new Date(
                now.getFullYear(),
                now.getMonth(),
                now.getDate(),
                now.getHours(),
                now.getMinutes() + 1,
                0, 0
            );

            interval = nextMinute.getTime() - now.getTime() + 500;
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            timeWithDate = !timeWithDate
            timeText.text = Qt.formatDateTime(new Date(), timeWithDate ? "HH:mm | ddd.dd" : "HH:mm");
            var now = new Date();
            var nextMinute = new Date(
                now.getFullYear(),
                now.getMonth(),
                now.getDate(),
                now.getHours(),
                now.getMinutes() + 1,
                0, 0
            );
        }
    }
}