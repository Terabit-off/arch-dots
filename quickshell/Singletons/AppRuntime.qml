import QtQuick
import Quickshell
import Quickshell.Hyprland
pragma Singleton

Item {
    property bool initialized: false
    property bool applicationsReady: false
    property bool applicationsIndexed: false
    property int applicationProbeAttempts: 0
    property var applications: []
    property var applicationUsageRank: ({
    })

    signal rawEventReceived(var event)
    signal startupComplete()

    function initialize() {
        if (initialized)
            return ;

        initialized = true;
        Hyprland.refreshToplevels();
        Hyprland.refreshWorkspaces();
        applicationProbeAttempts = 0;
        applicationProbe.start();
    }

    function refreshHyprland() {
        Hyprland.refreshToplevels();
        Hyprland.refreshWorkspaces();
    }

    function onHyprlandRawEvent(event) {
        rawEventReceived(event);
    }

    function buildApplicationIndex() {
        if (applicationsIndexed)
            return ;

        const entries = DesktopEntries.applications.values;
        const indexed = [];
        const seen = ({
        });
        for (let i = 0; i < entries.length; ++i) {
            const app = entries[i];
            const id = String(app.id || "").trim();
            if (!id || seen[id])
                continue;

            seen[id] = true;
            const title = String(app.name || "").trim();
            const description = String(app.genericName || app.comment || "Application").trim();
            const keywords = Array.isArray(app.keywords) ? app.keywords.join(" ") : "";
            indexed.push({
                "title": title,
                "description": description,
                "keywords": keywords,
                "searchText": (title + " " + description + " " + keywords).toLowerCase(),
                "icon": String(app.icon || ""),
                "type": "app",
                "id": id,
                "entry": app
            });
        }
        applications = indexed;
        applicationsIndexed = true;
        applicationsIndexedChanged();
    }

    Component.onCompleted: {
        Hyprland.rawEvent.connect(onHyprlandRawEvent);
        initialize();
    }
    Component.onDestruction: {
        Hyprland.rawEvent.disconnect(onHyprlandRawEvent);
    }

    Timer {
        id: applicationProbe

        interval: 100
        repeat: true
        onTriggered: {
            const entries = DesktopEntries.applications.values;
            if (entries.length > 0) {
                stop();
                applicationsReady = true;
                buildApplicationIndex();
                startupComplete();
                return ;
            }
            applicationProbeAttempts++;
            if (applicationProbeAttempts >= 30) {
                stop();
                applicationsReady = true;
                buildApplicationIndex();
                startupComplete();
            }
        }
    }

}
