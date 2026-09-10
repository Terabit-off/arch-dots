import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string homePath: "/home/terabit"
    property int debounceMs: 160
    property int maxResults: 40
    property int maxHomeDepth: 8
    property bool pathMode: false
    property string pendingQuery: ""
    property string activePath: ""
    property int requestSerial: 0
    property var directoryItems: []
    property var fileItems: []
    property bool directoryFinished: false
    property bool fileFinished: false

    signal resultsReady(var items)

    function stop() {
        debounce.stop();
        root.requestSerial++;
        directoryProcess.running = false;
        fileProcess.running = false;
        directoryItems = [];
        fileItems = [];
        directoryFinished = false;
        fileFinished = false;
    }

    function search(query) {
        pendingQuery = String(query || "").trim();
        pathMode = true;
        debounce.restart();
    }

    function searchHome(query) {
        pendingQuery = String(query || "").trim();
        pathMode = false;
        debounce.restart();
    }

    function resolveHomePath(input) {
        var value = String(input || "").trim();
        if (value === "" || value === "~" || value === "~/")
            return root.homePath;

        if (value.startsWith("~/"))
            return root.homePath + value.substring(1);

        if (value.startsWith("/"))
            return root.homePath + value;

        return root.homePath + "/" + value;
    }

    function normalizePath(path) {
        var parts = String(path || "").split("/");
        var output = [];
        for (var i = 0; i < parts.length; i++) {
            var part = parts[i];
            if (!part || part === ".")
                continue;

            if (part === "..") {
                if (output.length > 0)
                    output.pop();

                continue;
            }
            output.push(part);
        }
        return "/" + output.join("/");
    }

    function startSearch(query, isPathMode) {
        root.requestSerial++;
        var serial = root.requestSerial;
        directoryProcess.running = false;
        fileProcess.running = false;
        directoryItems = [];
        fileItems = [];
        directoryFinished = false;
        fileFinished = false;
        query = String(query || "").trim();
        if (isPathMode) {
            var directory = normalizePath(root.resolveHomePath(query));
            root.activePath = directory;
            directoryProcess.command = ["find", directory, "-mindepth", "1", "-maxdepth", "1", "-type", "d", "-print"];
            fileProcess.command = ["find", directory, "-mindepth", "1", "-maxdepth", "1", "-type", "f", "-print"];
            directoryProcess.running = true;
            fileProcess.running = true;
            return ;
        }
        if (query.length < 2) {
            resultsReady([]);
            return ;
        }
        // Generic filesystem search is always restricted to /home/terabit.
        root.activePath = root.homePath;
        directoryProcess.command = ["fd", "--hidden", "--ignore-case", "--type", "d", "--max-depth", String(root.maxHomeDepth), "--max-results", String(root.maxResults), "--exclude", ".git", "--exclude", ".cache", "--exclude", "node_modules", "--exclude", ".npm", "--exclude", ".local/share/Trash", query, root.homePath];
        fileProcess.command = ["fd", "--hidden", "--ignore-case", "--type", "f", "--max-depth", String(root.maxHomeDepth), "--max-results", String(root.maxResults), "--exclude", ".git", "--exclude", ".cache", "--exclude", "node_modules", "--exclude", ".npm", "--exclude", ".local/share/Trash", query, root.homePath];
        directoryProcess.running = true;
        fileProcess.running = true;
    }

    function parseLines(text) {
        var lines = String(text || "").split("\n");
        var paths = [];
        for (var i = 0; i < lines.length; i++) {
            var path = lines[i].trim();
            if (path.length > 0)
                paths.push(path);

        }
        return paths;
    }

    function makeItem(path, type) {
        var cleanPath = String(path || "");
        var slash = cleanPath.lastIndexOf("/");
        var title = slash >= 0 ? cleanPath.substring(slash + 1) : cleanPath;
        if (title === "")
            title = cleanPath;

        return {
            "title": type === "folder" ? displayPath(title) : title,
            "description": type === "folder" || type === "file" ? displayPath(cleanPath) : cleanPath,
            "icon": type === "folder" ? "folder" : (isImage(cleanPath) ? "file://" + cleanPath : "file"),
            "type": type,
            "path": cleanPath
        };
    }

    function displayPath(path) {
        if (!path)
            return "";

        const home = "/home/terabit";
        if (path === home)
            return "~";

        if (path.indexOf(home + "/") === 0)
            return "~" + path.substring(home.length);

        return path;
    }

    function finishDirectories(text, serial) {
        if (serial !== root.requestSerial)
            return ;

        directoryItems = [];
        var paths = parseLines(text);
        for (var i = 0; i < paths.length && directoryItems.length < root.maxResults; i++) directoryItems.push(makeItem(paths[i], "folder"))
        directoryFinished = true;
        publishIfReady();
    }

    function finishFiles(text, serial) {
        if (serial !== root.requestSerial)
            return ;

        fileItems = [];
        var paths = parseLines(text);
        for (var i = 0; i < paths.length && fileItems.length < root.maxResults; i++) fileItems.push(makeItem(paths[i], "file"))
        fileFinished = true;
        publishIfReady();
    }

    function publishIfReady() {
        if (!directoryFinished || !fileFinished)
            return ;

        var output = directoryItems.concat(fileItems);
        output.sort(function(a, b) {
            if (a.type !== b.type)
                return a.type === "folder" ? -1 : 1;

            return String(a.title).localeCompare(String(b.title));
        });
        resultsReady(output.slice(0, root.maxResults));
    }

    function isImage(path) {
        var lower = String(path || "").toLowerCase();
        return lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".png") || lower.endsWith(".webp") || lower.endsWith(".gif") || lower.endsWith(".bmp") || lower.endsWith(".svg") || lower.endsWith(".avif");
    }

    Timer {
        id: debounce

        interval: root.debounceMs
        repeat: false
        onTriggered: root.startSearch(pendingQuery, root.pathMode)
    }

    Process {
        id: directoryProcess

        stdout: StdioCollector {
            onStreamFinished: root.finishDirectories(this.text || "", root.requestSerial)
        }

        stderr: StdioCollector {
        }

    }

    Process {
        id: fileProcess

        stdout: StdioCollector {
            onStreamFinished: root.finishFiles(this.text || "", root.requestSerial)
        }

        stderr: StdioCollector {
        }

    }

}
