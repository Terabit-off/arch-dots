import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import Quickshell.Hyprland

import "./panelWidgets"
import "./barModules"

// PANEL
PanelWindow {
    id: myContent
    aboveWindows: true
    visible: false
    exclusiveZone: 0
    implicitWidth: 400
    Colors {
        id: colors
    }

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
    function updateTimeDate(){
        timeDateText.text = Qt.formatDateTime(new Date(), "HH:mm      dd-MM-yyyy      ddd");
    }
    color: 'transparent'
    Rectangle {
        anchors.fill: parent
        color: colors.panelBackground
        radius: colors.panelBorderRadius
        ColumnLayout {
            anchors.fill: parent
            spacing: 5

            // CALENDAR
            Rectangle {
                id: timeDateModule
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 40
                border.color: colors.moduleBorderColor
                color: colors.moduleBackgroundColor
                radius: colors.moduleBorderRadius

                ColumnLayout {
                    id: rootCalendar
                    anchors.fill: parent
                    spacing: 5

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        // TIME, DATE
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.maximumHeight: 30
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            color: 'transparent'
                            
                            Text {
                                id: timeDateText
                                text: Qt.formatDateTime(new Date(), "HH:mm      dd-MM-yyyy      ddd");
                                anchors.centerIn: parent
                                font.pixelSize: 22
                                color: colors.foreground
                                font.bold: true
                            }
                        }
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
                color: colors.separatorColor
            }
            // MUSIC
            Rectangle {
                id: musicModule
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 150
                border.color: colors.moduleBorderColor

                color: colors.moduleBackgroundColor
                visible: MusicSingleton.active
                radius: colors.moduleBorderRadius

                MusicPanelWidget { }

            }
            // SEPARATOR
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 1
                Layout.maximumWidth: 300
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: colors.separatorColor
            }
            // WEATHER
            WhetherPanelWidget {
                id: whetherPanelModule
            }
            // SEPARATOR
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 1
                Layout.maximumWidth: 300
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: colors.separatorColor
            }
            // SYSTEM MONITORING
            Rectangle {
                id: systemMonitoringModule
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 70
                //Layout.maximumWidth: 250
                Layout.alignment: Qt.AlignHCenter
                color: colors.moduleBackgroundColor
                border.color: colors.moduleBorderColor
                radius: colors.moduleBorderRadius

                SystemMonitor { }
            }
            // SEPARATOR
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 1
                Layout.maximumWidth: 300
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: colors.separatorColor
            }
            // SHORTCUTS, VOLUMES
            Rectangle {
                id: deviceControlsModule
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                color: colors.moduleBackgroundColor
                border.color: colors.moduleBorderColor
                radius: colors.moduleBorderRadius
                Layout.maximumHeight: 160

                Process {
                    id: appRun
                    running: false
                }


                ColumnLayout {
                    anchors.fill: parent
                    anchors.centerIn: parent
                    anchors.bottomMargin: 5
                    anchors.topMargin: 5
                    spacing: 5

                    // APPS
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        //Layout.maximumHeight: 30
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        spacing: 15

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            width: 46
                            height: 46
                            radius: 18
                            color: colors.buttonOffBackground
                            border.color: colors.buttonBorderColor
                            border.width: colors.buttonBorderWidth
                            Text {
                                anchors.centerIn: parent
                                font.pixelSize: 18
                                text: ""
                                color: colors.buttonOffTextColor
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    appRun.command = ["vscodium"]
                                    appRun.running = true
                                }
                            }
                        }
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            width: 46
                            height: 46
                            radius: 18
                            color: colors.buttonOffBackground
                            border.color: colors.buttonBorderColor
                            border.width: colors.buttonBorderWidth
                            Text {
                                anchors.centerIn: parent
                                font.pixelSize: 22
                                text: ""
                                color: colors.buttonOffTextColor
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    appRun.command = ["firefox"]
                                    appRun.running = true
                                }
                            }
                        }
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            width: 46
                            height: 46
                            radius: 18
                            color: colors.buttonOffBackground
                            border.color: colors.buttonBorderColor
                            border.width: colors.buttonBorderWidth
                            Text {
                                anchors.centerIn: parent
                                font.pixelSize: 20
                                text: ""
                                color: colors.buttonOffTextColor
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    appRun.command = ["Telegram"]
                                    appRun.running = true
                                }
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
                        color: colors.moduleSeparatorColor
                    }
                    BrightnessProcess { }
                    // SEPARATOR
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: 1
                        Layout.maximumWidth: 150
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        color: colors.moduleSeparatorColor
                    }
                    AudioVolumeProcess { }
                    
                }
            }

            // NOTIFICATIONS ---- IN FUTURE
            Rectangle {
                id: notificationsModule
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                color: 'transparent'
                border.color: colors.moduleBorderColor
                radius: colors.moduleBorderRadius
            }
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
            // 1. Выполняем обновление погоды
            whetherPanelModule.weatherProcesss.running = true;

            // 2. Рассчитываем время до следующего часа
            var now = new Date();
            var nextHour = new Date(
                now.getFullYear(),
                now.getMonth(),
                now.getDate(),
                now.getHours() + 1, // Следующий час
                0, 0, 0             // 00 минут, 00 секунд
            );

            var msToNextHour = nextHour.getTime() - now.getTime();
            
            // 3. Устанавливаем новый интервал
            // Добавляем небольшой запас (например, 1 сек), чтобы не попасть в 59:59
            interval = msToNextHour + 1000;
        }
    }
}


