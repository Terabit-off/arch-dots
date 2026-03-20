import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import Quickshell.Hyprland


import "../panelWidgets" as Widgets
import "../Singletons" as Singletons

// PANEL
PanelWindow {
    id: myContent
    aboveWindows: true
    visible: false
    exclusiveZone: 0
    implicitWidth: 400


    anchors {
        right: true
        top: true
        bottom: true
    }
    margins {
        top: 25
        right: 15
        bottom: 25
    }
    color: 'transparent'

    function updateTimeDate() {
        timeDateWidget.upd()
    }


    Rectangle {
        //anchors.fill: parent
        width: 400
        height: parent.height
        color: Singletons.Colors.panelBackground
        radius: Singletons.Colors.panelBorderRadius

        NumberAnimation on x {
            duration: 250
            running: visible
            from: 1000; to: 0
            easing.type: Easing.OutExpo
        }


        ColumnLayout {
            anchors.fill: parent
            spacing: 5

            // CALENDAR
            Widgets.TimeDateWidget {
                id: timeDateWidget
            }
            // SEPARATOR
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 1
                Layout.maximumWidth: 300
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: Singletons.Colors.separatorColor
            }
            
            // WEATHER
            Widgets.WhetherPanelWidget {
                id: whetherPanelModule
            }
            // SEPARATOR
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 1
                Layout.maximumWidth: 300
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: Singletons.Colors.separatorColor
            }
            // SYSTEM MONITORING
            Rectangle {
                id: systemMonitoringModule
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 50
                //Layout.maximumWidth: 250
                Layout.alignment: Qt.AlignHCenter
                color: Singletons.Colors.moduleBackgroundColor
                border.color: Singletons.Colors.moduleBorderColor
                radius: Singletons.Colors.moduleBorderRadius

                ColumnLayout {
                    anchors.fill: parent
                    anchors.centerIn: parent
                    anchors.topMargin: 15
                    spacing: 5

                    Widgets.SystemMonitor { }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        // anchors.bottomMargin: 5
                        // anchors.topMargin: 5
                        spacing: 5
                    }
                }
            }
            // SEPARATOR
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 1
                Layout.maximumWidth: 300
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: Singletons.Colors.separatorColor
            }

            // NOTIFICATIONS //TODO: notification
            Widgets.NotificationWidget { }
        }
    }

    // CLOSE PANEL
    HyprlandFocusGrab {
        windows: [myContent]
        active: myContent.visible

        onCleared: {
            myContent.visible = false
        }
    }

    // WHETHER TIMER
    Timer {
        id: hourlyTimer
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            whetherPanelModule.weatherProcesss.running = true;

            var now = new Date();
            var nextHour = new Date(
                now.getFullYear(),
                now.getMonth(),
                now.getDate(),
                now.getHours() + 1,
                0, 0, 0
            );

            var msToNextHour = nextHour.getTime() - now.getTime();
            interval = msToNextHour + 1000;
        }
    }
}


