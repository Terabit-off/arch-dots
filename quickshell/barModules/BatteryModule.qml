import Quickshell
import Quickshell.Services.UPower
import QtQuick.Layouts
import QtQuick

import "../Singletons" as Singletons

Rectangle {
    color: 'transparent'
    Layout.fillWidth: true
    Layout.minimumWidth: 50
    Layout.maximumWidth: 50
    height: 24

    readonly property var battery: Singletons.BatteryState.battery

    Text {
        id: batteryText
        anchors.centerIn: parent

        property var icon: {
            if (parent.battery.state === UPowerDevice.Charging) return "󰂄";
            if (parent.battery.percentage * 100>= 90) return "󰁹";
            if (parent.battery.percentage * 100>= 50) return "󰁾";
            if (parent.battery.percentage * 100 >= 20) return "󰁼";
            return "󰂃";
        }
        color: Singletons.Colors.foreground
        text: parent.battery ? icon + " " + Math.round(parent.battery.percentage * 100) + "%" : "--%"
        font.bold: true
        font.pixelSize: 13
    }

}