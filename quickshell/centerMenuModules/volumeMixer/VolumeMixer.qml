import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import "../../Singletons" as Singletons

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true

    property bool opened: false

    Layout.maximumHeight: {
        if (opened){
            const s = 50 + Singletons.AudioState.streamNodes.length * 50 + ((Singletons.AudioState.streamNodes.length - 1) * 5);
            if (300 < s) {
                return 300;
            }
            return s;
        }
        return 35;
    }
    radius: Singletons.Colors.moduleBorderRadius
    color: Singletons.Colors.moduleBackgroundColor
    border.color: Singletons.Colors.moduleBorderColor
    visible: Singletons.AudioState.streamNodes.length > 0
    clip: true

    Behavior on Layout.maximumHeight {
        NumberAnimation {
            duration: 220
            easing.type: Easing.InOutCubic
        }
    }

    ColumnLayout {
        anchors.fill: parent
        Text {
            text: "Audio Mixer "
            color: Singletons.Colors.foreground
            font.pixelSize: 12
            font.bold: true
            Layout.maximumHeight: 10
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 10
            Layout.topMargin: 10
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    opened = !opened;
                    parent.text = opened ? "Audio Mixer " : "Audio Mixer "
                }
            }
        }
        ListView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: Singletons.AudioState.streamNodes
            clip: true
            spacing: 5
            Layout.margins: 10

            delegate: Rectangle {
                color: '#393939'
                radius: 10
                width: parent.width//226
                border.color: Singletons.Colors.buttonBorderColor
                height: 50

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10

                    Text {
                        color: Singletons.Colors.foreground
                        font.pixelSize: 12
                        Layout.maximumHeight: 5
                        font.bold: true
                        text: {
                            return displayName(modelData) + subName(modelData);
                        }
                    }
                    // SLIDER
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: 10
                        Layout.maximumWidth: 200
                        Layout.alignment: Qt.AlignVCenter

                        Text{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.maximumWidth: 30
                            color: Singletons.Colors.foreground
                            font.bold: true
                            font.pixelSize: 15
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter 
                            text: "󰕾"
                        }
                        Slider {
                            id: soundVolumeSlider
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 5
                            Layout.maximumHeight: 5
                            Layout.minimumWidth: 100
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            from: 0
                            to: 153 //MY MAXIMUM BOOST
                            value: modelData.audio ? modelData.audio.volume * 100 : 100

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
                                width: 5
                                height: 10
                                radius: 4
                                color: Singletons.Colors.sliderHandlerColor
                            }
                            onMoved: {
                                if (modelData.audio && modelData.ready)
                                    modelData.audio.volume = value / 100
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumWidth: 30
                            Layout.maximumWidth: 30
                            color: Singletons.Colors.foreground
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            text: Math.round(soundVolumeSlider.value) + "%"
                        }
                    }
                }
            }
        }
    }


    function displayName(node) {
        if (!node) return "Unknown";

        const props = node.properties || {};
        const name = props["application.name"]
            || node.description
            || node.nickname
            || props["media.name"]
            || node.name
            || "Unknown";

        // WTF????
        if (name === "audio-src") return "Spotify";
        return truncate(name);
    }
    function subName(node) {
        if (!node) return "Unknown";

        const props = node.properties || {};
        const name = props["media.name"] || "Unknown";
        if (name === "audio-src") return ""
        return "    -    " + truncate(name);
    }

    function truncate(text) {
        if (!text || text.length <= 18) return text;
        return text.substring(0, 18) + "...";
    }
}