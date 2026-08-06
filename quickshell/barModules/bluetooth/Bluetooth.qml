import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick


Rectangle {
    color: '#4b4b4b4b'
    radius: 5
    Layout.fillHeight: true
    implicitWidth: btText.implicitWidth + 15

    Text {
        id: btText
        anchors.centerIn: parent

        text: "󰂯"
        color: "#ffffff"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 15

    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: {
            startApp.command = ["overskride"]
            startApp.running = true
        }
    }

    Process {
        id: startApp
    }
}