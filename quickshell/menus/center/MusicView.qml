import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls

import "../../Singletons" as Singletons

Item {
    id: musicViewRoot

    property var popup
    property int currentPlayerIndex: 0

    readonly property var active: {
        const players = Singletons.MusicSingleton.list 
        return players.length > 0
            ? players[Math.min(currentPlayerIndex, players.length - 1)]
            : null
    }

    function formatTime(seconds) {
        seconds = Number(seconds) || 0
        const minutes = Math.floor(seconds / 60)
        const secs = Math.floor(seconds % 60)
        return `${minutes}:${secs.toString().padStart(2, "0")}`
    }

    function sourceName(player) {
        if (!player)
            return "No source"

        const identity = player.identity || player.desktopEntry || "Browser"
        const title = player.trackTitle || "No track"

        return `${identity}·${title}`
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 18
            rightMargin: 18
            topMargin: 16
            bottomMargin: 16
        }
        spacing: 18

        // COVER
        Rectangle {
            id: coverFrame

            Layout.preferredWidth: 142
            Layout.preferredHeight: 142
            Layout.alignment: Qt.AlignVCenter

            radius: 12
            color: "#302f2f2f"

            Image {
                id: coverImage

                anchors.fill: parent
                source: musicViewRoot.active
                        ? musicViewRoot.active.trackArtUrl
                        : ""

                sourceSize.width: 284
                sourceSize.height: 284
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
                cache: true
                visible: false
            }

            Rectangle {
                id: coverMask

                anchors.fill: parent
                radius: coverFrame.radius
                color: "white"
                visible: false
            }

            OpacityMask {
                id: roundedCover

                anchors.fill: coverFrame
                source: coverImage
                maskSource: coverMask
                visible: coverImage.status === Image.Ready
            }

            Text {
                anchors.centerIn: parent

                visible: !roundedCover.visible
                text: "󰝚"
                color: Singletons.Colors.foreground
                font.pixelSize: 48
                opacity: 0.55
            }
            AnimatedImage {
                id: coverEmpty
                anchors.fill: parent

                source: Qt.resolvedUrl("sleepy_cat.gif")
                fillMode: Image.PreserveAspectFit
                playing: true
                visible: false
            }
            OpacityMask {
                id: roundedCoverEmpty

                anchors.fill: coverFrame
                source: coverEmpty
                maskSource: coverMask
                visible: !roundedCover.visible
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 7

            // Track Name
            Text {
                id: musicNameText

                Layout.fillWidth: true
                Layout.preferredHeight: 24
                text: musicViewRoot.active
                      ? musicViewRoot.active.trackTitle
                      : "No player"
                font.pixelSize: 17
                font.bold: true
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                font.family: "JetBrainsMono Nerd Font"

                MouseArea {
                    id: titleMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (musicViewRoot.active) {
                            const url = musicViewRoot.active.metadata["xesam:url"]
                            if (url)
                                Qt.openUrlExternally(url)
                        }
                    }
                }

                color: Singletons.Colors.foreground
            }

            // Artist Name
            Text {
                id: musicArtistText
                font.family: "JetBrainsMono Nerd Font"

                Layout.fillWidth: true
                Layout.preferredHeight: 19
                text: musicViewRoot.active
                      ? musicViewRoot.active.trackArtist
                      : " "
                color: Singletons.Colors.foreground
                font.pixelSize: 12
                elide: Text.ElideRight
                opacity: 0.78
            }

            // Timeline
            Slider {
                id: positionSlider

                Layout.fillWidth: true
                Layout.preferredHeight: 12
                from: 0
                to: musicViewRoot.active && musicViewRoot.active.length > 0
                    ? musicViewRoot.active.length
                    : 100
                value: musicViewRoot.active ? Math.max(0, Math.min(musicViewRoot.active.position, to)) : 0

                HoverHandler {
                    target: null
                    cursorShape: Qt.PointingHandCursor
                }

                background: Rectangle {
                    x: positionSlider.leftPadding
                    y: positionSlider.topPadding + positionSlider.availableHeight / 2 - height / 2
                    width: positionSlider.availableWidth
                    height: 4
                    radius: 2
                    color: Singletons.Colors.sliderBackgroundColor

                    Rectangle {
                        width: positionSlider.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: Singletons.Colors.sliderBackgroundFillColor
                    }
                }

                handle: Rectangle {
                    x: positionSlider.leftPadding
                       + positionSlider.visualPosition * (positionSlider.availableWidth - width)
                    y: positionSlider.topPadding
                       + positionSlider.availableHeight / 2 - height / 2
                    width: 9
                    height: 9
                    radius: 5
                    color: Singletons.Colors.sliderBackgroundFillColor
                    border.color: Singletons.Colors.foreground
                    border.width: 1
                }

                onMoved: {
                    if (musicViewRoot.active)
                        musicViewRoot.active.position = value
                }
            }
            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: musicViewRoot.formatTime(musicViewRoot.active ? musicViewRoot.active.position : 0)
                    color: Singletons.Colors.foreground
                    font.pixelSize: 11
                    opacity: 0.7
                    font.family: "JetBrainsMono Nerd Font"
                }

                Text {
                    Layout.fillWidth: true
                    text: musicViewRoot.formatTime(musicViewRoot.active ? musicViewRoot.active.length : 0)
                    color: Singletons.Colors.foreground
                    font.pixelSize: 11
                    opacity: 0.7
                    horizontalAlignment: Text.AlignRight
                    font.family: "JetBrainsMono Nerd Font"
                }
            }
            FrameAnimation {
                running: musicViewRoot.active ? musicViewRoot.active.isPlaying : false

                onTriggered: {
                    if (musicViewRoot.active)
                        musicViewRoot.active.positionChanged()
                }
            }

            // Controls
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 34
                spacing: 16

                Text {
                    id: previousButton
                    font.family: "JetBrainsMono Nerd Font"

                    text: "󰒮"
                    color: previousMouse.containsMouse
                           ? Singletons.Colors.foreground
                           : Singletons.Colors.foregroundDim
                    font.pixelSize: 27

                    MouseArea {
                        id: previousMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (musicViewRoot.active && musicViewRoot.active.canGoPrevious)
                                musicViewRoot.active.previous()
                        }
                    }
                }

                Text {
                    id: playButton
                    font.family: "JetBrainsMono Nerd Font"

                    text: musicViewRoot.active && musicViewRoot.active.isPlaying ? "󰏤" : "󰐊"
                    color: playMouse.containsMouse
                           ? Singletons.Colors.foreground
                           : Singletons.Colors.foregroundDim
                    font.pixelSize: 31

                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (musicViewRoot.active)
                                musicViewRoot.active.togglePlaying()
                        }
                    }
                }

                Text {
                    id: nextButton

                    text: "󰒭"
                    font.family: "JetBrainsMono Nerd Font"
                    color: nextMouse.containsMouse
                           ? Singletons.Colors.foreground
                           : Singletons.Colors.foregroundDim
                    font.pixelSize: 27

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (musicViewRoot.active && musicViewRoot.active.canGoNext)
                                musicViewRoot.active.next()
                        }
                    }
                }
            }

            // Sources
            RowLayout {
                visible: Singletons.MusicSingleton.list.length > 1
                spacing: 8

                Text {
                    text: ""
                    color: previousMouse2.containsMouse
                        ? Singletons.Colors.foreground
                        : Singletons.Colors.foregroundDim

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14

                    MouseArea {
                        id: previousMouse2
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            const count = Singletons.MusicSingleton.list.length

                            if (count > 1) {
                                currentPlayerIndex =
                                    (currentPlayerIndex + count - 1) % count
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true

                    text: musicViewRoot.active
                        ? sourceName(musicViewRoot.active)
                        : "Нет источника"

                    color: Singletons.Colors.foreground
                    font.pixelSize: 11
                    font.family: "JetBrainsMono Nerd Font"
                    elide: Text.ElideMiddle
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: ""
                    color: nextMouse2.containsMouse
                        ? Singletons.Colors.foreground
                        : Singletons.Colors.foregroundDim
                    font.pixelSize: 14
                    font.family: "JetBrainsMono Nerd Font"

                    MouseArea {
                        id: nextMouse2
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            const count = Singletons.MusicSingleton.list.length

                            if (count > 1) {
                                currentPlayerIndex =
                                    (currentPlayerIndex + 1) % count
                            }
                        }
                    }
                }
            }
        }
    }
}
