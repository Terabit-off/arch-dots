import QtQuick
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects
import QtQuick.Controls

import "../../Singletons" as Singletons
import "." as Modules

PopupWindow {
    id: centerWindowRoot
    grabFocus: true
    visible: false
    implicitWidth: 550
    implicitHeight: 220
    color: "transparent"

    property var active: musicView.active

    anchor {
        item: anchorItem
        edges: Edges.Bottom
        gravity: Edges.Bottom
        margins.top: 25
    }

    onVisibleChanged: {
        if (visible)
            openAnimation.restart()
    }

    property Item anchorItem
    property int currentSegmentIndex: 0

    component NavButton: Item {
        id: btn
        property string iconText
        property bool isActive
        signal clicked()

        width: 40
        height: 40

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: btn.isActive
                ? Singletons.Colors.activeButtonBackgroundColor
                : (mouseArea.containsMouse 
                    ? Singletons.Colors.buttonBackgroundColorHover
                    : Singletons.Colors.buttonBackgroundColor)

            Text {
                anchors.centerIn: parent
                text: btn.iconText
                font.family: "JetBrainsMono Nerd Font"
                color: btn.isActive || mouseArea.containsMouse ? Singletons.Colors.foreground 
                    : Singletons.Colors.foregroundDim
                font.pixelSize: 20
            }
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    Rectangle {
        id: popupContent
        width: centerWindowRoot.implicitWidth
        height: centerWindowRoot.implicitHeight
        color: Singletons.Colors.menuBackground
        radius: Singletons.Colors.menuBorderRadius
        border.color: Singletons.Colors.menuBorderColor
        border.width: 1
        transformOrigin: Item.Center

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

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // left navigation panel
            Rectangle {
                Layout.preferredWidth: 60
                Layout.fillHeight: true
                color: "transparent" //Singletons.Colors.menuBackground
                radius: popupContent.radius
                
                Rectangle {
                    width: popupContent.radius
                    height: parent.height
                    anchors.right: parent.right
                    color: Singletons.Colors.menuBackground
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16

                    NavButton {
                        iconText: "󰝚"
                        isActive: centerWindowRoot.currentSegmentIndex === 0
                        onClicked: centerWindowRoot.currentSegmentIndex = 0
                    }
                    NavButton {
                        iconText: "󰄄"
                        isActive: centerWindowRoot.currentSegmentIndex === 1
                        onClicked: centerWindowRoot.currentSegmentIndex = 1
                    }
                    NavButton {
                        iconText: "󰍛"
                        isActive: centerWindowRoot.currentSegmentIndex === 2
                        onClicked: centerWindowRoot.currentSegmentIndex = 2
                    }
                }
            }

            // separator
            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: Singletons.Colors.separatorColor
                opacity: 0.3
            }

            // Main area with segment switching
            StackLayout {
                id: contentStack
                Layout.fillWidth: true
                Layout.fillHeight: true

                currentIndex: centerWindowRoot.currentSegmentIndex

                function updatePages() {
                    for (let i = 0; i < count; ++i) {
                        let page = itemAt(i)
                        if (!page)
                            continue

                        page.opacity = (i === currentIndex) ? 1 : 0
                        page.x = (i === currentIndex) ? 0 : 20
                    }
                }

                onCurrentIndexChanged:{
                    updatePages()

                } 
                Component.onCompleted: {
                    updatePages()
                }
                Modules.MusicView {
                    id: musicView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    popup: centerWindowRoot

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on x {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Modules.ScreenshotsView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    popup: centerWindowRoot

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on x {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Modules.SystemResourcesView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on x {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
