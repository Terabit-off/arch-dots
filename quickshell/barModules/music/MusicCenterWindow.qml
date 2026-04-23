import QtQuick
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects
import Quickshell.Hyprland
import QtQuick.Controls

import "../../Singletons" as Singletons

PanelWindow {
    id: musicRoot
    aboveWindows: true
    visible: false
    exclusiveZone: 0
    implicitHeight: 150
    implicitWidth: 400
    anchors {
        top: true
    }
    margins {
        top: 5
    }
    color: 'transparent'
    property int currentPlayerIndex: 0
    readonly property var active: Singletons.MusicSingleton.list.length > 1 ? Singletons.MusicSingleton.list[currentPlayerIndex]
         : Singletons.MusicSingleton.list[0]

    Rectangle {
        width: 400
        height: 150
        color: Singletons.Colors.moduleBackgroundColor
        radius: Singletons.Colors.panelBorderRadius
        border.color: Singletons.Colors.moduleBorderColor

        NumberAnimation on y {
            duration: 150
            running: visible
            from: -100; to: 0
            easing.type: Easing.OutCubic
        }
        RowLayout {
            anchors.fill: parent
            // COVER
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                Layout.maximumWidth: 150
                Image {
                    id: musicCover
                    anchors.fill: parent
                    anchors.centerIn: parent
                    anchors.margins: 5
                    fillMode: Image.PreserveAspectFit
                    source: {
                        return active.metadata["xesam:artUrl"] !== "" ? active.trackArtUrl : "bongo-cat.gif"
                    }
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: musicCover.width
                            height: musicCover.height
                            radius: 3
                        }
                    }
                }
            }

            // CONTROLS AND TRACK INFO
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                // Layout.margins: {
                //     top: 15
                //     bottom: 15
                // }
                color: 'transparent'
                ColumnLayout {
                    spacing: 5
                    anchors {
                        fill: parent
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                    //TRACK NAME
                    Text {
                        id: musicNameText
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: 20
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        text: active ? active.metadata["xesam:title"]: "Unknown"
                        horizontalAlignment: Text.AlignHCenter
                        color: Singletons.Colors.foreground
                        font.pixelSize: 16
                        elide: Text.ElideRight
                        font.bold: true
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            
                            onClicked: {
                                if (active) {
                                    Qt.openUrlExternally(active.metadata["xesam:url"])
                                }
                            }
                            onEntered: parent.color = '#ffffff'
                            onExited: parent.color = Singletons.Colors.foreground
                        }
                    }
                    //ARTIST
                    Text {
                        id: musicArtistText
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: 20
                        Layout.minimumHeight: 20
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        text: active ? active.trackArtist : "Unknown"
                        horizontalAlignment: Text.AlignHCenter
                        color: Singletons.Colors.foreground
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        font.bold: true
                    }

                    // TIME LINE
                    Slider {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 5
                        Layout.maximumHeight: 5
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        from: 0
                        to: active ? active.length : 100
                        value: active ? active.position : 0

                        HoverHandler {
                            target: null
                            cursorShape: Qt.PointingHandCursor
                        }

                        background: Rectangle {
                            x: parent.leftPadding
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: parent.availableWidth
                            height: 4
                            radius: 2
                            color: Singletons.Colors.sliderBackgroundColor

                            Rectangle {
                                width: parent.parent.visualPosition * parent.width
                                height: parent.height
                                color: Singletons.Colors.sliderBackgroundFillColor
                                radius: 2
                            }
                        }
                        handle: Rectangle {
                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: 8
                            height: 8
                            radius: 4
                            color: 'transparent'
                        }


                        onMoved: {
                            if (active)
                                active.position = value
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 5
                        Layout.maximumHeight: 5
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        color: 'transparent'

                        Text {
                            anchors.left: parent.left
                            color: Singletons.Colors.foreground
                            text: formatTime(active ? active.position : "")
                        }
                        Text {
                            anchors.right: parent.right
                            color: Singletons.Colors.foreground
                            text: formatTime(active ? active.length : "")
                        }
                    }
                    FrameAnimation {
                        running: active ? active.isPlaying : false
                        onTriggered: {
                            active ? active.positionChanged() : 0
                        }
                    }
                    
                    //Controls
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumWidth: 120
                        Layout.minimumHeight: 25
                        Layout.maximumHeight: 35
                        spacing: 5
                        Text {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            Layout.maximumWidth: 25
                            horizontalAlignment: Text.AlignHCenter
                            color: Singletons.Colors.foreground
                            text: "󰒮"
                            font.pixelSize: 30

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    if (active && active.canGoPrevious) {
                                        active.previous()
                                    }
                                }
                                onEntered: parent.color = '#ffffff'
                                onExited: parent.color = Singletons.Colors.foreground
                            }
                        }
                        //PAUSE
                        Text {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            Layout.maximumWidth: 25
                            horizontalAlignment: Text.AlignHCenter
                            color: Singletons.Colors.foreground
                            text: active && active.isPlaying ? "󰏤" : "󰐊"
                            font.pixelSize: 30

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    if (active) {
                                        active.togglePlaying()
                                    }
                                }
                                onEntered: parent.color = '#ffffff'
                                onExited: parent.color = Singletons.Colors.foreground
                            }
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            Layout.maximumWidth: 25
                            horizontalAlignment: Text.AlignHCenter
                            color: Singletons.Colors.foreground
                            text: "󰒭"
                            font.pixelSize: 30

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    if (active && active.canGoNext) {
                                        active.next()
                                    }
                                }
                                onEntered: parent.color = '#ffffff'
                                onExited: parent.color = Singletons.Colors.foreground
                            }
                        }
                    }
                    // ACTIVE PLAYER SELECTOR
                    RowLayout {
                        visible: Singletons.MusicSingleton.list.length > 1
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumWidth: 160
                        Layout.minimumHeight: 10
                        Layout.maximumHeight: 10
                        
                        Text {
                            text: ""
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            horizontalAlignment: Text.AlignHCenter
                            color: Singletons.Colors.foreground

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (currentPlayerIndex > 0) {
                                        currentPlayerIndex--
                                    } else currentPlayerIndex = Singletons.MusicSingleton.list.length - 1
                                }
                            }
                        }
                        Text {
                            text: Singletons.MusicSingleton.list[currentPlayerIndex] ? Singletons.MusicSingleton.list[currentPlayerIndex].identity : ""
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            horizontalAlignment: Text.AlignHCenter 

                            color: Singletons.Colors.foreground
                        }
                        Text {
                            text: ""
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            horizontalAlignment: Text.AlignHCenter
                            color: Singletons.Colors.foreground

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (currentPlayerIndex < Singletons.MusicSingleton.list.length - 1) {
                                        currentPlayerIndex++
                                    } else currentPlayerIndex = 0
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
                            
    }
    
    function formatTime(seconds) {
        let minutes = Math.floor((seconds % 3600) / 60)
        let secs = seconds % 60
        
        return minutes > 0 
            ? `${minutes}:${Math.round(secs).toString().padStart(2, '0')}`
            : `0:${Math.round(secs).toString().padStart(2, '0')}`
    }

    HyprlandFocusGrab {
        windows: [musicRoot]
        active: musicRoot.visible

        onCleared: {
            musicRoot.visible = false
        }
    }
}