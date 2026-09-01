import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var data: ({})

    property real totalWeight: 10.0

    property string filePath: (Quickshell.env("HOME") || "") +
        "/.config/quickshell/launcher/usage.json"

    signal changed()
    signal ready()

    FileView {
        id: usageFile

        path: root.filePath

        onLoadedChanged: {
            if (loaded)
                root.load()
        }
    }

    function load() {
        var text = usageFile.text()

        if (!text || text.trim() === "") {
            root.data = ({})
            root.save()
            root.ready()
            return
        }

        try {
            var json = JSON.parse(text)

            if (typeof json !== "object" || Array.isArray(json)) {
                root.data = ({})
                root.ready()
                return
            }

            var restored = {}

            for (var id in json) {
                var launches = Number(json[id])

                if (isFinite(launches) && launches > 0)
                    restored[id] = Math.floor(launches)
            }

            root.data = restored
        } catch (error) {
            console.log(
                "Failed to parse launcher usage.json:",
                error
            )

            root.data = ({})
        }

        root.ready()
    }

    function save() {
        usageFile.setText(
            JSON.stringify(root.data, null, 4)
        )
    }

    function launches(id) {
        if (!id)
            return 0

        return Number(root.data[id] || 0)
    }

    function totalLaunches() {
        var total = 0

        for (var id in root.data)
            total += launches(id)

        return total
    }

    function weight(id) {
        var total = totalLaunches()

        if (total <= 0)
            return 0

        return totalWeight * launches(id) / total
    }

    function record(id) {
        if (!id)
            return

        var updated = Object.assign({}, root.data)

        updated[id] = launches(id) + 1

        root.data = updated
        root.save()
        root.changed()
    }

    function clear() {
        root.data = ({})
        root.save()
        root.changed()
    }
}