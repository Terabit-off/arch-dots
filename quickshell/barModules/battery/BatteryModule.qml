import Quickshell
import QtQuick.Layouts
import QtQuick
import QtQuick.Controls
import Quickshell.Services.UPower


import "../../Singletons" as Singletons
import "../../menus" as Menus

Rectangle {
    color: Singletons.Colors.barModuleColor
    radius: 5
    implicitHeight: 20
    implicitWidth: batteryText ? batteryText.implicitWidth + 10 : 10

    Menus.BatteryPopup {
        id: batteryPopup
        anchorItem: batteryText
    }
    
    Behavior on x {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutCubic
        }
    }
    
    Behavior on implicitWidth {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutCubic
        }
    }


    Text {
        id: batteryText
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        color: Singletons.BatteryState.battery.percentage * 100 < 25 ? Singletons.Colors.criticalColor : Singletons.Colors.foreground

        text: {
            return Singletons.BatteryState.modIcon 
                + batteryIcon(Singletons.BatteryState.battery.percentage * 100,
                Singletons.BatteryState.battery.state === UPowerDevice.Charging)
                + (Singletons.BatteryState.battery.percentage * 100).toFixed(0) + "%"
        }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            batteryPopup.visible = !batteryPopup.visible
        }
    }
    function batteryIcon(level, charging) {
        if (charging)
            return "󰂄 "

        switch (true) {
        case level <= 25:
            return "󰁺"

        case level <= 50:
            return "󰁾 "

        case level <= 75:
            return "󰂀 "

        case level <= 100:
            return "󰁹 "
        }
    }
}