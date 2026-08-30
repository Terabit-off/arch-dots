import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick
import QtQuick.Controls

import "../../Singletons" as Singletons

PopupWindow {
    id: popup

    visible: false
    grabFocus: true

    property Item anchorItem

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 25

    implicitWidth: 260
    implicitHeight: popupContent.implicitHeight
    color: "transparent"

    onVisibleChanged: {
        if (visible)
            openAnimation.restart()
    }

    Rectangle {
        id: popupContent

        anchors.fill: parent

        color: Singletons.Colors.menuBackground
        border.color: Singletons.Colors.menuBorderColor
        radius: Singletons.Colors.menuBorderRadius

        implicitHeight: mainColumn.implicitHeight + 20

        ParallelAnimation {
            id: openAnimation

            PropertyAnimation {
                target: popupContent
                property: "opacity"
                from: 0
                to: 1
                duration: 160
                easing.type: Easing.OutCubic
            }

            PropertyAnimation {
                target: popupContent
                property: "scale"
                from: 0.92
                to: 1
                duration: 180
                easing.type: Easing.OutQuint
            }
        }

        ColumnLayout {
            id: mainColumn

            anchors.fill: parent
            anchors.margins: 10

            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 18
                Layout.rightMargin: 15
                Layout.leftMargin: 15

                Text {
                    Layout.preferredWidth: 30

                    color: Singletons.Colors.foreground
                    font.bold: true
                    font.pixelSize: 15

                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter

                    text: Singletons.AudioState.sink
                          ? Singletons.AudioState.sink.audio.muted
                            ? "󰝟 "
                            : "󰕾 "
                          : "󰕾 "

                    MouseArea {
                        anchors.fill: parent

                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (Singletons.AudioState.sink)
                                Singletons.AudioState.sink.audio.muted =
                                    !Singletons.AudioState.sink.audio.muted
                        }
                    }
                }

                Slider {
                    id: soundVolumeSlider

                    Layout.fillWidth: true
                    Layout.preferredHeight: 18

                    from: 0
                    to: 100

                    value: Singletons.AudioState.sink
                           ? Singletons.AudioState.sink.audio.volume * 100
                           : 0

                    HoverHandler {
                        target: null
                        cursorShape: Qt.PointingHandCursor
                    }

                    background: Rectangle {
                        x: parent.leftPadding

                        y: parent.topPadding
                           + parent.availableHeight / 2
                           - height / 2

                        width: parent.availableWidth
                        height: 4

                        radius: 2

                        color: Singletons.Colors.sliderBackgroundColor

                        Rectangle {
                            width: parent.parent.visualPosition
                                   * parent.width

                            height: parent.height

                            color: Singletons.Colors.sliderBackgroundFillColor
                            radius: 2
                        }
                    }

                    handle: Rectangle {
                        x: parent.leftPadding
                           + parent.visualPosition
                           * (parent.availableWidth - width)

                        y: parent.topPadding
                           + parent.availableHeight / 2
                           - height / 2

                        width: 5
                        height: 10

                        radius: 4

                        color: Singletons.Colors.sliderHandlerColor
                    }

                    onMoved: {
                        if (!Singletons.AudioState.sink)
                            return

                        if (Singletons.AudioState.sink.audio.muted)
                            Singletons.AudioState.sink.audio.muted = false

                        Singletons.AudioState.sink.audio.volume =
                            value / 100
                    }
                }

                Text {
                    Layout.preferredWidth: 30

                    color: Singletons.Colors.foreground
                    font.bold: true

                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter

                    text: Math.round(soundVolumeSlider.value) + "%"
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 18
                Layout.rightMargin: 15
                Layout.leftMargin: 15

                Text {
                    Layout.preferredWidth: 30

                    color: Singletons.Colors.foreground

                    font.bold: true
                    font.pixelSize: 15

                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter

                    text: "󰃠 "
                }

                Slider {
                    id: brightnessVolumeSlider

                    Layout.fillWidth: true
                    Layout.preferredHeight: 18

                    from: 0
                    to: 100

                    value:
                        Math.round(
                            anchorItem.currentBrightness / 64507 * 100
                        )

                    HoverHandler {
                        target: null

                        cursorShape:
                            Qt.PointingHandCursor
                    }

                    background: Rectangle {
                        x: parent.leftPadding

                        y:
                            parent.topPadding
                            + parent.availableHeight / 2
                            - height / 2

                        height: 4
                        width: parent.availableWidth

                        radius: 2

                        color:
                            Singletons.Colors.sliderBackgroundColor

                        Rectangle {
                            width:
                                parent.parent.visualPosition
                                * parent.width

                            height: parent.height

                            color:
                                Singletons.Colors
                                .sliderBackgroundFillColor

                            radius: 2
                        }
                    }

                    handle: Rectangle {
                        x:
                            parent.leftPadding
                            + parent.visualPosition
                            * (parent.availableWidth - width)

                        y:
                            parent.topPadding
                            + parent.availableHeight / 2
                            - height / 2

                        width: 5
                        height: 10

                        radius: 4

                        color:
                            Singletons.Colors.sliderHandlerColor
                    }

                    onMoved: {
                        brightnessSet.command = [
                            "brightnessctl",
                            "s",
                            value + "%"
                        ]

                        brightnessSet.running = true
                        brightnessProcess.running = true
                    }
                }

                Text {
                    Layout.preferredWidth: 30

                    color: Singletons.Colors.foreground

                    font.bold: true

                    verticalAlignment:
                        Text.AlignVCenter

                    horizontalAlignment:
                        Text.AlignRight

                    text:
                        Math.round(
                            brightnessVolumeSlider.value
                        ) + "%"
                }
            }

            

            // APPLICATION MIXER
            Rectangle {
                visible: Singletons.AudioState.streamNodes.length > 0
                Layout.fillWidth: true
                Layout.preferredHeight: 1

                color: Singletons.Colors.separatorColor
            }
            ListView {
                id: streamList

                Layout.fillWidth: true
                Layout.preferredHeight:
                    Math.min(contentHeight, 300)

                clip: true

                spacing: 5

                model: Singletons.AudioState.streamNodes

                delegate: Rectangle {
                    id: streamDelegate

                    required property var modelData

                    width: streamList.width
                    height: 50

                    color: "transparent"

                    radius: 10

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        anchors.topMargin: 5
                        anchors.bottomMargin: 5

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 15

                            color: Singletons.Colors.foreground

                            font.pixelSize: 12
                            font.bold: true

                            elide: Text.ElideRight

                            verticalAlignment: Text.AlignVCenter

                            text:
                                displayName(streamDelegate.modelData)
                                + subName(streamDelegate.modelData)
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            spacing: 5

                            Text {
                                Layout.preferredWidth: 25

                                color: Singletons.Colors.foreground

                                font.bold: true
                                font.pixelSize: 14

                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter

                                text:
                                    streamDelegate.modelData.audio
                                    && streamDelegate.modelData.audio.muted
                                    ? "󰝟"
                                    : "󰕾"

                                MouseArea {
                                    anchors.fill: parent

                                    cursorShape:
                                        Qt.PointingHandCursor

                                    onClicked: {
                                        if (streamDelegate.modelData.audio
                                            && streamDelegate.modelData.ready) {

                                            streamDelegate.modelData.audio.muted =
                                                !streamDelegate.modelData.audio.muted
                                        }
                                    }
                                }
                            }

                            Slider {
                                id: appVolumeSlider

                                Layout.fillWidth: true
                                Layout.preferredHeight: 18

                                from: 0
                                to: 150

                                value:
                                    streamDelegate.modelData.audio
                                    ? streamDelegate.modelData.audio.volume * 100
                                    : 100

                                HoverHandler {
                                    target: null
                                    cursorShape:
                                        Qt.PointingHandCursor
                                }

                                background: Rectangle {
                                    x: parent.leftPadding

                                    y: parent.topPadding
                                       + parent.availableHeight / 2
                                       - height / 2

                                    width: parent.availableWidth
                                    height: 4

                                    radius: 2

                                    color:
                                        Singletons.Colors
                                        .sliderBackgroundColor

                                    Rectangle {
                                        width:
                                            parent.parent.visualPosition
                                            * parent.width

                                        height: parent.height

                                        radius: 2

                                        color:
                                            Singletons.Colors
                                            .sliderBackgroundFillColor
                                    }
                                }

                                handle: Rectangle {
                                    x:
                                        parent.leftPadding
                                        + parent.visualPosition
                                        * (parent.availableWidth - width)

                                    y:
                                        parent.topPadding
                                        + parent.availableHeight / 2
                                        - height / 2

                                    width: 5
                                    height: 10

                                    radius: 4

                                    color:
                                        Singletons.Colors
                                        .sliderHandlerColor
                                }

                                onMoved: {
                                    if (streamDelegate.modelData.audio
                                        && streamDelegate.modelData.ready) {

                                        if (streamDelegate.modelData.audio.muted)
                                            streamDelegate.modelData.audio.muted = false

                                        streamDelegate.modelData.audio.volume =
                                            value / 100
                                    }
                                }
                            }

                            Text {
                                Layout.preferredWidth: 35

                                color:
                                    Singletons.Colors.foreground

                                font.bold: true

                                horizontalAlignment:
                                    Text.AlignRight

                                verticalAlignment:
                                    Text.AlignVCenter

                                text:
                                    Math.round(
                                        appVolumeSlider.value
                                    ) + "%"
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1

                            color: Singletons.Colors.separatorColor
                        }
                    }
                }
            }         
        }
    }

    Process {
        id: brightnessProcess

        running: true

        command: [
            "brightnessctl",
            "g"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                anchorItem.currentBrightness =
                    parseInt(this.text.trim())
            }
        }
    }

    Process {
        id: brightnessSet
    }

    // APPLICATION NAMES
    function displayName(node) {
        if (!node)
            return "Unknown"

        const props = node.properties || {}

        const name =
            props["application.name"]
            || node.description
            || node.nickname
            || props["media.name"]
            || node.name
            || "Unknown"

        // WTF????
        if (name === "audio-src")
            return "Spotify"

        return truncate(name)
    }

    function subName(node) {
        if (!node)
            return ""

        const props = node.properties || {}

        const name =
            props["media.name"] || "Unknown"

        if (name === "audio-src")
            return ""

        return "  -  " + truncate(name)
    }

    function truncate(text) {
        if (!text || text.length <= 18)
            return text

        return text.substring(0, 18) + "..."
    }
}