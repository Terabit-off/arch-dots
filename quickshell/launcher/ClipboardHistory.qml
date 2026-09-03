import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    signal resultsReady(var items)

    Process {
        id: listProcess

        command: ["cliphist", "list"]

        stdout: StdioCollector {
            id: output

            onStreamFinished: {
                root.parseResults(text)
            }
        }
    }

    Process {
        id: copyProcess

        property string selectedValue: "" 

        command: [
            "sh",
            "-c",
            "wl-copy \"$1\" && notify-send --urgency=low \"Copied: '$1'\" 'Clipboard'",
            "clipboard-helper",
            selectedValue
        ]
    }

    function search() {
        listProcess.running = true 
    }

    function parseResults(text) {
        var items = []
        var lines = String(text || "").split("\n")

        for (var i = 0; i < lines.length && items.length < 40; i++) {
            var line = lines[i].trim()
            let parts = line.split("\t");

            if (line.length === 0)
                continue

            items.push({
                title: preview(parts[1]),
                description: parts[0],
                icon: "",
                type: "clipboard",
                value: line
            })
        }

        root.resultsReady(items)
    }

    function preview(value) {
        var text = String(value)
            .replace(/^[0-9]+\\s+/, "")
            .replace(/\t/g, " ")
            .replace(/\n/g, " ")

        if (text.length > 100)
            text = text.substring(0, 100) + "…"

        return text
    }

    function copy(item) {
        if (!item || item.type !== "clipboard")
            return

        copyProcess.selectedValue = item.title
        copyProcess.running = true
    }
}