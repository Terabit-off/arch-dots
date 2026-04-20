import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../Singletons" as Singletons
import "." as Bar


Rectangle {
    color: 'transparent'
    Layout.fillWidth: true
    Layout.minimumWidth: 30
    Layout.maximumWidth: 50
    radius: 15
    height: 24


    Bar.BluetoothMenu {
        id: bluetoothMenu
        panel: bluetoothText    
    }
    Component.onCompleted: {
        bluetoothMenu.loadIcon()
    }
    
    Text {
        id: bluetoothText
        anchors.centerIn: parent
        text: Singletons.Properties.bluetoothIcon //"󰂯" "󰂲"
        font.pixelSize: 17
        color: Singletons.Colors.foreground
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            bluetoothMenu.visible = true
            bluetoothMenu.activeFocus = true
        }
        hoverEnabled: true
        onEntered: parent.color = Singletons.Colors.buttonOffHoverColor
        onExited: parent.color = 'transparent'
    }
    Behavior on color {
        ColorAnimation { duration: 200; easing.type: Easing.InQuad }
    }
}