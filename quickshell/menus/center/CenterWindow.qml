import "." as Modules
import "../../Singletons" as Singletons
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

PopupWindow {
    id: centerWindowRoot

    property var active: musicView.active
    property Item anchorItem
    property int currentSegmentIndex: 0

    grabFocus: true
    visible: false
    implicitWidth: 550
    implicitHeight: 220
    color: "transparent"
    onVisibleChanged: {
        if (visible) {
            openAnimation.restart();
            timeDateView.today();
        }
    }

    anchor {
        item: anchorItem
        edges: Edges.Bottom
        gravity: Edges.Bottom
        margins.top: 25
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
                Layout.preferredWidth: 64
                Layout.fillHeight: true
                color: "transparent"
                radius: popupContent.radius

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 10

                    NavButton {
                        iconText: ""
                        isActive: centerWindowRoot.currentSegmentIndex === 0
                        onClicked: centerWindowRoot.currentSegmentIndex = 0
                    }

                    NavButton {
                        iconText: "󰝚"
                        isActive: centerWindowRoot.currentSegmentIndex === 1
                        onClicked: centerWindowRoot.currentSegmentIndex = 1
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

                function updatePages() {
                    for (let i = 0; i < count; ++i) {
                        let page = itemAt(i);
                        if (!page)
                            continue;

                        page.opacity = (i === currentIndex) ? 1 : 0;
                        page.x = (i === currentIndex) ? 0 : 20;
                    }
                }

                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: centerWindowRoot.currentSegmentIndex
                onCurrentIndexChanged: {
                    updatePages();
                }
                Component.onCompleted: {
                    updatePages();
                }

                Modules.DateTimeView {
                    id: timeDateView

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

            }

        }

    }

    component NavButton: Item {
        id: btn

        property string iconText
        property bool isActive

        signal clicked()

        width: 40
        height: 40

        Rectangle {
            anchors.fill: parent
            radius: Singletons.Colors.controlRadius
            color: btn.isActive ? Singletons.Colors.controlActive : (mouseArea.containsMouse ? Singletons.Colors.controlHover : Singletons.Colors.buttonBackgroundColor)

            Text {
                anchors.centerIn: parent
                text: btn.iconText
                font.family: "JetBrainsMono Nerd Font"
                color: btn.isActive || mouseArea.containsMouse ? Singletons.Colors.foreground : Singletons.Colors.foregroundDim
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

}
