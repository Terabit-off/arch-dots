import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PopupWindow {
    id: root
    property var anchorItem: null

    visible: false

    anchor.item: anchorItem

    anchor.rect.x: anchorItem ? (anchorItem.width - width) / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 10 : 0

    grabFocus: true

    implicitWidth: 1040
    implicitHeight: 720

    color: "transparent"

    // ============================================================
    // BACKGROUND
    // ============================================================

    Rectangle {
        id: background

        anchors.fill: parent
        radius: 5

        color: "#f11c1c1c"
        border.width: 1
        border.color: "#db6e6e6e"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // ============================================================
            // HEADER
            // ============================================================

            RowLayout {
                id: header
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                spacing: 12

                // Title Icon & Name
                RowLayout {
                    spacing: 8

                    Text {
                        text: "󰍹"
                        color: "#ffffff"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 18
                    }

                    Text {
                        text: "Overview"
                        color: "#eeeeef"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }
                }

                // Window Count Badge
                Rectangle {
                    radius: 12
                    color: "#20ffffff"
                    implicitWidth: countText.implicitWidth + 14
                    implicitHeight: 22

                    Text {
                        id: countText
                        anchors.centerIn: parent
                        text: Hyprland.toplevels.count + " windows"
                        color: "#aaaaaf"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                    }
                }

                Item { Layout.fillWidth: true }

                // Focused Workspace Indicator
                Rectangle {
                    visible: Hyprland.focusedWorkspace !== null
                    radius: 8
                    color: "#15ffffff"
                    border.width: 1
                    border.color: "#25ffffff"
                    implicitWidth: wsText.implicitWidth + 16
                    implicitHeight: 26

                    Text {
                        id: wsText
                        anchors.centerIn: parent
                        text: Hyprland.focusedWorkspace ? "Active Workspace " + Hyprland.focusedWorkspace.id : ""
                        color: "#dddddf"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                    }
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#15ffffff"
            }

            // ============================================================
            // WORKSPACES LIST
            // ============================================================

            Flickable {
                id: workspaceFlickable

                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true
                contentWidth: width
                contentHeight: workspaceColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    policy: workspaceFlickable.contentHeight > workspaceFlickable.height
                            ? ScrollBar.AsNeeded
                            : ScrollBar.AlwaysOff
                }

                Column {
                    id: workspaceColumn
                    width: workspaceFlickable.width
                    spacing: 20

                    Repeater {
                        model: Hyprland.workspaces

                        delegate: Rectangle {
                            id: workspaceDelegate
                            required property var modelData

                            width: workspaceColumn.width
                            implicitHeight: wsLayout.implicitHeight + 24

                            radius: 12
                            color: modelData.focused ? "#12ffffff" : "#08ffffff"
                            border.width: 1
                            border.color: modelData.focused ? "#30ffffff" : "#10ffffff"

                            ColumnLayout {
                                id: wsLayout
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                    margins: 12
                                }
                                spacing: 12

                                // WORKSPACE HEADER
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    // Workspace Tag
                                    Rectangle {
                                        implicitWidth: 28
                                        implicitHeight: 24
                                        radius: 6
                                        color: workspaceDelegate.modelData.focused ? "#ffffff" : "#25ffffff"

                                        Text {
                                            anchors.centerIn: parent
                                            text: workspaceDelegate.modelData.name
                                            color: workspaceDelegate.modelData.focused ? "#111114" : "#cccccc"
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11
                                            font.weight: Font.Bold
                                        }
                                    }

                                    // Active Status Dot
                                    Rectangle {
                                        width: 6
                                        height: 6
                                        radius: 3
                                        color: "#52b788"
                                        visible: workspaceDelegate.modelData.focused
                                    }

                                    Text {
                                        text: workspaceDelegate.modelData.focused ? "Active" : ""
                                        color: "#88888f"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: workspaceDelegate.modelData.toplevels.count + " windows"
                                        color: "#66666d"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                    }
                                }

                                // WINDOWS FLOW
                                Flow {
                                    Layout.fillWidth: true
                                    spacing: 12

                                    Repeater {
                                        model: workspaceDelegate.modelData.toplevels

                                        delegate: Item {
                                            id: windowDelegate
                                            required property var modelData

                                            width: 236
                                            height: 160

                                            // WINDOW CARD
                                            Rectangle {
                                                id: card
                                                anchors.fill: parent
                                                radius: 10

                                                color: cardMouse.containsMouse ? "#28ffffff" : "#18ffffff"
                                                border.width: windowDelegate.modelData.activated ? 2 : (cardMouse.containsMouse ? 1 : 0)
                                                border.color: windowDelegate.modelData.activated ? "#ffffff" : "#45ffffff"

                                                scale: cardMouse.containsMouse ? 1.02 : 1.0
                                                clip: true

                                                Behavior on scale {
                                                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                                                }
                                                Behavior on color {
                                                    ColorAnimation { duration: 120 }
                                                }

                                                // 1. ГЛАВНАЯ КНОПКА КАРТОЧКИ (ФОНОВЫЙ СЛОЙ)
                                                

                                                // 2. ВЕРХНИЙ СЛОЙ С ИНТЕРФЕЙСОМ И КНОПКОЙ ЗАКРЫТИЯ
                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 6
                                                    spacing: 6

                                                    // PREVIEW CONTAINER
                                                    Rectangle {
                                                        Layout.fillWidth: true
                                                        Layout.fillHeight: true
                                                        radius: 6
                                                        color: "#101012"
                                                        clip: true

                                                        ScreencopyView {
                                                            id: preview
                                                            anchors.fill: parent
                                                            captureSource: windowDelegate.modelData.wayland
                                                            live: true
                                                            paintCursor: false
                                                            visible: hasContent
                                                            opacity: hasContent ? 1 : 0

                                                            Behavior on opacity {
                                                                NumberAnimation { duration: 180 }
                                                            }
                                                        }

                                                        // FALLBACK ICON
                                                        Text {
                                                            anchors.centerIn: parent
                                                            visible: !preview.hasContent
                                                            text: "󰖟"
                                                            color: "#44444c"
                                                            font.family: "JetBrainsMono Nerd Font"
                                                            font.pixelSize: 28
                                                        }
                                                    }

                                                    // WINDOW INFO BAR
                                                    RowLayout {
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: 22
                                                        spacing: 6

                                                        Text {
                                                            text: "󰖯"
                                                            color: "#aaaaaf"
                                                            font.family: "JetBrainsMono Nerd Font"
                                                            font.pixelSize: 11
                                                        }

                                                        Text {
                                                            Layout.fillWidth: true
                                                            text: windowDelegate.modelData.title || "Window"
                                                            color: "#dddddf"
                                                            font.family: "JetBrainsMono Nerd Font"
                                                            font.pixelSize: 9
                                                            elide: Text.ElideRight
                                                            maximumLineCount: 1
                                                        }

                                                        // Close Window Button on Hover
                                                        Rectangle {
                                                            implicitWidth: 18
                                                            implicitHeight: 18
                                                            radius: 4
                                                            color: closeWinMouse.containsMouse ? "#a54242" : "transparent"
                                                            visible: cardMouse.containsMouse

                                                            Text {
                                                                anchors.centerIn: parent
                                                                text: "󰅖"
                                                                color: "#ffffff"
                                                                font.family: "JetBrainsMono Nerd Font"
                                                                font.pixelSize: 10
                                                            }

                                                            MouseArea {
                                                                id: closeWinMouse
                                                                anchors.fill: parent
                                                                hoverEnabled: true
                                                                cursorShape: Qt.PointingHandCursor
                                                                
                                                                // Блокируем передачу клика на фоновый cardMouse
                                                                propagateComposedEvents: false 
                                                                
                                                                onClicked: {
                                                                    // В Hyprland/Wayland у toplevel обычно есть метод close() или requestClose()
                                                                    if (typeof windowDelegate.modelData.close === "function") {
                                                                        windowDelegate.modelData.close()
                                                                    } else if (typeof windowDelegate.modelData.requestClose === "function") {
                                                                        windowDelegate.modelData.requestClose()
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                MouseArea {
                                                    id: cardMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: root.focusWindow(windowDelegate.modelData)
                                                }
                                            }
                                        }
                                    }

                                    // EMPTY WORKSPACE PLACEHOLDER
                                    Rectangle {
                                        visible: workspaceDelegate.modelData.toplevels.count === 0
                                        width: 200
                                        height: 40
                                        radius: 8
                                        color: "#08ffffff"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Empty workspace"
                                            color: "#55555c"
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 10
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // FOCUS WINDOW FUNCTION
    function focusWindow(toplevel) {
        if (!toplevel)
            return

        const workspace = toplevel.workspace

        if (workspace)
            workspace.activate()

        if (toplevel.wayland)
            toplevel.wayland.activate()

        root.visible = false
    }
}