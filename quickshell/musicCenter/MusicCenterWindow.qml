import QtQuick
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects
import Quickshell.Hyprland
import QtQuick.Controls

import "../Singletons" as Singletons
import "../barModules"

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
            spacing: 0
            anchors.fill: parent

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                Layout.maximumWidth: 150

                Image {
                    id: musicCover
                    visible: true
                    anchors.fill: parent
                    anchors.centerIn: parent
                    anchors.margins: 5
                    // width: 130
                    // height: 130
                    fillMode: Image.PreserveAspectFit //PreserveAspectCrop
                    source: {
                        if(MusicSingleton.active && MusicSingleton.active.metadata["mpris:artUrl"]) {
                            return MusicSingleton.active.metadata["mpris:artUrl"]
                        }
                        else {
                            return "bongo-cat.gif"
                        }
                    }
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: musicCover.width
                            height: musicCover.height
                            radius: 10
                        }
                    }
                }
            }

            // CONTROLS AND TRACK INFO
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 95
                Layout.alignment: Qt.AlignVCenter
                color: 'transparent'
                ColumnLayout {
                    spacing: 5
                    anchors {
                        fill: parent
                    }
                    //TRACK NAME
                    Text {
                        id: musicNameText
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 20
                        Layout.maximumHeight: 20
                        Layout.maximumWidth: 200
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        text: MusicSingleton.active ? MusicSingleton.active.metadata["xesam:title"]: "Unknown"
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
                                if (MusicSingleton.active && MusicSingleton.active.metadata["xesam:title"]) {
                                    Qt.openUrlExternally(MusicSingleton.active.metadata["xesam:url"])
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
                        Layout.minimumHeight: 20
                        Layout.maximumHeight: 20
                        Layout.maximumWidth: 200
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        text: MusicSingleton.active ? MusicSingleton.active.trackArtist : "Unknown"
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
                        Layout.maximumWidth: 200
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        from: 0
                        to: MusicSingleton.active.length
                        value: MusicSingleton.active.position

                        HoverHandler {
                            target: null
                            cursorShape: Qt.PointingHandCursor
                        }

                        background: Rectangle {
                            x: parent.leftPadding
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            implicitHeight: 4
                            width: parent.availableWidth
                            height: implicitHeight
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
                            implicitWidth: 8
                            implicitHeight: 8
                            radius: 4
                            color: 'transparent'
                        }


                        onMoved: {
                            if (MusicSingleton.active)
                                MusicSingleton.active.position = value
                        }
                    }
                    FrameAnimation {
                        running: MusicSingleton.isPlaying
                        onTriggered: MusicSingleton.active.positionChanged()
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
                                    if (MusicSingleton.active && MusicSingleton.active.canGoPrevious) {
                                        MusicSingleton.active.previous()
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
                            text: MusicSingleton.isPlaying ? "󰏤" : "󰐊"
                            font.pixelSize: 30

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    if (MusicSingleton.active) {
                                        MusicSingleton.active.togglePlaying()
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
                                    if (MusicSingleton.active && MusicSingleton.active.canGoNext) {
                                        MusicSingleton.active.next()
                                    }
                                }
                                onEntered: parent.color = '#ffffff'
                                onExited: parent.color = Singletons.Colors.foreground
                            }
                        }
                    }
                }
            }
        }                          
    }

    HyprlandFocusGrab {
        windows: [musicRoot]
        active: musicRoot.visible

        onCleared: {
            musicRoot.visible = false
        }
    }
}