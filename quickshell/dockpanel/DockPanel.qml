import "."
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import "../Singletons" as Singletons

PanelWindow {
    id: root

    property real hoverTimeout: 800
    property bool panelHovered: false
    property bool popupHovered: false
    property var iconPathCache: ({})
    property int iconRevision: 0
    readonly property var currentWorkspace: Hyprland.focusedWorkspace
    readonly property bool hasFullscreen: currentWorkspace ? currentWorkspace.hasFullscreen : false
    readonly property bool isFloating: {
        if (!currentWorkspace)
            return false;

        let hasWindows = false;
        for (const window of Hyprland.toplevels.values) {
            if (!window.workspace || window.workspace.id !== currentWorkspace.id)
                continue;

            hasWindows = true;
            const ipc = window.lastIpcObject;
            if (!ipc)
                continue;

            if (!Boolean(ipc.floating))
                return false;

        }
        return hasWindows;
    }
    readonly property bool hasCurrentWorkspaceWindows: {
        if (!currentWorkspace)
            return false;

        const windows = Hyprland.toplevels.values;
        for (const window of windows) {
            if (window.workspace && window.workspace.id === currentWorkspace.id)
                return true;

        }
        return false;
    }

    function windowWorkspaceId(window) {
        if (!window)
            return undefined

        if (window.workspace)
            return window.workspace.id

        var ipc = window.lastIpcObject
        return ipc && ipc.workspace ? ipc.workspace.id : undefined
    }

    function iconForWindow(window) {
        // Read the revision so this binding can be retriggered after
        // DesktopEntries has finished loading/resolving icons.
        void iconRevision

        var ipc = window ? window.lastIpcObject : null
        var className = ipc && ipc.class ? String(ipc.class) : "__unknown__"
        var fallback = Qt.resolvedUrl("icon-placeholder.png")

        if (!ipc)
            return fallback

        // Cache only successful resolutions. A temporary lookup failure must
        // not permanently turn an application icon into the placeholder.
        if (iconPathCache[className])
            return iconPathCache[className]

        var entry = DesktopEntries.heuristicLookup(className)
        if (!entry || !entry.icon)
            return fallback

        if (!Quickshell.hasThemeIcon(entry.icon))
            return fallback

        var path = Quickshell.iconPath(entry.icon)
        if (!path)
            return fallback

        iconPathCache[className] = path
        return path
    }

    function scheduleRefresh() {
        refreshTimer.restart()
    }

    function updatePopup(overrideFloating) {
        if (hasFullscreen) {
            closeTimer.stop();
            popup.popupShown = false;
            return ;
        }
        const currentFloatingState = (overrideFloating !== undefined) ? overrideFloating : isFloating;
        if (currentFloatingState) {
            closeTimer.stop();
            popup.popupShown = true;
        } else {
            if (panelHovered || popupHovered) {
                closeTimer.stop();
                popup.popupShown = true;
            } else {
                popup.popupShown = false;
            }
        }
    }

    function updateHover() {
        updatePopup(undefined);
    }

    function onRawEvent(event) {
        switch (event.name) {
        case "changefloatingmode":
            {
                const args = event.parse(2);
                if (args.length < 2)
                    return ;

                const isWindowFloating = Number(args[1]) === 1;
                root.updatePopup(isWindowFloating);
                break;
            };
        default:
            scheduleRefresh();
            break;
        }
    }

    function focusWindow(window) {
        if (!window)
            return ;

        window.wayland.activate();
    }

    anchors.bottom: true
    implicitHeight: 4
    implicitWidth: 180
    WlrLayershell.namespace: "qs-blur"
    WlrLayershell.layer: WlrLayer.Top
    color: "transparent"
    Component.onCompleted: {
        Hyprland.refreshToplevels();
        Hyprland.refreshWorkspaces();
        Hyprland.rawEvent.connect(onRawEvent);
        scheduleRefresh();
    }

    Process {
        id: openLauncherCommand

        command: ["qs", "ipc", "call", "launcher", "toggle"]
    }

    Rectangle {
        id: anchItem

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: panelHovered ? 150 : 90
        height: panelHovered ? 4 : 3
        radius: height / 2
        color: panelHovered ? Singletons.Colors.dockAccent : Singletons.Colors.dockAccentDim

        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 20
            height: parent.height + 6
            radius: height / 2
            color: parent.color
            opacity: panelHovered ? 0.18 : 0
            scale: panelHovered ? 1 : 0.75

            Behavior on opacity {
                NumberAnimation {
                    duration: 220
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutBack
                }

            }

        }

        Behavior on width {
            NumberAnimation {
                duration: 280
                easing.type: Easing.OutCubic
            }

        }

        Behavior on height {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }

        }

        Behavior on color {
            ColorAnimation {
                duration: 180
            }

        }

    }

    HoverHandler {
        onHoveredChanged: {
            root.panelHovered = hovered;
            if (hovered) {
                closeTimer.stop();
                if (!root.hasFullscreen)
                    popup.popupShown = true;

            } else {
                if (!root.isFloating)
                    closeTimer.restart();

            }
        }
    }

    PopupWindow {
        id: popup

        property bool popupShown: false

        anchor.window: root
        anchor.rect.x: root.width / 2 - width / 2
        anchor.rect.y: -height - 20
        implicitWidth: popupContent.implicitWidth + 32
        implicitHeight: popupContent.implicitHeight + 32
        color: "transparent"
        grabFocus: false
        visible: popupBackground.opacity > 0

        HoverHandler {
            onHoveredChanged: {
                root.popupHovered = hovered;
                if (hovered) {
                    closeTimer.stop();
                } else {
                    if (!root.isFloating)
                        closeTimer.restart();

                }
            }
        }

        Rectangle {
            id: popupBackground

            anchors.fill: parent
            radius: 18
            color: Singletons.Colors.dockPopupBackground
            border.width: 1
            border.color: Singletons.Colors.borderSubtle
            opacity: popup.popupShown ? 1 : 0
            scale: popup.popupShown ? 1 : 0.82
            y: popup.popupShown ? 0 : 12

            RowLayout {
                id: popupContent

                anchors.centerIn: parent
                spacing: 10

                // windows
                Repeater {
                    model: Hyprland.toplevels

                    delegate: Item {
                        id: windowItem

                        required property var modelData
                        property bool hovered: false
                        readonly property bool isCurrentWorkspace: {
                            if (!root.currentWorkspace || !modelData)
                                return false;

                            return root.windowWorkspaceId(modelData) === root.currentWorkspace.id;
                        }

                        implicitWidth: 56
                        implicitHeight: 56
                        opacity: popup.popupShown ? 1 : 0
                        scale: popup.popupShown ? (hovered ? 1.16 : 1) : 0.4
                        y: popup.popupShown ? 0 : 15

                        Rectangle {
                            id: iconBackground

                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            width: 44
                            height: 44
                            radius: 13
                            // Более яркий фон для текущего стола
                            color: windowItem.hovered ? Singletons.Colors.dockWindowHoverBackground : (windowItem.isCurrentWorkspace ? Singletons.Colors.dockWindowCurrentBackground : Singletons.Colors.dockWindowBackground)
                            // Более заметная граница
                            border.width: 1
                            border.color: windowItem.hovered ? Singletons.Colors.dockWindowHoverBorder : (windowItem.isCurrentWorkspace ? Singletons.Colors.dockWindowCurrentBorder : Singletons.Colors.dockWindowBorder)
                            scale: windowItem.hovered ? 1.05 : 1

                            Image {
                                id: appIcon

                                anchors.centerIn: parent
                                width: 27
                                height: 27
                                asynchronous: true
                                fillMode: Image.PreserveAspectFit
                                source: root.iconForWindow(windowItem.modelData)
                                opacity: status === Image.Ready ? 1 : 0
                                scale: status === Image.Ready ? 1 : 0.65

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 180
                                    }

                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 250
                                        easing.type: Easing.OutBack
                                    }

                                }

                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 220
                                    easing.type: Easing.OutBack
                                }

                            }

                        }

                        // Active window indicator
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            width: windowItem.modelData.activated ? 22 : 6
                            height: 3
                            radius: 2
                            color: Singletons.Colors.foreground
                            opacity: windowItem.modelData.activated ? 0.9 : 0.25

                            Behavior on width {
                                NumberAnimation {
                                    duration: 260
                                    easing.type: Easing.OutBack
                                }

                            }

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 180
                                }

                            }

                        }

                        HoverHandler {
                            onHoveredChanged: {
                                windowItem.hovered = hovered;
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.focusWindow(windowItem.modelData);
                            }
                        }

                        ToolTip {
                            visible: hovered
                            delay: 700

                            enter: Transition {
                                NumberAnimation {
                                    property: "opacity"
                                    from: 0
                                    to: 1
                                    duration: 180
                                    easing.type: Easing.OutCubic
                                }

                                NumberAnimation {
                                    property: "scale"
                                    from: 0.85
                                    to: 1
                                    duration: 200
                                    easing.type: Easing.OutBack // Лёгкий "пружинящий" эффект
                                }

                            }

                            exit: Transition {
                                NumberAnimation {
                                    property: "opacity"
                                    from: 1
                                    to: 0
                                    duration: 120
                                    easing.type: Easing.InCubic
                                }

                                NumberAnimation {
                                    property: "scale"
                                    from: 1
                                    to: 0.9
                                    duration: 120
                                    easing.type: Easing.InCubic
                                }

                            }

                            contentItem: Row {
                                spacing: 5

                                Text {
                                    text: {
                                        var ipc = windowItem.modelData.lastIpcObject;
                                        var wayland = windowItem.modelData.wayland;
                                        var title = (wayland && wayland.title) || (ipc && ipc.title) || (ipc && ipc.class) || "Window";
                                        return title.length > 35 ? title.substring(0, 32) + "..." : title;
                                    }
                                    color: Singletons.Colors.foreground
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Separator
                                Rectangle {
                                    width: 1
                                    height: 12
                                    color: "#44ffffff"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // WS number
                                Text {
                                    text: {
                                        var ws = root.windowWorkspaceId(windowItem.modelData);
                                        return "WS " + (ws !== undefined ? ws : "?");
                                    }
                                    color: "#b0ffffff"
                                    font.pixelSize: 11
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                            }

                            background: Rectangle {
                                color: '#d1101010'
                                border.width: 1
                                border.color: Singletons.Colors.borderSubtle
                                radius: 8
                            }

                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 220
                                easing.type: Easing.OutCubic
                            }

                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 260
                                easing.type: Easing.OutBack
                            }

                        }

                        Behavior on y {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutBack
                            }

                        }

                    }

                }

                // separator
                Rectangle {
                    height: 56
                    width: 1
                    color: Singletons.Colors.dockSeparator
                }

                // launcher button
                MouseArea {
                    width: 56
                    height: 56
                    opacity: popup.popupShown ? 1 : 0
                    scale: popup.popupShown ? (containsMouse ? 1.16 : 1) : 0.4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    y: 15
                    onClicked: {
                        openLauncherCommand.running = true;
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        width: 44
                        height: 44
                        radius: 13
                        color: parent.containsMouse ? Singletons.Colors.dockWindowHoverBackground : Singletons.Colors.dockWindowBackground
                        border.width: 1
                        border.color: parent.containsMouse ? Singletons.Colors.dockWindowHoverBorder : Singletons.Colors.dockWindowBorder
                        scale: parent.containsMouse ? 1.05 : 1

                        Text {
                            anchors.centerIn: parent
                            text: "󰀻"
                            font.pixelSize: 24
                            color: Singletons.Colors.foreground
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        width: 6
                        height: 3
                        radius: 2
                        color: Singletons.Colors.foreground
                        opacity: 0.25
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.OutBack
                        }

                    }

                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 240
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 330
                    easing.type: Easing.OutBack
                }

            }

            Behavior on y {
                NumberAnimation {
                    duration: 280
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

    Timer {
        id: refreshTimer

        interval: 0
        repeat: false

        onTriggered: {
            Hyprland.refreshToplevels();
            Hyprland.refreshWorkspaces();
            root.updatePopup(undefined);
        }
    }

    Timer {
        id: iconRetryTimer

        interval: 350
        repeat: true
        running: popup.popupShown

        onTriggered: {
            // Re-evaluate icon bindings while the popup is visible. This is
            // only needed briefly after startup or when a new app appears.
            root.iconRevision++
        }
    }

    Timer {
        id: closeTimer

        interval: hoverTimeout
        repeat: false
        onTriggered: {
            if (!root.panelHovered && !root.popupHovered && !root.isFloating && !root.hasFullscreen)
                popup.popupShown = false;

        }
    }

}
