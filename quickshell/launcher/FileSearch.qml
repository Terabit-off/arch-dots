import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    signal resultsReady(var items)

    Process {
        id: process

        stdout: StdioCollector {
            onStreamFinished: {
                var text = this.text

                var lines = text.split("\n")

                var items = []

                for (var i = 0; i < lines.length; i++) {
                    var path = lines[i].trim()

                    if (path.length === 0)
                        continue

                    var title = path

                    var slash = path.lastIndexOf("/")

                    if (slash >= 0)
                        title = path.substring(slash + 1)

                    items.push({
                        title: title,

                        description: path,

                        icon: isImage(path)
                            ? "file://" + path 
                            : "󰈔",

                        type: "file",

                        path: path
                    })
                }

                root.resultsReady(items)
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                // fd errors intentionally ignored
            }
        }
    }

    Timer {
        id: debounce

        interval: 180

        repeat: false

        property string pendingQuery: ""

        onTriggered: {
            root.runSearch(pendingQuery)
        }
    }

    function stop() {
        debounce.stop()
        process.running = false
    }

    function search(query) {
        debounce.pendingQuery = query
        debounce.restart()
    }

    function runSearch(query) {
        process.running = false

        var home =
            Quickshell.env("HOME") || ""

        var path = query

        if (path.startsWith("~")) {
            path =
                home +
                path.substring(1)
        }

        /*
         * Absolute path:
         *
         * /home/user/Documents/report
         *
         * becomes:
         *
         * directory = /home/user/Documents
         * pattern   = report
         */

        var directory = "."
        var pattern = path

        if (path.startsWith("/")) {
            var slash = path.lastIndexOf("/")

            if (slash > 0) {
                directory =
                    path.substring(0, slash)

                pattern =
                    path.substring(slash + 1)
            } else {
                directory = "/"
                pattern = ""
            }
        }

        /*
         * Search "~/foo" as:
         *
         * fd foo "$HOME"
         */

        if (path === home) {
            directory = home
            pattern = ""
        }

        var command = [
            "fd",
            "--hidden",
            "--exclude", ".git",
            "--type", "f",
            "--type", "l",
            "--max-results", "40"
        ]

        if (pattern.length > 0) {
            command.push(
                "--ignore-case"
            )

            command.push(pattern)
        } else {
            command.push(".")
        }

        command.push(directory)

        process.command = command

        process.running = true
    }

    function searchHome(query) {
        process.running = false

        var home = Quickshell.env("HOME") || "."

        process.command = [
            "fd",
            "--hidden",
            "--exclude", ".git",
            "--type", "f",
            "--type", "l",
            "--ignore-case",
            "--max-results", "40",
            query,
            home
        ]

        process.running = true
    }

    function isImage(path) {
        var lower = path.toLowerCase()

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