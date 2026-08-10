import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtCore
import Quickshell.Io
import Quickshell
import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects

import "../../Singletons" as Singletons

Item {
    id: screenshotsRoot

    property var popup
    property string screenshotsFolder: "file:///home/terabit/Pictures/Screenshots"

    Process {
        id: openImage
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            height: 20
            Text {
                text: "Screenshots"
                color: Singletons.Colors.foreground
                font.pixelSize: 16
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
            }
            Item {
                Layout.fillWidth: true
            }
            Text {
                text: "Open in Nemo"
                color: mouseArea.containsMouse ? "#ffffff" : '#9b9b9b'
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font"
                

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        openImage.command = ["nemo", screenshotsFolder]
                        openImage.running = true
                        popup.visible = false
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Singletons.Colors.foreground
            opacity: 0.1
        }

        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 103
            cellHeight: 103
            clip: true
            
            ScrollBar.vertical: ScrollBar {
                active: true
            }

            model: FolderListModel {
                folder: screenshotsRoot.screenshotsFolder
                nameFilters: ["*.png", "*.jpg", "*.jpeg"]
                sortField: FolderListModel.Time
            }

            delegate: Item {
                width: GridView.view.cellWidth - 2
                height: GridView.view.cellHeight - 2

                Rectangle {
                    id: coverFrame
                    anchors.fill: parent
                    anchors.margins: 0
                    color: "#302f2f2f"
                    radius: 8
                    clip: true
                    
                    border.color: dragArea.containsMouse ? Singletons.Colors.foreground : 'transparent'
                    border.width: 1
                    Behavior on border.color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }

                    Image {
                        id: img
                        anchors.fill: parent
                        source: filePath
                        fillMode: Image.PreserveAspectCrop
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
                        anchors.margins: 1
                        source: img
                        maskSource: coverMask
                        visible: img.status === Image.Ready
                    }

                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            singleClickTimer.selectedFilePath = filePath
                            singleClickTimer.restart()
                        }

                        onDoubleClicked: {
                            singleClickTimer.stop()

                            openImage.command = ["swayimg", filePath]
                            openImage.running = true

                            popup.visible = false
                        }
                    }
                }
            }
            
            Text {
                anchors.centerIn: parent
                visible: parent.count === 0
                text: "No screenshots"
                font.family: "JetBrainsMono Nerd Font"
                color: Singletons.Colors.foreground
                opacity: 0.5
            }
        }
    }
    Timer {
        id: singleClickTimer

        property string selectedFilePath: ""

        interval: 250
        repeat: false

        onTriggered: {
            copyImage.selectedFilePath = selectedFilePath
            copyImage.running = true
        }
    }
    Process {
        id: copyImage

        property string selectedFilePath: ""

        command: [
            "sh",
            "-c",
            "cat -- \"$1\" | wl-copy --type image/png",
            "sh",
            selectedFilePath
        ]

        onExited: {
            doSome.command = [
                "notify-send",
                "--icon", selectedFilePath,
                "--hint", "string:image-path:" + selectedFilePath,
                "Image copied",
                fileName(selectedFilePath)
            ]
            doSome.running = true
        }
    }
    Process {
        id: doSome
    }
    function fileName(path) {
        if (!path)
            return ""

        return path.split("/").pop()
    }
}
