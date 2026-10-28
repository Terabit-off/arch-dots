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

    implicitWidth: 340
    implicitHeight: 142
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

        width: root.implicitWidth
        height: root.implicitHeight


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
                duration: 260
                easing.type: Easing.OutCubic
            }
            PropertyAnimation {
                target: popupContent
                property: "y"
                from: -100
                to: 0
                duration: 260
                easing.type: Easing.OutBack
            }

            PropertyAnimation {
                target: popupContent
                property: "scale"
                from: 0.85
                to: 1
                duration: 280
                easing.type: Easing.OutSine
            }

        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: Singletons.Colors.menuSectionSpacing

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
                height: 10
                spacing: 8

                ProfileButton {
                    Layout.fillWidth: true

                    title: "Power saver"

                    active: PowerProfiles.profile === PowerProfile.PowerSaver

                    onClicked: {
                        PowerProfiles.profile = PowerProfile.PowerSaver
                        Singletons.BatteryState.setModIcon("s")
                    }
                }

                ProfileButton {
                    Layout.fillWidth: true

                    title: "Balance"

                    active: PowerProfiles.profile === PowerProfile.Balanced

                    onClicked: {
                        PowerProfiles.profile = PowerProfile.Balanced
                        Singletons.BatteryState.setModIcon("b")
                    }
                }

                ProfileButton {
                    Layout.fillWidth: true

                    title: "Performance"

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
        Layout.preferredHeight: 48

        radius: Singletons.Colors.cardRadius
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

        Layout.preferredHeight: 32

        radius: Singletons.Colors.cardRadius

        color: {
            if (!enabled)
                return Singletons.Colors.buttonBackgroundColor;

            if (active)
                return Singletons.Colors.controlActive;

            if (mouse.containsMouse)
                return Singletons.Colors.controlHover;

            return Singletons.Colors.buttonBackgroundColor;
        }

        border.width: 1
        border.color:Singletons.Colors.controlActive

        property string title
        property bool active: false

        signal clicked()

        opacity: enabled ? 1.0 : 0.45

        Column {
            anchors.fill: parent
            anchors.margins: 9
            spacing: 4

            Text {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter 
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: button.title
                color: Singletons.Colors.foreground
                font.pixelSize: 12
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
