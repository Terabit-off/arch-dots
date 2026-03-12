import QtQuick
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects
import Quickshell.Hyprland

import ".."
import "../barModules"

PanelWindow {
    id: musicRoot
    aboveWindows: true
    visible: false
    exclusiveZone: 0
    implicitHeight: 150
    implicitWidth: 400
    Colors {
        id: colors
    }
    anchors {
        top: true
    }
    margins {
        top: 5
    }
    color: 'transparent'

    
    


    Rectangle {
        //anchors.fill: parent
        width: 400
        height: 150
        color: colors.moduleBackgroundColor
        radius: colors.panelBorderRadius
        border.color: colors.moduleBorderColor

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
                color: 'transparent'
                ColumnLayout {
                    spacing: 5
                    anchors {
                        fill: parent
                        topMargin: 15
                        bottomMargin: 15
                    }
                    //TRACK NAME
                    Text {
                        id: musicNameText
                        Layout.fillWidth: true
                        Layout.maximumHeight: 25
                        Layout.maximumWidth: 200
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        text: MusicSingleton.active ? MusicSingleton.active.metadata["xesam:title"] : "Unknown"
                        horizontalAlignment: Text.AlignHCenter
                        color: colors.foreground
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
                            onExited: parent.color = colors.foreground
                        }
                    }
                    //ARTIST
                    Text {
                        id: musicArtistText
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: 10
                        Layout.maximumWidth: 200
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        text: MusicSingleton.active ? MusicSingleton.active.trackArtist : "Unknown"
                        horizontalAlignment: Text.AlignHCenter
                        color: colors.foreground
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        font.bold: true
                    }
                    
                    //Controls
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10
                        Text {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            Layout.maximumWidth: 35
                            horizontalAlignment: Text.AlignHCenter
                            height: 30
                            color: colors.foreground
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
                                onExited: parent.color = colors.foreground
                            }
                        }
                        //PAUSE
                        Text {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            Layout.maximumWidth: 35
                            horizontalAlignment: Text.AlignHCenter
                            height: 30
                            color: colors.foreground
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
                                onExited: parent.color = colors.foreground
                            }
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            Layout.fillWidth: true
                            Layout.maximumWidth: 35
                            horizontalAlignment: Text.AlignHCenter
                            height: 30
                            color: colors.foreground
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
                                onExited: parent.color = colors.foreground
                            }
                        }
                    }
                    // SOURCE
                    Text {
                        id: musicSourceText
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: 8
                        Layout.maximumWidth: 160
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        text: {
                            let src = MusicSingleton.active ? MusicSingleton.active.metadata["xesam:url"]: ""
                            if (src === "") return " "
                            let hostname = new URL(src).hostname
                            let parts = hostname.replace(/^www\./, "").split(".com")
                            return parts[0]
                        } 
                        horizontalAlignment: Text.AlignHCenter
                        color: colors.foreground
                        font.pixelSize: 8
                        elide: Text.ElideRight
                        font.bold: true
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