import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

import "../../Singletons" as Singletons

Item {
    id: root
    property bool active: false
    property int maxItems: 100

    property var clipboardItems: []

    signal itemSelected(string id)

    
    onActiveChanged: {
        if (active)
            refresh()
    }

    Component.onCompleted: {
        if (active)
            refresh()
    }

    
    // HELPERS
    function shellQuote(value) {
        return "'" +
               String(value).replace(/'/g, "'\\''") +
               "'"
    }

    function prettyPreview(value) {
        if (!value)
            return ""

        return String(value)
            .replace(/\n/g, " ")
            .replace(/\t/g, " ")
            .trim()
    }

    function isBinary(preview) {
        return String(preview).includes(
            "[[ binary data"
        )
    }

    function isImageMime(mime) {
        return String(mime)
            .trim()
            .startsWith("image/")
    }

    function mimeIcon(mime) {
        mime = String(mime)

        if (mime.startsWith("image/"))
            return "󰋩"

        if (mime.startsWith("video/"))
            return "󰕧"

        if (mime.startsWith("audio/"))
            return "󰎆"

        if (mime === "application/pdf")
            return "󰈦"

        if (
            mime.includes("zip") ||
            mime.includes("compressed") ||
            mime.includes("archive")
        )
            return "󰗀"

        return "󰈙"
    }

    function refresh() {
        if (!listProcess.running)
            listProcess.running = true
    }

    
    // CLIPHIST LIST
    Process {
        id: listProcess

        command: [
            "sh",
            "-c",
            "cliphist list | head -n " +
            root.maxItems
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseHistory(text)
            }
        }

        onExited: function(exitCode) {
            if (exitCode !== 0)
                root.clipboardItems = []
        }
    }

    
    // PARSE HISTORY
    function parseHistory(data) {
        const lines = data.split("\n")
        const result = []

        for (const line of lines) {
            if (!line.trim())
                continue

            const separator = line.indexOf("\t")

            if (separator < 0)
                continue

            const id =
                line.substring(0, separator)

            const preview =
                line.substring(separator + 1)

            result.push({
                id: id,
                preview: preview,

                binary:
                    root.isBinary(preview),

                mime: "",

                isImage: false,

                previewPath: ""
            })
        }

        clipboardItems = result

        /*
            После получения списка начинаем
            определять MIME бинарных записей.
        */
        mimeQueue = []

        for (const item of result) {
            if (item.binary)
                mimeQueue.push(item)
        }

        detectNextBinary()
    }

    // BINARY MIME QUEUE
    property var mimeQueue: []

    function detectNextBinary() {
        if (mimeQueue.length === 0)
            return

        if (mimeProcess.running)
            return

        const item = mimeQueue.shift()

        if (!item)
            return

        const path =
            "/tmp/quickshell-clipboard-" +
            sanitizeFileName(item.id) +
            ".bin"

        item.previewPath = path

        mimeProcess.currentItemId = item.id
        mimeProcess.currentPath = path

        mimeProcess.command = [
            "sh",
            "-c",
            "cliphist decode " +
            root.shellQuote(item.id) +
            " > " +
            root.shellQuote(path) +
            " && file --mime-type -b " +
            root.shellQuote(path)
        ]

        mimeProcess.running = true
    }

    function sanitizeFileName(value) {
        return String(value)
            .replace(/[^a-zA-Z0-9_.-]/g, "_")
    }

    Process {
        id: mimeProcess

        property string currentItemId: ""
        property string currentPath: ""

        command: []

        stdout: StdioCollector {
            onStreamFinished: {
                const mime =
                    text.trim()

                for (
                    let i = 0;
                    i < root.clipboardItems.length;
                    ++i
                ) {
                    const item =
                        root.clipboardItems[i]

                    if (
                        item.id !==
                        mimeProcess.currentItemId
                    )
                        continue

                    item.mime = mime

                    item.isImage =
                        root.isImageMime(mime)

                    /*
                        Если это изображение —
                        сохраняем путь к preview.
                    */
                    item.previewPath =
                        mimeProcess.currentPath

                    /*
                        Обновляем model,
                        чтобы delegate увидел
                        новые свойства.
                    */
                    root.clipboardItems =
                        root.clipboardItems.slice()

                    break
                }
            }
        }

        onExited: {
            /*
                Даже если file не смог определить MIME,
                продолжаем очередь.
            */
            root.detectNextBinary()
        }
    }

    // RESTORE CLIPBOARD
    function restore(id) {
        if (!id)
            return

        restoreProcess.command = [
            "sh",
            "-c",
            "cliphist decode " +
            root.shellQuote(id) +
            " | wl-copy"
        ]

        restoreProcess.running = true
    }

    Process {
        id: restoreProcess

        command: []
    }

    // DELETE
    function removeItem(id) {
        if (!id)
            return

        deleteProcess.command = [
            "sh",
            "-c",
            "printf '%s\\n' " +
            root.shellQuote(id) +
            " | cliphist delete"
        ]

        deleteProcess.running = true

        refreshTimer.restart()
    }

    Process {
        id: deleteProcess

        command: []
    }

    // CLEAR
    function clearHistory() {
        clearProcess.running = true

        clipboardItems = []
        mimeQueue = []
    }

    Process {
        id: clearProcess

        command: [
            "cliphist",
            "wipe"
        ]

        onExited: {
            root.refresh()
        }
    }

    // REFRESH TIMER
    Timer {
        id: refreshTimer

        interval: 150

        repeat: false

        onTriggered: {
            root.refresh()
        }
    }

    // UI
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        
        // HEADER
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Clipboard"
                color: Singletons.Colors.foreground
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                font.weight: Font.DemiBold
            }

            Text {
                text: root.clipboardItems.length + " items"
                color: Singletons.Colors.foreground
                opacity: 0.5
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
            }

            Item {
                Layout.fillWidth: true
            }

            // REFRESH
            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 20

                radius: 8
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰑐"
                    
                    color: refreshMouse.containsMouse
                           ? "#ffffff"
                           : Singletons.Colors.foreground
                    opacity: refreshMouse.containsMouse ? 1.0 : 0.6

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14

                    rotation: refreshMouse.containsMouse ? 180 : 0

                    Behavior on rotation {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                MouseArea {
                    id: refreshMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.refresh()
                    }
                }
            }

            // CLEAR
            Rectangle {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 20

                radius: 8
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "Clear"

                    color: clearMouse.containsMouse
                           ? "#ffffff"
                           : Singletons.Colors.foreground
                    opacity: clearMouse.containsMouse ? 1.0 : 0.6

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: root.clipboardItems.length > 0

                    onClicked: {
                        root.clearHistory()
                    }
                }
            }
        }

        
        // SEPARATOR
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Singletons.Colors.foreground
            opacity: 0.1
        }

        
        // GRID
        GridView {
            id: clipboardGrid

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            cellWidth: 150
            cellHeight: 125

            model: root.clipboardItems

            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                active: true
            }

            delegate: Item {
                id: delegateRoot

                required property var modelData
                required property int index

                width: clipboardGrid.cellWidth - 6
                height: clipboardGrid.cellHeight - 6

                property string itemId: modelData.id
                property string preview: modelData.preview
                property bool binary: modelData.binary
                property string mime: modelData.mime || ""
                property bool image: modelData.isImage === true
                property string previewPath: modelData.previewPath || ""

                // CARD
                Rectangle {
                    id: card

                    anchors.fill: parent
                    radius: 8
                    
                    color: "#302f2f2f"
                    border.width: 1
                    border.color: cardMouse.containsMouse 
                                  ? Singletons.Colors.foreground 
                                  : "transparent"

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }

                    // =
                    // IMAGE
                    // =

                    Rectangle {
                        id: imageContainer

                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 6
                        }

                        height: 72
                        radius: 6
                        color: "transparent"
                        visible: delegateRoot.image

                        Image {
                            id: imagePreview

                            anchors.fill: parent
                            source: delegateRoot.image && delegateRoot.previewPath !== ""
                                    ? "file://" + delegateRoot.previewPath
                                    : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                            visible: false
                        }

                        Rectangle {
                            id: imageMask
                            anchors.fill: parent
                            radius: imageContainer.radius
                            color: "white"
                            visible: false
                        }

                        OpacityMask {
                            id: roundedCover
                            anchors.fill: imageContainer
                            source: imagePreview
                            maskSource: imageMask
                            visible: imagePreview.status === Image.Ready
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: imagePreview.status !== Image.Ready
                            text: "󰋩"
                            color: Singletons.Colors.foreground
                            opacity: 0.5
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 24
                        }
                    }

                    // =
                    // NON IMAGE
                    // =

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 6
                        }

                        height: 72
                        radius: 6
                        color: "transparent"
                        visible: !delegateRoot.image

                        Text {
                            anchors.centerIn: parent

                            text: {
                                if (delegateRoot.mime !== "") {
                                    return root.mimeIcon(delegateRoot.mime)
                                }
                                if (delegateRoot.binary) {
                                    return "󰈙"
                                }
                                if (delegateRoot.preview.startsWith("file://")) {
                                    return "󰉋"
                                }
                                if (delegateRoot.preview.match(/^https?:\/\//)) {
                                    return "󰌷"
                                }
                                return "󰅍"
                            }

                            color: Singletons.Colors.foreground
                            opacity: 0.6
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 25
                        }
                    }

                    // =
                    // TEXT / MIME
                    // =

                    Text {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                            margins: 8
                        }

                        height: 34

                        text: delegateRoot.binary
                              ? (delegateRoot.mime !== "" ? delegateRoot.mime : "Binary data")
                              : root.prettyPreview(delegateRoot.preview)

                        color: Singletons.Colors.foreground
                        opacity: 0.8
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 9
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    // =
                    // DELETE
                    // =

                    Rectangle {
                        id: deleteButton

                        anchors {
                            right: parent.right
                            top: parent.top
                            margins: 5
                        }

                        width: 25
                        height: 25
                        radius: 6

                        opacity: cardMouse.containsMouse ? 1 : 0
                        color: deleteMouse.containsMouse ? "#a54242" : "#451b1b20"

                        Behavior on opacity {
                            NumberAnimation { duration: 100 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: "#ffffff"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: deleteMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                root.removeItem(delegateRoot.itemId)
                            }
                        }
                    }

                    // =
                    // CLICK
                    // =

                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.restore(delegateRoot.itemId)
                            root.itemSelected(delegateRoot.itemId)
                        }
                    }
                }
            }

            
            // EMPTY
            

            Column {
                anchors.centerIn: parent
                spacing: 8
                visible: root.clipboardItems.length === 0

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰅍"
                    color: Singletons.Colors.foreground
                    opacity: 0.3
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 34
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Clipboard is empty"
                    color: Singletons.Colors.foreground
                    opacity: 0.5
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                }
            }
        }
    }
}