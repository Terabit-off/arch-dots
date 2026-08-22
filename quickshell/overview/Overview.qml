import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io

import "../Singletons" as Singletons

PanelWindow {
    id: overviewWindow

    visible: false
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    implicitWidth: Math.min(1320, 320 * sortedToplevels.length + 40)
    implicitHeight: Math.min(800, windowGrid.contentHeight + 40)
    property bool isOpen: false

    readonly property var sortedToplevels: {
        const list = Hyprland.toplevels.values.slice();
        return list.sort((a, b) => {
            const wsA = a.workspace?.id ?? 0;
            const wsB = b.workspace?.id ?? 0;
            if (wsA !== wsB) return wsA - wsB;
            
            // Если окна на одном рабочем столе, сортируем по названию
            return (a.title || "").localeCompare(b.title || "");
        });
    }
    

    HyprlandFocusGrab {
        active: overviewWindow.visible
        windows: [ overviewWindow ]
        onCleared: overviewWindow.visible = false
    }

    IpcHandler {
        target: "overview"

        function close() { closeOverview() }
        function toggle(address: string) { 
            if (!isOpen) {
                openOverview(address);
            } else {
                closeOverview()
            }  
        }
    }
    function openOverview(address) {
        selectFocusedWindow(address);
        hideAnim.stop();

        if (!visible) {
            mainContainer.opacity = 0;
            slideTransform.y = 120;
            visible = true;
        }

        isOpen = true;
        showAnim.start();
    }
    function closeOverview() {
        if (!isOpen) return;
        isOpen = false;
        showAnim.stop();
        hideAnim.start();
    }

    Shortcut {
        sequence: "Escape"
        onActivated: closeOverview()
    }

    function selectFocusedWindow(address) {
        const items = Hyprland.toplevels.values;
        for (let i = 0; i < items.length; i++) {
            if (items[i].address === address.slice(2)) {
                windowGrid.currentIndex = i;
                return;
            }
        }
        windowGrid.currentIndex = 0;
    }


    ParallelAnimation {
        id: showAnim
        NumberAnimation { target: mainContainer; property: "opacity"; to: 1; duration: 150; easing.type: Easing.OutCubic }
        NumberAnimation { target: slideTransform; property: "y"; to: 0; duration: 250; easing.type: Easing.OutCubic }
    }

    ParallelAnimation {
        id: hideAnim
        NumberAnimation { target: mainContainer; property: "opacity"; to: 0; duration: 150; easing.type: Easing.InCubic }
        NumberAnimation { target: slideTransform; property: "y"; to: 120; duration: 200; easing.type: Easing.InCubic }

        onFinished: {
            overviewWindow.visible = false;
        }
    }

    Rectangle {
        id: mainContainer
        anchors.fill: parent
        color: Singletons.Colors.overviewBackground
        radius: Singletons.Colors.menuBorderRadius
        border.color: Singletons.Colors.menuBorderColor
        border.width: 1

        opacity: overviewWindow.isOpen ? 1 : 0

        transform: Translate {
            id: slideTransform
            y: 120
        }

        GridView {
            id: windowGrid
            anchors.margins: 20
            anchors.fill: parent
            anchors.centerIn: parent
            clip: true

            cellWidth: 320
            cellHeight: 230

            model: overviewWindow.sortedToplevels


            focus: true
            keyNavigationWraps: true

            Keys.onPressed: (event) => {
                if (count === 0) return;

                if (event.key === Qt.Key_Tab) {
                    if (event.modifiers & Qt.ShiftModifier) {
                        currentIndex = (currentIndex - 1 + count) % count;
                    } else {
                        currentIndex = (currentIndex + 1) % count;
                    }
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    if (currentItem && currentItem.modelData) {
                        currentItem.modelData.wayland.activate();
                        closeOverview();
                    }
                    event.accepted = true;
                } else if (event.key === Qt.Key_Left) {
                    currentIndex = (currentIndex - 1 + count) % count;
                    event.accepted = true;
                } else if (event.key === Qt.Key_Right) {
                    currentIndex = (currentIndex + 1) % count;
                    event.accepted = true;
                } else if (event.key === Qt.Key_Up) {
                    currentIndex = Math.max(0, currentIndex - windowGrid.columnsCount);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Down) {
                    currentIndex = Math.min(count - 1, currentIndex + windowGrid.columnsCount);
                    event.accepted = true;
                }
            }

            delegate: Rectangle {
                id: card
                required property var modelData
                required property int index

                readonly property bool isSelected: windowGrid.currentIndex === index || mouseArea.containsMouse


                width: windowGrid.cellWidth - 15
                height: windowGrid.cellHeight - 15

                color: isSelected
                    ? Singletons.Colors.overviewCardHoverBackground 
                    : Singletons.Colors.overviewCardBackground
                radius: Singletons.Colors.menuBorderRadius
                border.color: isSelected
                    ? Singletons.Colors.overviewCardHoverBorder 
                    : Singletons.Colors.overviewCardBorder
                border.width: 1

                Behavior on border.color { ColorAnimation { duration: 120 } }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#000000"
                        radius: Singletons.Colors.menuBorderRadius
                        clip: true

                        ScreencopyView {
                            anchors.fill: parent
                            captureSource: card.modelData.wayland
                            live: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: card.modelData.title && card.modelData.title !== ""
                                ? card.modelData.title 
                                : (card.modelData.appId && card.modelData.appId !== "" ? card.modelData.appId : "No name")
                            color: Singletons.Colors.foreground
                            font.pixelSize: 12
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            id: wsText
                            width: content + 10
                            text: card.modelData?.workspace?.name ?? card.modelData?.workspace?.id ?? "—"
                            color: Singletons.Colors.wsFocusForeground
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        card.modelData.wayland.activate();
                        closeOverview();
                    }
                }
            }
        }
        
    }
}