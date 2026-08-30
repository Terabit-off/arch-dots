import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.UPower

import "../../Singletons" as Singletons


PopupWindow {
    id: root

    property Item anchorItem

    implicitWidth: popupContent.width
    implicitHeight: popupContent.height
    color: "transparent"
    grabFocus: true

    anchor {
        item: anchorItem
        edges: Edges.Bottom
        gravity: Edges.Bottom
        margins.top: 25
    }

    onVisibleChanged: {
        if (visible)
            openAnimation.restart()
    }

    Timer {
        running: true
        repeat: false
        interval: 1000
        onTriggered: {
            setIcons();
        }
    }
    function setIcons() {
        if (PowerProfiles.profile === PowerProfile.PowerSaver) Singletons.BatteryState.setModIcon("s")
        else if (PowerProfiles.profile === PowerProfile.Performance) Singletons.BatteryState.setModIcon("p")
        else if (PowerProfiles.profile === PowerProfile.Balanced) Singletons.BatteryState.setModIcon("b")
    }

    function formatTime(seconds) {
        if (!seconds || seconds <= 0)
            return "—";

        const minutes = Math.floor(seconds / 60);
        const hours = Math.floor(minutes / 60);
        const mins = minutes % 60;

        if (hours > 0)
            return hours + " h " + mins + " min";

        return mins + " min";
    }

    Rectangle {
        id: popupContent

        anchors.fill: parent
        implicitWidth: 340
        implicitHeight: 150


        color: Singletons.Colors.menuBackground
        border.color: Singletons.Colors.menuBorderColor
        radius: Singletons.Colors.menuBorderRadius

        ParallelAnimation {
            id: openAnimation

            PropertyAnimation {
                target: popupContent
                property: "opacity"
                from: 0
                to: 1
                duration: 160
                easing.type: Easing.OutCubic
            }

            PropertyAnimation {
                target: popupContent
                property: "scale"
                from: 0.92
                to: 1
                duration: 180
                easing.type: Easing.OutQuint
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5

            RowLayout {
                Layout.fillWidth: true
                height: 10

                StatCard {
                    title: "Consumption"
                    value: Math.abs(Singletons.BatteryState.battery.changeRate).toFixed(1) + " W"
                }
                Rectangle {
                    height: 10
                    width: 1
                    color: Singletons.Colors.separatorColor
                }

                StatCard {
                    title: UPower.onBattery
                           ? "Time to empty"
                           : "Time to full"

                    value: UPower.onBattery
                           ? root.formatTime(Singletons.BatteryState.battery.timeToEmpty)
                           : root.formatTime(Singletons.BatteryState.battery.timeToFull)
                }
            }
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Singletons.Colors.separatorColor
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                ProfileButton {
                    Layout.fillWidth: true

                    title: "Power saver"
                    icon: "󰌪"

                    active: PowerProfiles.profile === PowerProfile.PowerSaver

                    onClicked: {
                        PowerProfiles.profile = PowerProfile.PowerSaver
                        Singletons.BatteryState.setModIcon("s")
                    }
                }

                ProfileButton {
                    Layout.fillWidth: true

                    title: "Balance"
                    icon: "󰗑"

                    active: PowerProfiles.profile === PowerProfile.Balanced

                    onClicked: {
                        PowerProfiles.profile = PowerProfile.Balanced
                        Singletons.BatteryState.setModIcon("b")
                    }
                }

                ProfileButton {
                    Layout.fillWidth: true

                    title: "Performance"
                    icon: "󱐋"

                    enabled: PowerProfiles.hasPerformanceProfile

                    active: PowerProfiles.profile === PowerProfile.Performance

                    onClicked: {
                        if (PowerProfiles.hasPerformanceProfile)
                            PowerProfiles.profile = PowerProfile.Performance
                        
                        Singletons.BatteryState.setModIcon("p")
                    }
                }
            }
        }
    }

    // StatCard
    component StatCard: Rectangle {
        id: stat

        Layout.fillWidth: true
        Layout.preferredHeight: 58

        radius: 5
        color: "transparent"

        property string title
        property string value

        Column {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 12
            spacing: 3

            Text {
                text: stat.title
                color: "#777780"
                font.pixelSize: 10
            }

            Text {
                text: stat.value
                color: "#e4e4e7"
                font.pixelSize: 13
                font.bold: true
            }
        }
    }

    // ProfileButton
    component ProfileButton: Rectangle {
        id: button

        Layout.preferredHeight: 62

        radius: 5

        color: {
            if (!enabled)
                return Singletons.Colors.buttonBackgroundColor;

            if (active)
                return Singletons.Colors.activeButtonBackgroundColor;

            if (mouse.containsMouse)
                return Singletons.Colors.buttonBackgroundColorHover;

            return Singletons.Colors.buttonBackgroundColor;
        }

        border.width: 1
        border.color:Singletons.Colors.activeButtonBackgroundColor

        property string title
        property string icon
        property bool active: false

        signal clicked()

        opacity: enabled ? 1.0 : 0.45

        Column {
            anchors.fill: parent
            anchors.margins: 9
            spacing: 4

            Text {
                text: button.title
                color: Singletons.Colors.foreground
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: button.icon
                color: Singletons.Colors.foreground
                font.pixelSize: 18
                font.bold: true
            }
        }

        MouseArea {
            id: mouse

            anchors.fill: parent
            hoverEnabled: true
            enabled: button.enabled

            onClicked: button.clicked()
        }
    }
}
