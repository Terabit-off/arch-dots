import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property int debounceMs: 180
    property int minHomeQueryLength: 2
    property int maxResults: 40
    property string homePath: Quickshell.env("HOME") || "."
    property var searchExcludes: [
        ".git",
        ".cache",
        "node_modules",
        ".npm",
        ".local/share/Trash"
    ]

    signal resultsReady(var items)

    Process {
        id: process

        stdout: StdioCollector {
            onStreamFinished: {
                var text = this.text || ""
                var lines = text.split("\n")
                var items = []

                for (var i = 0; i < lines.length && items.length < root.maxResults; i++) {
                    var path = lines[i].trim()

                    if (path.length === 0)
                        continue

                    var title = path
                    var slash = path.lastIndexOf("/")

                    if (slash >= 0 && slash + 1 < path.length)
                        title = path.substring(slash + 1)

                    items.push({
                        title: title,
                        description: path,
                        icon: root.isImage(path) ? "file://" + path : "󰈔",
                        type: "file",
                        path: path
                    })
                }

                root.resultsReady(items)
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                // fd errors are intentionally ignored; an empty result is enough for the UI.
            }
        }
    }

    Timer {
        id: debounce

        interval: root.debounceMs
        repeat: false
        property string pendingQuery: ""
        property bool pendingHomeSearch: false

        onTriggered: {
            if (pendingHomeSearch)
                root.runHomeSearch(pendingQuery)
            else
                root.runSearch(pendingQuery)
        }
    }

    function stop() {
        debounce.stop()
        process.running = false
    }

    function search(query) {
        debounce.pendingQuery = String(query || "")
        debounce.pendingHomeSearch = false
        debounce.restart()
    }

    function searchHome(query) {
        query = String(query || "").trim()

        if (query.length < root.minHomeQueryLength) {
            stop()
            root.resultsReady([])
            return
        }

        debounce.pendingQuery = query
        debounce.pendingHomeSearch = true
        debounce.restart()
    }

    function runSearch(request) {
        process.running = false
        request = String(request || "")

        var path = request

        if (path.startsWith("~"))
            path = root.homePath + path.substring(1)

        var directory = "."
        var pattern = path

        if (path.startsWith("/")) {
            var slash = path.lastIndexOf("/")

            if (slash > 0) {
                directory = path.substring(0, slash)
                pattern = path.substring(slash + 1)
            } else {
                directory = "/"
                pattern = ""
            }
        }

        if (path === root.homePath) {
            directory = root.homePath
            pattern = ""
        }

        process.command = root.buildCommand(pattern, directory)
        process.running = true
    }

    function runHomeSearch(query) {
        if (!query || query.length < root.minHomeQueryLength) {
            root.resultsReady([])
            return
        }

        process.command = root.buildCommand(query, root.homePath)
        process.running = true
    }

    function buildCommand(pattern, directory) {
        var command = [
            "fd",
            "--hidden",
            "--type", "f",
            "--type", "l",
            "--ignore-case",
            "--max-results", String(root.maxResults)
        ]

        for (var i = 0; i < root.searchExcludes.length; i++)
            command.push("--exclude", root.searchExcludes[i])

        if (pattern.length > 0)
            command.push(pattern)
        else
            command.push(".")

        command.push(directory)
        return command
    }

    function isImage(path) {
        var lower = String(path || "").toLowerCase()

        return lower.endsWith(".jpg") ||
            lower.endsWith(".jpeg") ||
            lower.endsWith(".png") ||
            lower.endsWith(".webp") ||
            lower.endsWith(".gif") ||
            lower.endsWith(".bmp") ||
            lower.endsWith(".svg") ||
            lower.endsWith(".avif")
    }
}
