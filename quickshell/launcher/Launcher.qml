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

            if (router.results.length > 0)
                resultList.positionViewAtBeginning()
        }
    }



    function open() {
        launcher.visible = true

        search.forceActiveFocus()
        search.selectAll()
        search.text = ""

        router.search(search.text)
        showAnim.restart();
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

        if (!item || !router.isSelectable(item))
            return
        

        router.execute(item)
    }

    ParallelAnimation {
        id: showAnim
        PropertyAnimation {
            target: window
            property: "opacity"
            from: 0
            to: 1
            duration: 260
            easing.type: Easing.OutCubic
        }
        PropertyAnimation {
            target: window
            property: "y"
            from: -100
            to: 0
            duration: 260
            easing.type: Easing.OutBack
        }

        PropertyAnimation {
            target: window
            property: "scale"
            from: 0.85
            to: 1
            duration: 280
            easing.type: Easing.OutSine
        }
    }

    ParallelAnimation {
        id: hideAnim
        PropertyAnimation {
            target: window
            property: "opacity"
            from: 1
            to: 0
            duration: 260
            easing.type: Easing.InCubic
        }
        PropertyAnimation {
            target: window
            property: "y"
            from: 0
            to: -100
            duration: 260
            easing.type: Easing.InBack
        }

        PropertyAnimation {
            target: window
            property: "scale"
            from: 1
            to: 0.85
            duration: 280
            easing.type: Easing.InSine
        }
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

        width: 460
        height: Math.min(parent.height - 100, 600)

        //anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

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
                        height: modelData.type != "separator" ? 64 : 1

                        radius: 9

                        color: modelData.type != "separator" ? index === launcher.selectedIndex
                            ? "#3f3f46"
                            : "transparent" : '#5b5b62'

                        RowLayout {
                            visible: modelData.type != "separator"
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

                                        var iconName = String(modelData.icon || "")
                                        var usable = modelData.type === "app" || modelData.type === "folder" || modelData.type === "window"
                                        return usable && Quickshell.hasThemeIcon(iconName)
                                            ? Quickshell.iconPath(iconName)
                                            : ""
                                    }
                                }

                                Image {
                                    id: fileImage
                                    anchors.centerIn: parent
                                    visible: source != ""

                                    width: 32
                                    height: 32
                                    fillMode: Image.PreserveAspectFit

                                    source: {
                                        var iconValue = String(modelData.icon || "")

                                        return modelData.type === "file" && iconValue.startsWith("file://")
                                            ? iconValue
                                            : ""
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent

                                    visible: !iconImage.visible && !fileImage.visible

                                    text: {
                                        if (modelData.type === "calculator")
                                            return "="

                                        if (modelData.type === "folder")
                                            return "󰉋"

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
                                text: modelData.type === "folder" ? "folder"
                                    : modelData.type === "file" ? "file"
                                    : (modelData.type || "")

                                color: Singletons.Colors.foregroundDim

                                font.pixelSize: 10
                            }
                        }
                        MouseArea {
                            visible: modelData.type != "separator"
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