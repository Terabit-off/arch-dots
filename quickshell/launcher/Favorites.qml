import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var data: ({})

    property string filePath:
        (Quickshell.env("HOME") || "") +
        "/.config/quickshell/launcher/favorites.json"

    signal changed()

    FileView {
        id: favoritesFile

        path: root.filePath

        onLoadedChanged: {
            if (loaded)
                root.load()
        }
    }

    function load() {
        var text = favoritesFile.text()

        if (!text || text.trim() === "") {
            root.data = ({})
            root.save()
            return
        }

        try {
            var json = JSON.parse(text)

            if (typeof json !== "object" ||
                Array.isArray(json)) {
                root.data = ({})
                return
            }

            var restored = {}

            for (var id in json) {
                var saved = json[id]

                var desktopEntry = findEntry(id)

                if (!desktopEntry)
                    continue

                restored[id] = {
                    id: desktopEntry.id,
                    icon: desktopEntry.icon,
                    entry: desktopEntry
                }
            }

            root.data = restored

        } catch (error) {
            console.log(
                "Failed to parse favorites.json:",
                error
            )

            root.data = ({})
        }
    }

    function findEntry(id) {
        var entries = DesktopEntries.applications.values

        for (var i = 0; i < entries.length; ++i) {
            var entry = entries[i]

            if (entry.id === id)
                return entry
        }

        return null
    }

    function save() {
        var json = {}

        for (var id in root.data) {
            var item = root.data[id]

            json[id] = {
                id: item.id,
                icon: item.icon
            }
        }

        favoritesFile.setText(
            JSON.stringify(json, null, 4)
        )
    }

    function add(entry) {
        if (!entry || !entry.id)
            return

        var id = entry.id

        root.data[id] = {
            id: entry.id,
            icon: entry.icon || "",
            entry: entry
        }

        root.data = Object.assign({}, root.data)

        root.save()
        root.changed()
    }

    function remove(id) {
        if (!root.data[id])
            return

        var copy = Object.assign({}, root.data)

        delete copy[id]

        root.data = copy

        root.save()
        root.changed()
    }

    function contains(id) {
        return root.data[id] !== undefined
    }

    function toggle(entry) {
        if (!entry || !entry.id)
            return

        if (contains(entry.id))
            remove(entry.id)
        else
            add(entry)
    }
}