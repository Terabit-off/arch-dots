import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtCore
import Quickshell.Io
import Qt.labs.folderlistmodel

import "../../Singletons" as Singletons

Item {
    id: screenshotsRoot

    property var popup
    // Укажите путь до папки со скриншотами (по умолчанию стандартная папка Pictures/Screenshots)
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

        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 120
            cellHeight: 120
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
                width: GridView.view.cellWidth
                height: GridView.view.cellHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 0
                    color: "#302f2f2f"
                    radius: 8
                    clip: true
                    
                    border.color: dragArea.containsMouse ? Singletons.Colors.foreground : "transparent"
                    border.width: 1

                    Image {
                        id: img
                        anchors.fill: parent
                        anchors.margins: {
                            top: 5
                            left: 5
                            right: 5
                            bottom: 5
                        }
                        source: filePath
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                    }

                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onDoubleClicked: {
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
}
