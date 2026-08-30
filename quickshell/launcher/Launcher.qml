import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

import "../Singletons" as Singletons

PanelWindow {
    id: root

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
    property bool commandConfirmVisible: false
    property string pendingCommand: ""

    FileSearch {
        id: fileSearch

        onResultsReady: function(items) {
            router.setFileResults(items)
        }
    }

    CommandRunner {
        id: commandRunner

        onOutputReady: function(text) {
            router.appendCommandOutput(text)
        }

        onFinished: function(exitCode) {
            router.appendCommandOutput(
                "\n[exit code: " + exitCode + "]"
            )
        }
    }

    Router {
        id: router

        fileSearch: fileSearch
        commandRunner: commandRunner

        onResultsChanged: {
            root.selectedIndex = 0

            if (resultList.count > 0) {
                resultList.positionViewAtBeginning()
            }
        }
    }

    function open() {
        root.visible = true
        root.commandConfirmVisible = false
        root.pendingCommand = ""

        search.forceActiveFocus()
        search.selectAll()

        router.search(search.text)
    }

    function close() {
        root.commandConfirmVisible = false
        root.pendingCommand = ""

        commandRunner.stop()
        fileSearch.stop()

        root.visible = false

        root.closed()
    }

    function moveSelection(delta) {
        if (router.results.length === 0)
            return

        root.selectedIndex += delta

        if (root.selectedIndex < 0)
            root.selectedIndex = router.results.length - 1

        if (root.selectedIndex >= router.results.length)
            root.selectedIndex = 0

        resultList.positionViewAtIndex(
            root.selectedIndex,
            ListView.Contain
        )
    }

    function executeSelected() {
        if (router.results.length === 0)
            return

        var item = router.results[root.selectedIndex]

        if (!item)
            return

        if (item.type === "command") {
            root.pendingCommand = item.command
            root.commandConfirmVisible = true
            return
        }

        router.execute(item)
    }

    function executePendingCommand() {
        if (root.pendingCommand.length === 0)
            return

        root.commandConfirmVisible = false

        router.execute({
            type: "command",
            command: root.pendingCommand
        })

        root.pendingCommand = ""
    }

    // Rectangle {
    //     anchors.fill: parent

    //     color: "#000000"
    //     opacity: 0.45

    //     MouseArea {
    //         anchors.fill: parent
    //     }
    // }
    MouseArea {
        anchors.fill: parent
        onClicked: parent.close()
    }

    Rectangle {
        id: window

        width: Math.min(parent.width - 80, 760)
        height: Math.min(parent.height - 100, 600)

        anchors.centerIn: parent

        radius: 16

        color: "#18181b"

        border.width: 1
        border.color: "#3f3f46"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16

            spacing: 10

            TextField {
                id: search

                Layout.fillWidth: true
                Layout.preferredHeight: 52

                focus: true

                placeholderText:
                    "Search applications, files, commands..."

                font.pixelSize: 19

                color: "#fafafa"
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
                    root.close()
                }

                Keys.onUpPressed: {
                    root.moveSelection(-1)
                }

                Keys.onDownPressed: {
                    root.moveSelection(1)
                }

                Keys.onTabPressed: {
                    root.moveSelection(1)
                }

                Keys.onReturnPressed: {
                    root.executeSelected()
                }

                Keys.onEnterPressed: {
                    root.executeSelected()
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: router.modeText

                    color: "#a1a1aa"
                    font.pixelSize: 12

                    Layout.fillWidth: true
                }

                Text {
                    text: router.results.length + " results"

                    color: "#71717a"
                    font.pixelSize: 12
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                radius: 10

                color: "#111113"

                clip: true

                ListView {
                    id: resultList

                    anchors.fill: parent
                    anchors.margins: 6

                    clip: true

                    spacing: 3

                    model: router.results

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: resultList.width
                        height: 64

                        radius: 9

                        color:
                            index === root.selectedIndex
                            ? "#3f3f46"
                            : "transparent"

                        MouseArea {
                            anchors.fill: parent

                            hoverEnabled: true

                            onEntered: {
                                root.selectedIndex = index
                            }

                            onClicked: {
                                root.selectedIndex = index
                                root.executeSelected()
                            }
                        }

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

                                Text {
                                    anchors.centerIn: parent

                                    visible: modelData.type !== "app" || iconImage.source == ""

                                    text: {
                                        if (modelData.type === "calculator")
                                            return "="

                                        if (modelData.type === "command")
                                            return "$"

                                        if (modelData.type === "file")
                                            return "󰈔"

                                        return "󰀻"
                                    }

                                    color: "#e4e4e7"
                                    font.pixelSize: 19
                                }
                            }
                            

                            ColumnLayout {
                                Layout.fillWidth: true

                                spacing: 2

                                Text {
                                    Layout.fillWidth: true

                                    text: modelData.title || ""

                                    color: "#fafafa"

                                    font.pixelSize: 14
                                    font.bold: true

                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true

                                    text: modelData.description || ""

                                    color: "#a1a1aa"

                                    font.pixelSize: 12

                                    elide: Text.ElideRight
                                }
                            }

                            Text {
                                text: modelData.type || ""

                                color: "#71717a"

                                font.pixelSize: 10
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {}
                }

                Text {
                    anchors.centerIn: parent

                    visible: resultList.count === 0

                    text: "Nothing found"

                    color: "#52525b"

                    font.pixelSize: 16
                }
            }

            Rectangle {
                Layout.fillWidth: true

                Layout.preferredHeight:
                    router.commandOutput.length > 0
                    ? 110
                    : 0

                visible:
                    router.commandOutput.length > 0

                radius: 10

                color: "#09090b"

                clip: true

                Text {
                    anchors.fill: parent
                    anchors.margins: 10

                    text: router.commandOutput

                    color: "#d4d4d8"

                    font.family: "monospace"
                    font.pixelSize: 11

                    wrapMode: Text.WrapAnywhere

                    verticalAlignment: Text.AlignTop
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "↑↓ Navigate"

                    color: "#71717a"
                    font.pixelSize: 11
                }

                Text {
                    text: "Enter Run"

                    color: "#71717a"
                    font.pixelSize: 11
                }

                Text {
                    text: "Esc Close"

                    color: "#71717a"
                    font.pixelSize: 11
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "Quickshell 0.3.0"

                    color: "#52525b"
                    font.pixelSize: 11
                }
            }
        }
    }

    Rectangle {
        visible: root.commandConfirmVisible

        anchors.fill: window

        radius: 16

        color: "#18181b"

        border.width: 1
        border.color: "#52525b"

        ColumnLayout {
            anchors.centerIn: parent

            width: parent.width - 80

            spacing: 18

            Text {
                Layout.fillWidth: true

                text: "Execute command?"

                color: "#fafafa"

                font.pixelSize: 22
                font.bold: true

                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true

                Layout.preferredHeight: 100

                radius: 10

                color: "#09090b"

                Text {
                    anchors.fill: parent
                    anchors.margins: 14

                    text: "$ " + root.pendingCommand

                    color: "#d4d4d8"

                    font.family: "monospace"
                    font.pixelSize: 13

                    wrapMode: Text.WrapAnywhere

                    verticalAlignment: Text.AlignVCenter
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                spacing: 10

                Button {
                    text: "Cancel"

                    onClicked: {
                        root.commandConfirmVisible = false
                        root.pendingCommand = ""
                        search.forceActiveFocus()
                    }
                }

                Button {
                    text: "Execute"

                    onClicked: {
                        root.executePendingCommand()
                    }
                }
            }
        }

        Keys.onEscapePressed: {
            root.commandConfirmVisible = false
            root.pendingCommand = ""
            search.forceActiveFocus()
        }

        Keys.onReturnPressed: {
            root.executePendingCommand()
        }

        Keys.onEnterPressed: {
            root.executePendingCommand()
        }
    }
}