import QtQuick
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects

import ".."

RowLayout {
    spacing: 0
    anchors.fill: parent

    Colors {
        id: colors
    }
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "transparent"
        Layout.maximumWidth: 170

        Image {
            id: musicCover
            visible: true
            anchors.centerIn: parent
            anchors.margins: 10
            width: 130
            height: 130
            fillMode: Image.PreserveAspectCrop//PreserveAspectFit
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
                    radius: musicCover.height / 2
                }
            }
            transform: Rotation {
                id: rotation
                origin.x: musicCover.width / 2
                origin.y: musicCover.height / 2
                angle: 0
            }
            NumberAnimation {
                target: rotation
                property: "angle"
                from: rotation.angle
                to: 360
                duration: 15000
                loops: Animation.Infinite
                running: MusicSingleton.isPlaying
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
                Layout.maximumWidth: 160
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
                    
                    onClicked: {
                        if (MusicSingleton.active && MusicSingleton.active.metadata["xesam:title"]) {
                            Qt.openUrlExternally(MusicSingleton.active.metadata["xesam:url"])
                        }
                    }
                }
            }
            //ARTIST
            Text {
                id: musicArtistText
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 10
                Layout.maximumWidth: 160
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
                //Layout.maximumHeight: 15
                spacing: 10
                Text {
                    Layout.alignment: Qt.AlignHCenter
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
                        onClicked: {
                            if (MusicSingleton.active && MusicSingleton.active.canGoPrevious) {
                                MusicSingleton.active.previous()
                            }
                        }
                    }
                }
                //PAUSE
                Text {
                    Layout.alignment: Qt.AlignHCenter
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
                        onClicked: {
                            if (MusicSingleton.active) {
                                MusicSingleton.active.togglePlaying()
                            }
                        }
                    }
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
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
                        onClicked: {
                            if (MusicSingleton.active && MusicSingleton.active.canGoNext) {
                                MusicSingleton.active.next()
                            }
                        }
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