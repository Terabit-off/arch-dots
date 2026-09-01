import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io

import "../Singletons" as Singletons

PanelWindow {
    id: launcher

    visible: false

    WlrLayershell.namespace: "qs-blur"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "transparent"

    property int selectedIndex: 0

    UsageStats {
        id: usageStats

        onReady: {
            if (launcher.visible && search.text.trim() === "") {
                router.search("")
            }
        }
    }

    ClipboardHistory { 
        id: clipboardHistory

        onResultsReady: function(items) {
            router.setClipboardResults(items)
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            launcher.visible = !launcher.visible

            if (launcher.visible)
                launcher.open()
            else
                launcher.close()
        }

        function close(): void {
            launcher.close()
        }
    }

    FileSearch {
        id: fileSearch

        onResultsReady: function(items) {
            router.setFileResults(items)
        }
    }

    Router {
        id: router

        fileSearch: fileSearch
        usageStats: usageStats
        clipboardHistory: clipboardHistory

        onResultsChanged: {
            launcher.selectedIndex = 0

            if (resultList.count > 0) {
                resultList.positionViewAtBeginning()
            }
        }
    }

    function open() {
        launcher.visible = true

        search.forceActiveFocus()
        search.selectAll()
        search.text = ""

        usageStats.load()

        router.search(search.text)
        showAnim.start();
    }

    function close() {
        fileSearch.stop()

        showAnim.stop();
        hideAnim.start();
    }

    function moveSelection(delta) {
        if (router.results.length === 0)
            return

        launcher.selectedIndex += delta

        if (launcher.selectedIndex < 0)
            launcher.selectedIndex = router.results.length - 1

        if (launcher.selectedIndex >= router.results.length)
            launcher.selectedIndex = 0

        resultList.positionViewAtIndex(
            launcher.selectedIndex,
            ListView.Contain
        )
    }

    function executeSelected() {
        if (router.results.length === 0)
            return

        var item = router.results[launcher.selectedIndex]

        if (!item)
            return

        router.execute(item)
    }

    ParallelAnimation {
        id: showAnim
        NumberAnimation { target: window; property: "opacity"; to: 1; duration: 150; easing.type: Easing.OutCubic }
        NumberAnimation { target: slideTransform; property: "y"; to: 0; duration: 250; easing.type: Easing.OutCubic }
    }

    ParallelAnimation {
        id: hideAnim
        NumberAnimation { target: window; property: "opacity"; to: 0; duration: 150; easing.type: Easing.InCubic }
        NumberAnimation { target: slideTransform; property: "y"; to: 120; duration: 200; easing.type: Easing.InCubic }

        onFinished: {
            launcher.visible = false;
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: close()
    }

    Rectangle {
        id: window

        transform: Translate {
            id: slideTransform
            y: 120
        }

        width: 460
        height: Math.min(parent.height - 100, 600)

        anchors.centerIn: parent

        radius: Singletons.Colors.menuBorderRadius + 5

        color: Singletons.Colors.menuBackground

        border.width: 1
        border.color: Singletons.Colors.menuBorderColor

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: {
                top: 16
                left: 16
                right: 16
                //bottom: 6
            }

            spacing: 10

            TextField {
                id: search

                Layout.fillWidth: true
                Layout.preferredHeight: 42

                focus: true

                placeholderText: "Search applications, files, calculate..."

                font.pixelSize: 14

                color: Singletons.Colors.foreground
                placeholderTextColor: "#71717a"

                leftPadding: 16
                rightPadding: 16

                background: Rectangle {
                    radius: 10

                    color: "#27272a"

                    border.width: 1
                    border.color: "#3f3f46"
                }

                onTextChanged: {
                    router.search(text)
                }

                Keys.onEscapePressed: {
                    launcher.close()
                }

                Keys.onUpPressed: {
                    launcher.moveSelection(-1)
                }

                Keys.onDownPressed: {
                    launcher.moveSelection(1)
                }

                Keys.onTabPressed: {
                    launcher.moveSelection(1)
                }

                Keys.onReturnPressed: {
                    launcher.executeSelected()
                    launcher.close()
                }

                Keys.onEnterPressed: {
                    launcher.executeSelected()
                    launcher.close()
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: router.modeText

                    color: Singletons.Colors.foregroundDim
                    font.pixelSize: 12

                    Layout.fillWidth: true
                }

                Text {
                    text: router.results.length + " results"

                    color: Singletons.Colors.foregroundDim
                    font.pixelSize: 12
                }
            }

            // RESULTS
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                color: 'transparent'

                clip: true



                ListView {
                    id: resultList

                    anchors.fill: parent
                    //anchors.margins: 6

                    clip: true

                    spacing: 3

                    model: router.results

                    
                    // result card
                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: resultList.width
                        height: 64

                        radius: 9

                        color: index === launcher.selectedIndex
                            ? "#3f3f46"
                            : "transparent"

                        

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10

                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 42
                                Layout.preferredHeight: 42

                                radius: 8
                                color: "#27272a"

                                IconImage {
                                    id: iconImage
                                    anchors.centerIn: parent
                                    visible: source != ""

                                    width: 32
                                    height: 32

                                    source: {
                                        return modelData.type === "app" && Quickshell.hasThemeIcon(modelData.icon)
                                                ? Quickshell.iconPath(modelData.icon)
                                                : ""
                                    }
                                }
                                Image {
                                    id: fileImage
                                    anchors.centerIn: parent
                                    visible: source != ""

                                    width: 32
                                    height: 32

                                    source: {
                                        var lower = modelData.icon.toLowerCase()
                                        return modelData.type === "file" && lower.startsWith("file://")
                                                ? modelData.icon
                                                : ""
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent

                                    visible: (modelData.type !== "app" || iconImage.source == "") && !fileImage.visible

                                    text: {
                                        if (modelData.type === "calculator")
                                            return "="

                                        if (modelData.type === "file") 
                                            return "󰈔"

                                        if (modelData.type === "clipboard")
                                            return ""

                                        return "󰀻"
                                    }

                                    color: Singletons.Colors.foreground
                                    font.pixelSize: 24
                                }
                            }                

                            ColumnLayout {
                                Layout.fillWidth: true

                                spacing: 2

                                Text {
                                    Layout.fillWidth: true

                                    text: modelData.title || ""

                                    color: Singletons.Colors.foreground

                                    font.pixelSize: 14
                                    font.bold: true

                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true

                                    text: modelData.description || ""

                                    color: Singletons.Colors.foregroundDim

                                    font.pixelSize: 12

                                    elide: Text.ElideRight
                                }
                            }

                            Text {
                                text: modelData.type || ""

                                color: Singletons.Colors.foregroundDim

                                font.pixelSize: 10
                            }
                        }
                        MouseArea {
                            anchors.fill: parent

                            hoverEnabled: true

                            onClicked: {
                                launcher.selectedIndex = index
                                launcher.executeSelected()
                                launcher.close()
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {}
                }

                Text {
                    anchors.centerIn: parent

                    visible: resultList.count === 0

                    text: "Nothing found"

                    color: Singletons.Colors.foregroundDim

                    font.pixelSize: 16
                }
            }
        }
    }
}