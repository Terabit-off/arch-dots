import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../Singletons" as Singletons
import "." as Bar
import "../../menus" as Menus


Rectangle {
    id: root
    height: 20
    width: 260
    color: "transparent"

    Menus.CenterMenu {
        id: centerWindow
        anchorItem: root
    }
    Rectangle {
        color: "transparent"
        radius: 5
        implicitWidth: content.implicitWidth + 20
        height: parent.height
        anchors.centerIn: parent


        

        RowLayout {
            id: content
            spacing: 5
            anchors.centerIn: parent
            anchors.fill: parent

            Rectangle {
                Layout.fillHeight: true
                implicitWidth: 60
                radius: 5
                color: Singletons.Colors.barModuleColor
                clip: true

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                        centerWindow.currentSegmentIndex = 0
                        centerWindow.visible = true
                    }
                }

                Behavior on x {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutCubic
                    }
                }

                Text {
                    id: timeText
                    width: 50
                    anchors.margins: {
                        left: 5
                        right: 5
                    }
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: Singletons.Colors.foreground
                    anchors.centerIn: parent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                }
            }

            Rectangle {
                Layout.fillHeight: true
                implicitWidth: musicText.implicitWidth + 10
                radius: 5
                color: Singletons.Colors.barModuleColor
                visible: titleText.text != ""
                clip: true

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                        centerWindow.currentSegmentIndex = 1
                        centerWindow.visible = true
                    }
                }

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutCubic
                    }
                }

                RowLayout {
                    id: musicText
                    spacing: 5
                    anchors.centerIn: parent
                    anchors.margins: {
                        left: 5
                        right: 5
                    }

                    Item {
                        Layout.fillHeight: true
                        width: 10
                        Text {
                            anchors.fill: parent
                            anchors.centerIn: parent
                            text: "󰎆"
                            font.pixelSize: 14
                            color: Singletons.Colors.foreground

                            RotationAnimation on rotation {
                                running: centerWindow.active && centerWindow.active.isPlaying
                                from: rotation
                                to: 360
                                duration: 10200 
                                loops: Animation.Infinite
                            }
                        }
                    }



                    Text {
                        id: titleText
                        Layout.fillHeight: true
                        Layout.maximumWidth: 230
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        //anchors.centerIn: parent
                        elide: Text.ElideRight
                        text: centerWindow.active
                                ? centerWindow.active.metadata["xesam:title"]
                                : ""
                        color: Singletons.Colors.foreground
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                    }
                }

            }

        }
    }

    Timer {
        id: timeTimer
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            timeText.text = Qt.formatDateTime(new Date(), "HH:mm");
            var now = new Date();
            var nextMinute = new Date(
                now.getFullYear(),
                now.getMonth(),
                now.getDate(),
                now.getHours(),
                now.getMinutes() + 1,
                0, 0
            );

            interval = nextMinute.getTime() - now.getTime() + 500;
        }
    }
}
