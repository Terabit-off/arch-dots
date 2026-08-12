import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick
import QtQuick.Controls


import "../../Singletons" as Singletons

Rectangle {
    id: rootRec
    color: Singletons.Colors.barModuleColor
    radius: 5
    Layout.fillHeight: true
    implicitWidth: root.implicitWidth + 10
    property int currentBrightness: 0

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            popup.visible = true
        }
    }
   

    RowLayout {
        id: root
        spacing: 15
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 5
        }



        Text {
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignHCenter
            text: "󰃠 " + Math.round(currentBrightness/ 64507 * 100)
            color: Singletons.Colors.foreground
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onWheel: function(wheel) {
                    if (wheel.angleDelta.y > 0) {

                        brightnessSet.command = ["brightnessctl", "s", "+5%"]
                        brightnessSet.running = true
                        brightnessProcess.running = true
                    }
                    else{

                        brightnessSet.command = ["brightnessctl", "s", "5%-"]
                        brightnessSet.running = true
                        brightnessProcess.running = true
                    }

                    wheel.accepted = true
                }
                onClicked: {
                    popup.visible = true
                }
            }
        }

        Text {
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignHCenter
            text: {
                return "󰕾 " + (Singletons.AudioState.sink ? Math.round(Singletons.AudioState.sink.audio.volume * 100) + "%" : 0 + "%")
            }
            color: Singletons.Colors.foreground
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onWheel: function(wheel) {
                    if (wheel.angleDelta.y > 0) {
                        if (Singletons.AudioState.sink.audio.muted) Singletons.AudioState.sink.audio.muted = false;
                        Singletons.AudioState.sink.audio.volume =
                            Math.min(1.0, Singletons.AudioState.sink.audio.volume + 0.05)
                    }
                    else{
                        if (Singletons.AudioState.sink.audio.muted) Singletons.AudioState.sink.audio.muted = false;
                        Singletons.AudioState.sink.audio.volume -= 0.05
                    }

                    wheel.accepted = true
                }
                onClicked: {
                    popup.visible = true
                }
            }
        }
    }

    PopupWindow {
        id: popup

        visible: false
        grabFocus: true

        anchor.item: rootRec
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.margins.top: 25

        implicitWidth: 200
        implicitHeight: 70
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
                anchors.fill: parent
                anchors.centerIn: parent
                anchors.margins: {
                    left: 10
                    right: 10
                }
                
                // sound
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumHeight: 10
                    Layout.maximumWidth: 220
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    Text{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumWidth: 30
                        color: Singletons.Colors.foreground
                        font.bold: true
                        font.pixelSize: 15
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter 
                        text: Singletons.AudioState.sink ? Singletons.AudioState.sink.audio.muted ? "󰝟 " : "󰕾 " : "󰕾 "

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Singletons.AudioState.sink.audio.muted = !Singletons.AudioState.sink.audio.muted
                            }
                        }
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
                        to: 100
                        value: Singletons.AudioState.sink ? Singletons.AudioState.sink.audio.volume * 100 : 0

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
                            if (Singletons.AudioState.sink.audio.muted) Singletons.AudioState.sink.audio.muted = false;
                            Singletons.AudioState.sink.audio.volume = value / 100
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
                // brightness
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumHeight: 10
                    Layout.maximumWidth: 220
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    Text{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumWidth: 30
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
                        Layout.fillHeight: true
                        Layout.minimumWidth: 100
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        from: 0
                        to: 100
                        value: Math.round(currentBrightness/ 64507 * 100)

                        HoverHandler {
                            target: null
                            cursorShape: Qt.PointingHandCursor
                        }

                        background: Rectangle {
                            x: parent.leftPadding
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            height: 4
                            width: parent.availableWidth
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
                            brightnessSet.command = ["brightnessctl", "s", value + "%"]
                            brightnessSet.running = true
                            brightnessProcess.running = true
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 30
                        Layout.maximumWidth: 30
                        color: Singletons.Colors.foreground
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        text: Math.round(brightnessVolumeSlider.value) + "%"
                    }
                }
            }
        }
    }

    Process {
        id: brightnessProcess
        running: true
        command: ["brightnessctl", "g"]
        
        stdout: StdioCollector {
            onStreamFinished: currentBrightness = parseInt(this.text.trim())
        }
    }
    Process {
        id: brightnessSet
    }
}