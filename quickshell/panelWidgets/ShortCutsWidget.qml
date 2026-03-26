import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../Singletons" as Singletons

GridLayout {
    id: root
    anchors.fill: parent
    anchors.margins: 10
    anchors.centerIn: parent

    columns: 5
    rows: 1

    Process {
        id: startApp
    }
    


    Rectangle {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.maximumWidth: 50
        Layout.maximumHeight: 50
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        color: Singletons.Colors.buttonOffBackground
        border.color: Singletons.Colors.buttonBorderColor
        border.width: Singletons.Colors.buttonBorderWidth
        radius: Singletons.Colors.moduleBorderRadius

        Text {
            anchors.centerIn: parent
            color: Singletons.Colors.foreground
            text: "󰈹"
            font.pixelSize: 24
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.startApp(["firefox"])
            }
        }
    }
    Rectangle {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.maximumWidth: 50
        Layout.maximumHeight: 50
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        color: Singletons.Colors.buttonOffBackground
        border.color: Singletons.Colors.buttonBorderColor
        border.width: Singletons.Colors.buttonBorderWidth
        radius: Singletons.Colors.moduleBorderRadius

        Text {
            anchors.centerIn: parent
            color: Singletons.Colors.foreground
            font.family: "JetBrainsMono Nerd Font"
            text: ""
            font.pixelSize: 24
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.startApp(["vscodium"])
            }
        }
    }
    Rectangle {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.maximumWidth: 50
        Layout.maximumHeight: 50
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        color: Singletons.Colors.buttonOffBackground
        border.color: Singletons.Colors.buttonBorderColor
        border.width: Singletons.Colors.buttonBorderWidth
        radius: Singletons.Colors.moduleBorderRadius

        Text {
            anchors.centerIn: parent
            color: Singletons.Colors.foreground
            text: ""
            font.pixelSize: 24
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.startApp(["obsidian"])
            }
        }
    }

    Rectangle {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.maximumWidth: 50
        Layout.maximumHeight: 50
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        color: Singletons.Colors.buttonOffBackground
        border.color: Singletons.Colors.buttonBorderColor
        border.width: Singletons.Colors.buttonBorderWidth
        radius: Singletons.Colors.moduleBorderRadius

        Text {
            anchors.centerIn: parent
            color: Singletons.Colors.foreground
            text: ""
            font.pixelSize: 24
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.startApp(["Telegram"])
            }
        }
    }

    function startApp(command){
        startApp.command = command
        startApp.running = true
    }

}