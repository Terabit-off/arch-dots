import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // list of apps
    property var data: []

    property string filePath: (Quickshell.env("HOME") || "")
                              + "/.config/quickshell/launcher/usage.json"

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
            root.data = []
            root.save()
            root.ready()
            return
        }

        try {
            var json = JSON.parse(text)

            if (Array.isArray(json)) {
                var restored = []
                var seen = {}

                for (var i = 0; i < json.length; i++) {
                    var id = String(json[i] || "").trim()

                    if (id && !seen[id]) {
                        restored.push(id)
                        seen[id] = true
                    }
                }

                root.data = restored
                root.ready()
                return
            }

            root.data = []
            root.save()
            root.ready()
        } catch (error) {
            console.log("Failed to parse launcher usage.json:", error)

            root.data = []
            root.ready()
        }
    }

    function save() {
        usageFile.setText(JSON.stringify(root.data, null, 4))
    }

    // 0 - last started app, -1 - no app.
    function indexOf(id) {
        if (!id)
            return -1

        return root.data.indexOf(id)
    }

    function record(id) {
        id = String(id || "").trim()

        if (!id)
            return

        // Создаём новый список, не изменяя root.data напрямую.
        var updated = []

        // Сначала ставим только что запущенное приложение.
        updated.push(id)

        // Затем добавляем все остальные, кроме него самого.
        // Благодаря этому существующий ID переместится на первую строку.
        for (var i = 0; i < root.data.length; i++) {
            if (root.data[i] !== id)
                updated.push(root.data[i])
        }

        root.data = updated
        root.save()
        root.changed()
    }

    function clear() {
        root.data = []
        root.save()
        root.changed()
    }
}