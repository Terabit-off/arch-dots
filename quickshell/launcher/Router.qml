import QtQuick
import Quickshell

QtObject {
    id: root

    property QtObject fileSearch
    property QtObject commandRunner

    property var results: []

    property string modeText: "Applications"

    property string commandOutput: ""

    function normalize(text) {
        return String(text).toLowerCase().trim()
    }
    

    function fuzzyScore(query, text) {
        query = normalize(query)
        text = normalize(text)

        if (query.length === 0)
            return 0

        if (text === query)
            return 10000

        if (text.startsWith(query))
            return 8000 - text.length

        var directIndex = text.indexOf(query)

        if (directIndex >= 0)
            return 5000 - directIndex

        var q = 0
        var score = 0

        for (var i = 0;
             i < text.length && q < query.length;
             i++) {

            if (text[i] === query[q]) {
                score += 100
                q++
            }
        }

        if (q !== query.length)
            return -1

        return score
    }

    function sortResults(items, query) {
        var scored = []

        for (var i = 0; i < items.length; i++) {
            var item = items[i]

            var haystack =
                String(item.title || "") + " " +
                String(item.description || "") + " " +
                String(item.keywords || "")

            var score = fuzzyScore(query, haystack)

            if (score >= 0) {
                scored.push({
                    item: item,
                    score: score
                })
            }
        }

        scored.sort(function(a, b) {
            return b.score - a.score
        })

        var output = []

        for (var j = 0;
             j < scored.length && j < 40;
             j++) {

            output.push(scored[j].item)
        }

        return output
    }

    function search(text) {
        commandOutput = ""

        var query = normalize(text)

        if (query.length === 0) {
            modeText = "Applications"
            results = applicationResults("")
            return
        }

        if (query.startsWith("=")) {
            modeText = "Calculator"

            results = calculatorResults(
                query.substring(1).trim()
            )

            return
        }

        if (query.startsWith(">")) {
            modeText = "Command"

            results = commandResults(
                query.substring(1).trim()
            )

            return
        }

        if (
            query.startsWith("/") ||
            query.startsWith("~")
        ) {
            modeText = "Files"

            fileSearch.search(query)
            return
        }

        modeText = "Applications"

        results = applicationResults(query)
    }

    function applicationResults(query) {
        var output = []

        var entries = DesktopEntries.applications.values

        for (var i = 0; i < entries.length; i++) {
            var app = entries[i]

            output.push({
                title: app.name,

                description:
                    app.genericName ||
                    app.comment ||
                    "Application",

                icon: app.icon || "•",

                type: "app",

                keywords:
                    (app.keywords || []).join(" "),

                entry: app
            })
        }

        return sortResults(output, query)
    }

    function calculatorResults(expression) {
        if (expression.length === 0)
            return []

        var value = calculate(expression)

        if (value === null) {
            return [{
                title: "Invalid expression",

                description:
                    "Allowed: numbers + - * / ( ) %",

                icon: "=",

                type: "calculator-error"
            }]
        }

        return [{
            title: String(value),

            description:
                expression + " = " + String(value),

            icon: "=",

            type: "calculator",

            value: String(value)
        }]
    }

    function calculate(expression) {
        var e = String(expression)

        /*
         * Intentionally restricted calculator language.
         *
         * No identifiers.
         * No property access.
         * No function calls.
         * No strings.
         */
        if (!/^[0-9+\-*/().%\s]+$/.test(e))
            return null

        e = e.replace(/%/g, "/100")

        try {
            var value = Function(
                "\"use strict\"; return (" + e + ")"
            )()

            if (typeof value !== "number")
                return null

            if (!isFinite(value))
                return null

            return Math.round(
                value * 1000000000
            ) / 1000000000

        } catch (error) {
            return null
        }
    }

    function commandResults(command) {
        if (command.length === 0) {
            return [{
                title: "Execute shell command",

                description:
                    "Type a command after >",

                icon: "$",

                type: "command"
            }]
        }

        return [{
            title: command,

            description:
                "Execute using /bin/sh",

            icon: "$",

            type: "command",

            command: command
        }]
    }

    function setFileResults(items) {
        results = items
    }

    function appendCommandOutput(text) {
        commandOutput += text
    }

    function execute(item) {
        if (!item)
            return

        if (item.type === "app") {
            if (item.entry)
                item.entry.execute()

            return
        }

        if (item.type === "calculator") {
            Quickshell.clipboardText = item.value
            return
        }

        if (item.type === "file") {
            Quickshell.execDetached([
                "xdg-open",
                item.path
            ])

            return
        }

        if (item.type === "command") {
            if (!item.command)
                return

            commandOutput = ""

            commandRunner.run(item.command)

            return
        }
    }
}