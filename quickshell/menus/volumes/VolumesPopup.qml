import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick
import QtQuick.Controls
import Quickshell.Services.Pipewire

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

    implicitWidth: 300

    // Physical/virtual audio endpoints (application streams are excluded).
    property var outputDevices: Pipewire.nodes.values.filter(function(node) {
        return node.audio && !node.isStream && node.isSink
    })
    property var inputDevices: Pipewire.nodes.values.filter(function(node) {
        return node.audio && !node.isStream && !node.isSink
    })

    function audioNodeLabel(node, fallback) {
        if (!node)
            return fallback

        return node.nickname
               || node.description
               || node.name
               || fallback
    }
    implicitHeight: popupContent.idx == 0 ? 72 : 286 + 24
    color: "transparent"



    onVisibleChanged: {
        if (visible)
            openAnimation.restart()
    }

    Rectangle {
        id: popupContent

        property var idx: 0

        width: popup.width
        radius: Singletons.Colors.menuBorderRadius
        color: Singletons.Colors.menuBackground
        border.width: 1
        border.color: Singletons.Colors.menuBorderColor
        transformOrigin: Item.Top

        height: pageStack.currentIndex == 0 ? 72 : pageStack.height + 24

        Behavior on height {
            NumberAnimation {
                duration: 280
                easing.type: Easing.OutBack
                onRunningChanged: {
                    if (!running) {
                        popupContent.idx = pageStack.currentIndex
                    }
                }
            }
        }

        clip: true

        ParallelAnimation {
            id: openAnimation

            PropertyAnimation {
                target: popupContent
                property: "opacity"
                from: 0
                to: 1
                duration: 260
                easing.type: Easing.OutCubic
            }
            PropertyAnimation {
                target: popupContent
                property: "y"
                from: -100
                to: 0
                duration: 260
                easing.type: Easing.OutBack
            }

            PropertyAnimation {
                target: popupContent
                property: "scale"
                from: 0.85
                to: 1
                duration: 280
                easing.type: Easing.OutSine
            }

        }

        StackLayout {
            id: pageStack
            width: parent.width
            anchors.centerIn: parent
            currentIndex: 0
            height: {
                return currentIndex === 0
                        ? 48
                        : audioPage.implicitHeight
            }

            onCurrentIndexChanged: {
                updatePages();
            }
            Component.onCompleted: {
                updatePages();
            }

            function updatePages() {
                for (let i = 0; i < count; ++i) {
                    let page = itemAt(i);
                    if (!page)
                        continue;

                    page.opacity = (i === currentIndex) ? 1 : 0;
                }
            }

            // PAGE 1: only master volume and brightness
            ColumnLayout {
                id: overviewPage
                spacing: 10

                Behavior on opacity {
                    NumberAnimation {
                        duration: 280
                        easing.type: Easing.OutCubic
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

                        text: Singletons.AudioState.sink
                                ? Singletons.AudioState.sink.audio.muted
                                ? "󰝟 "
                                : "󰕾 "
                                : "󰕾 "

                        MouseArea {
                            anchors.fill: parent

                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                popupContent.idx = 1
                                pageStack.currentIndex = 1
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

                        value: parseInt(anchorItem.currentBrightness)

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
            }

            // PAGE 2: audio devices and per-application mixer
            ColumnLayout {
                id: audioPage
                spacing: 10
                implicitHeight: audioPageHeader.implicitHeight
                                + spacing
                                + Math.min(audioBodyContent.implicitHeight, 320)

                RowLayout {
                    id: audioPageHeader
                    Layout.fillWidth: true
                    Layout.rightMargin: 15
                    Layout.leftMargin: 15
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 8
                        color: "#e0282828"

                        Text {
                            anchors.centerIn: parent
                            text: "󰅁"
                            color: Singletons.Colors.foreground
                            font.pixelSize: 16
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: pageStack.currentIndex = 0
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Sounds and devices"
                        color: Singletons.Colors.foreground
                        font.pixelSize: 13
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 8
                        color: "#e0282828"

                        Text {
                            anchors.centerIn: parent
                            text: Singletons.AudioState.sink
                                    ? (Singletons.AudioState.sink.audio.muted ? "󰝟" : "󰕾")
                                    : "󰕾"
                            color: Singletons.Colors.foreground
                            font.pixelSize: 16
                        }

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
                }

                Flickable {
                    id: audioBodyFlickable
                    Layout.fillWidth: true
                    Layout.rightMargin: 15
                    Layout.leftMargin: 15
                    Layout.preferredHeight: Math.min(audioBodyContent.implicitHeight, 246)
                    Layout.minimumHeight: Math.min(audioBodyContent.implicitHeight, 246)
                    contentWidth: width
                    contentHeight: audioBodyContent.implicitHeight
                    flickableDirection: Flickable.VerticalFlick
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    interactive: contentHeight > height

                    ScrollBar.vertical: ScrollBar {
                        visible: false
                    }

                    ColumnLayout {
                        id: audioBodyContent
                        width: audioBodyFlickable.width
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: Singletons.Colors.separatorColor
                        }

                        ColumnLayout {
                            id: audioDevicesSection

                            Layout.fillWidth: true
                            Layout.leftMargin: 4
                            Layout.rightMargin: 4
                            spacing: 8

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3

                                Text {
                                    text: "Output"
                                    color: Singletons.Colors.foreground
                                    opacity: 0.75
                                    font.pixelSize: 10
                                }

                                ComboBox {
                                    id: outputDeviceCombo
                                    Layout.fillWidth: true
                                    implicitHeight: 34
                                    model: popup.outputDevices
                                    currentIndex: popup.outputDevices.indexOf(Pipewire.defaultAudioSink)
                                    displayText: popup.audioNodeLabel(
                                        Pipewire.defaultAudioSink,
                                        popup.outputDevices.length ? " " : "Not found device"
                                    )
                                    font.pixelSize: 11

                                    onActivated: {
                                        if (currentIndex >= 0 && currentIndex < popup.outputDevices.length)
                                            Pipewire.preferredDefaultAudioSink = popup.outputDevices[currentIndex]
                                    }

                                    contentItem: Text {
                                        leftPadding: 10
                                        rightPadding: outputDeviceCombo.indicator.width + 8
                                        text: outputDeviceCombo.displayText
                                        font: outputDeviceCombo.font
                                        color: Singletons.Colors.foreground
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }

                                    indicator: Text {
                                        x: outputDeviceCombo.width - width - 9
                                        y: (outputDeviceCombo.height - height) / 2
                                        text: "⌄"
                                        color: Singletons.Colors.foreground
                                        opacity: 0.8
                                        font.pixelSize: 15
                                    }

                                    background: Rectangle {
                                        radius: 8
                                        color: "#e0282828"
                                        border.width: 1
                                        border.color: '#78818181'
                                    }

                                    delegate: ItemDelegate {
                                        required property var modelData
                                        required property int index
                                        width: outputDeviceCombo.width
                                        height: 34
                                        highlighted: outputDeviceCombo.highlightedIndex === index

                                        contentItem: Text {
                                            text: popup.audioNodeLabel(modelData, "Unknown device")
                                            color: Singletons.Colors.foreground
                                            font.pixelSize: 11
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                        }

                                        background: Rectangle {
                                            radius: 6
                                            color: parent.highlighted
                                                    ? '#c74e4e4e'
                                                    : '#c7232222'
                                        }
                                    }

                                    popup: Popup {
                                        y: outputDeviceCombo.height - 1
                                        width: outputDeviceCombo.width
                                        implicitHeight: Math.min(contentItem.implicitHeight + 8, 180)
                                        padding: 4

                                        contentItem: ListView {
                                            clip: true
                                            implicitHeight: contentHeight
                                            model: outputDeviceCombo.popup.visible
                                                    ? outputDeviceCombo.delegateModel : null
                                            currentIndex: outputDeviceCombo.highlightedIndex
                                            ScrollIndicator.vertical: ScrollIndicator {}
                                        }

                                        background: Rectangle {
                                            radius: 9
                                            color: Singletons.Colors.menuBackground
                                            border.width: 1
                                            border.color: Singletons.Colors.menuBorderColor
                                        }
                                    }
                                }
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3

                                Text {
                                    text: "Input"
                                    color: Singletons.Colors.foreground
                                    opacity: 0.75
                                    font.pixelSize: 10
                                }

                                ComboBox {
                                    id: inputDeviceCombo
                                    Layout.fillWidth: true
                                    implicitHeight: 34
                                    model: popup.inputDevices
                                    currentIndex: popup.inputDevices.indexOf(Pipewire.defaultAudioSource)
                                    displayText: popup.audioNodeLabel(
                                        Pipewire.defaultAudioSource,
                                        popup.inputDevices.length ? " " : "Not found device"
                                    )
                                    font.pixelSize: 11

                                    onActivated: {
                                        if (currentIndex >= 0 && currentIndex < popup.inputDevices.length)
                                            Pipewire.preferredDefaultAudioSource = popup.inputDevices[currentIndex]
                                    }

                                    contentItem: Text {
                                        leftPadding: 10
                                        rightPadding: inputDeviceCombo.indicator.width + 8
                                        text: inputDeviceCombo.displayText
                                        font: inputDeviceCombo.font
                                        color: Singletons.Colors.foreground
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }

                                    indicator: Text {
                                        x: inputDeviceCombo.width - width - 9
                                        y: (inputDeviceCombo.height - height) / 2
                                        text: "⌄"
                                        color: Singletons.Colors.foreground
                                        opacity: 0.8
                                        font.pixelSize: 15
                                    }

                                    background: Rectangle {
                                        radius: 8
                                        color: "#e0282828"
                                        border.width: 1
                                        border.color: '#78818181'
                                    }

                                    delegate: ItemDelegate {
                                        required property var modelData
                                        required property int index
                                        width: inputDeviceCombo.width
                                        height: 34
                                        highlighted: inputDeviceCombo.highlightedIndex === index

                                        contentItem: Text {
                                            text: popup.audioNodeLabel(modelData, "Unknown device")
                                            color: Singletons.Colors.foreground
                                            font.pixelSize: 11
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                        }

                                        background: Rectangle {
                                            radius: 6
                                            color: parent.highlighted
                                                    ? '#c74e4e4e'
                                                    : '#c7232222'
                                        }
                                    }

                                    popup: Popup {
                                        y: inputDeviceCombo.height - 1
                                        width: inputDeviceCombo.width
                                        implicitHeight: Math.min(contentItem.implicitHeight + 8, 180)
                                        padding: 4

                                        contentItem: ListView {
                                            clip: true
                                            implicitHeight: contentHeight
                                            model: inputDeviceCombo.popup.visible
                                                    ? inputDeviceCombo.delegateModel : null
                                            currentIndex: inputDeviceCombo.highlightedIndex
                                            ScrollIndicator.vertical: ScrollIndicator {}
                                        }

                                        background: Rectangle {
                                            radius: 9
                                            color: Singletons.Colors.menuBackground
                                            border.width: 1
                                            border.color: Singletons.Colors.menuBorderColor
                                        }
                                    }
                                }
                            }
                            
                        }

                        Rectangle {
                            visible: Singletons.AudioState.streamNodes.length > 0
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: Singletons.Colors.separatorColor
                        }

                        ListView {
                            id: streamList

                            Layout.fillWidth: true
                            Layout.preferredHeight: contentHeight
                            interactive: false
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
            }
        }
        
    }

    Process {
        id: brightnessProcess

        running: true

        command: ["sh", "-c", "brightnessctl | grep -oP '\\(\\K[^)]+'"]

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