//@ pragma UseQApplication

import "./Singletons" as Singletons
import "./barModules" as Modules
import "./launcher"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: root

    property var runtime: Singletons.AppRuntime

    PanelWindow {
        id: rootPanel

        implicitHeight: 20
        color: 'transparent'
        WlrLayershell.namespace: "qs-blur"
        WlrLayershell.layer: WlrLayer.Top

        anchors {
            top: true
            left: true
            right: true
        }

        margins {
            left: 25
            right: 25
            top: 3
            bottom: 3
        }

        Rectangle {
            anchors.fill: parent
            color: Singletons.Colors.barBackground
            border.color: Singletons.Colors.barBorderColor
            radius: 25

            RowLayout {
                id: layoutContent

                anchors.fill: parent
                spacing: 12

                //LEFT
                Rectangle {
                    color: 'transparent'
                    height: 20
                    Layout.fillWidth: true

                    Modules.WorkspacesModule {
                    }

                }

                //CENTER
                Modules.CenterModule {
                }

                //RIGHT
                Rectangle {
                    color: 'transparent'
                    height: 20
                    Layout.fillWidth: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.left: parent.left
                        spacing: 10

                        Item {
                            Layout.fillWidth: true
                        }

                        Modules.WifiModule {
                        }

                        Modules.BluetoothModule {
                        }

                        Modules.VolumesModule {
                        }

                        Modules.BatteryModule {
                        }

                        Modules.TrayModule {
                        }

                        Modules.NotificationModule {
                        }

                    }

                }

            }

        }

    }

    Launcher {
    }

}
