import "../../Singletons" as Singletons

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

Rectangle {
    id: root

    property bool doNotDisturb: false
    property int toastTimeout: 5000
    property int maxHistory: 100
    property var hiddenToastIds: []

    color: Singletons.Colors.barModuleColor
    radius: 5
    implicitWidth: 25
    Layout.fillHeight: true

    function iconSource(icon) {
        if (!icon)
            return ""

        if (icon.startsWith("image://") || icon.startsWith("/")
                || icon.startsWith("file://"))
            return icon

        return Quickshell.iconPath(icon)
    }

    function historyIndex(id) {
        for (let i = 0; i < historyModel.count; ++i) {
            if (historyModel.get(i).notificationId === id)
                return i
        }
        return -1
    }

    function addToHistory(notification) {
        if (!notification)
            return

        const item = {
            notificationId: notification.id,
            summary: notification.summary || notification.appName || "Notification",
            body: notification.body || "",
            appIcon: notification.appIcon || "",
            image: notification.image || "",
            urgency: notification.urgency,
            time: Qt.formatTime(new Date(), "HH:mm")
        }

        const index = historyIndex(notification.id)

        if (index >= 0)
            historyModel.set(index, item)
        else
            historyModel.insert(0, item)

        while (historyModel.count > maxHistory)
            historyModel.remove(historyModel.count - 1)
    }

    function removeFromHistory(id) {
        const index = historyIndex(id)
        if (index >= 0)
            historyModel.remove(index)
    }

    function notificationForId(id) {
        const values = notificationServer.trackedNotifications.values
        for (let i = 0; i < values.length; ++i) {
            const n = values[i]
            if (n && n.id === id)
                return n
        }
        return null
    }

    function isToastHidden(id) {
        return hiddenToastIds.indexOf(id) !== -1
    }

    function hideToast(id) {
        if (!isToastHidden(id))
            hiddenToastIds = hiddenToastIds.concat([id])
    }

    function resetToastVisibility(id) {
        hiddenToastIds = hiddenToastIds.filter(item => item !== id)
    }

    function suppressAllCurrentToasts() {
        const values = notificationServer.trackedNotifications.values
        const ids = hiddenToastIds.slice()

        for (let i = 0; i < values.length; ++i) {
            const notification = values[i]
            if (!notification)
                continue

            if (notification.urgency !== NotificationUrgency.Critical
                    && ids.indexOf(notification.id) === -1) {
                ids.push(notification.id)
            }
        }

        hiddenToastIds = ids
    }

    onDoNotDisturbChanged: {
        if (doNotDisturb)
            suppressAllCurrentToasts()
    }

    function pruneHiddenToastIds() {
        const values = notificationServer.trackedNotifications.values
        const activeIds = values.map(notification => notification ? notification.id : -1)
        hiddenToastIds = hiddenToastIds.filter(id => activeIds.indexOf(id) !== -1)
    }

    function dismissNotification(id) {
        const notification = notificationForId(id)
        hideToast(id)
        removeFromHistory(id)

        if (notification && typeof notification.dismiss === "function")
            notification.dismiss()
    }

    function expireNotification(id) {
        hideToast(id)
    }

    function invokeAction(id, actionId) {
        const notification = notificationForId(id)
        if (!notification || !actionId)
            return

        const action = (notification.actions || [])
            .find(item => item.identifier === actionId)

        if (!action)
            return

        hideToast(id)
        action.invoke()
        removeFromHistory(id)
    }

    ListModel {
        id: historyModel
    }

    NotificationServer {
        id: notificationServer

        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: notification => {
            if (notification.urgency !== NotificationUrgency.Low)
                addToHistory(notification)

            notification.tracked = true

            if (root.doNotDisturb && notification.urgency !== NotificationUrgency.Critical)
                hideToast(notification.id)
            else
                resetToastVisibility(notification.id)

            pruneHiddenToastIds()
        }

    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredWidth: 25
            Layout.preferredHeight: 20

            Image {
                anchors.centerIn: parent
                width: 16
                height: 16
                fillMode: Image.PreserveAspectFit

                source: root.doNotDisturb
                    ? "icons/notifi_off.svg"
                    : historyModel.count
                        ? "icons/notifi_active.svg"
                        : "icons/notifi.svg"

                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization: 1
                    colorizationColor: historyModel.count
                        ? "#ffafaf"
                        : "#ffffff"
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                width: 10
                height: 10
                radius: 5
                visible: historyModel.count
                color: "#b45c5c"

                Text {
                    anchors.centerIn: parent
                    text: historyModel.count > 99 ? "99" : historyModel.count
                    color: "white"
                    font.pixelSize: 7
                    font.bold: true
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: notificationCenter.visible = !notificationCenter.visible
            }
        }
    }

    PanelWindow {
        id: toastWindow

        implicitWidth: 380
        implicitHeight: toastColumn.implicitHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Overlay

        anchors {
            top: true
            right: true
        }
        margins {
            top: 28
            right: 12
        }

        ColumnLayout {
            id: toastColumn
            width: parent.width
            spacing: 10

            Repeater {
                model: notificationServer.trackedNotifications

                delegate: Item {
                    id: toastDelegate

                    required property var modelData
                    property var notification: modelData
                    property int remainingMs: root.toastTimeout

                    visible: notification !== null && notification !== undefined
                             && !root.isToastHidden(notification.id)
                             && (!root.doNotDisturb
                                 || notification.urgency === NotificationUrgency.Critical)

                    Layout.fillWidth: true
                    implicitHeight: visible ? card.implicitHeight : 0

                    Timer {
                        id: toastTimer

                        running: notification !== null
                                && !root.isToastHidden(notification.id)
                                && !root.doNotDisturb
                                && notification.urgency !== NotificationUrgency.Critical

                        interval: 50
                        repeat: true

                        onTriggered: {
                            toastDelegate.remainingMs = Math.max(
                                0,
                                toastDelegate.remainingMs - interval
                            )

                            if (toastDelegate.remainingMs <= 0) {
                                stop()
                                root.expireNotification(toastDelegate.notification.id)
                            }
                        }
                    }

                    NotificationCard {
                        id: card

                        anchors.fill: parent
                        compact: true
                        notification: toastDelegate.notification

                        progress: toastDelegate.remainingMs / root.toastTimeout

                        onClicked: root.dismissNotification(toastDelegate.notification.id)
                        onActionInvoked: actionId =>
                            root.invokeAction(toastDelegate.notification.id, actionId)
                    }
                    NumberAnimation on progress {
                        id: progressAnimation

                        from: 1.0
                        to: 0.0
                        duration: root.toastTimeout
                        easing.type: Easing.Linear

                        running: toastDelegate.notification !== null
                                && !root.isToastHidden(toastDelegate.notification.id)
                                && !root.doNotDisturb
                                && toastDelegate.notification.urgency !== NotificationUrgency.Critical

                        onFinished: {
                            if (toastDelegate.notification)
                                root.expireNotification(toastDelegate.notification.id)
                        }
                    }
                }
            }
        }
    }

    PopupWindow {
        id: notificationCenter

        visible: false
        grabFocus: true
        implicitWidth: 420
        implicitHeight: Math.min(550, Math.max(250, historyList.contentHeight + 110))
        color: "transparent"

        anchor {
            item: root
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.top: 25
        }

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: Singletons.Colors.menuBackground
            border.width: 1
            border.color: Singletons.Colors.menuBorderColor

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Notifications"
                            color: Singletons.Colors.foreground
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: historyModel.count
                                ? `${historyModel.count} notifications`
                                : "No notifications"
                            color: Singletons.Colors.foreground
                            opacity: 0.5
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }
                    }

                    NotificationButton {
                        Layout.preferredWidth: 54
                        text: "Clear"
                        enabled: historyModel.count > 0
                        onClicked: historyModel.clear()
                    }

                    NotificationButton {
                        Layout.preferredWidth: 54
                        text: root.doNotDisturb ? "󰂛" : "󰂚"
                        fontFamily: "JetBrainsMono Nerd Font"
                        onClicked: root.doNotDisturb = !root.doNotDisturb
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Singletons.Colors.separatorColor
                }

                ListView {
                    id: historyList

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 10
                    model: historyModel
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar {
                        active: true
                    }

                    delegate: Item {
                        id: historyDelegate

                        required property var notificationId
                        required property string summary
                        required property string body
                        required property string appIcon
                        required property string image
                        required property int urgency
                        required property string time

                        property var liveNotification: root.notificationForId(notificationId)

                        width: historyList.width
                        implicitHeight: card.implicitHeight

                        NotificationCard {
                            id: card

                            anchors.fill: parent
                            notification: historyDelegate.liveNotification
                            summaryFallback: historyDelegate.summary
                            bodyFallback: historyDelegate.body
                            appIconFallback: historyDelegate.appIcon
                            imageFallback: historyDelegate.image
                            urgencyFallback: historyDelegate.urgency
                            time: historyDelegate.time

                            onClicked: root.dismissNotification(historyDelegate.notificationId)
                            onActionInvoked: actionId =>
                                root.invokeAction(historyDelegate.notificationId, actionId)
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        visible: historyModel.count === 0
                        spacing: 8

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "󰂚"
                            color: Singletons.Colors.foreground
                            opacity: 0.3
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 32
                        }

                        Text {
                            width: 200
                            text: "No notifications"
                            horizontalAlignment: Text.AlignHCenter
                            color: Singletons.Colors.foreground
                            opacity: 0.5
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }

    component NotificationIcon: Item {
        property string source: ""

        Image {
            id: image

            anchors.fill: parent
            source: parent.source
            visible: false
            fillMode: Image.PreserveAspectFit
        }

        Rectangle {
            id: mask
            anchors.fill: parent
            radius: 7
            visible: false
        }

        MultiEffect {
            anchors.fill: parent
            source: image
            maskEnabled: true
            maskSource: mask
            visible: image.status === Image.Ready
        }

        Text {
            anchors.centerIn: parent
            visible: image.status !== Image.Ready
            text: "󰂚"
            color: Singletons.Colors.foreground
            opacity: 0.5
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18
        }
    }

    component NotificationButton: Rectangle {
        property string text: ""
        property string fontFamily: "JetBrainsMono Nerd Font"
        property color normalColor: "transparent"
        property color hoverColor: '#9f818181'
        property color borderColor: "transparent"
        property color hoverBorderColor: "transparent"
        signal clicked()

        Layout.preferredHeight: 30
        radius: 6
        color: mouse.containsMouse ? hoverColor : normalColor
        border.width: hoverBorderColor === "transparent" && borderColor === "transparent"
            ? 0
            : 1
        border.color: mouse.containsMouse ? hoverBorderColor : borderColor
        opacity: enabled ? 1 : 0.4

        Text {
            anchors.centerIn: parent
            width: parent.width - 14
            text: parent.text
            color: Singletons.Colors.foreground
            font.family: parent.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            enabled: parent.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component NotificationCard: Rectangle {
        id: cardRoot

        property var notification: null
        property string summaryFallback: ""
        property string bodyFallback: ""
        property string appIconFallback: ""
        property string imageFallback: ""
        property int urgencyFallback: NotificationUrgency.Normal
        property bool compact: false
        property string time: ""

        property real progress: 0

        property string displaySummary: notification
            ? (notification.summary || notification.appName || summaryFallback || "Notification")
            : (summaryFallback || "Notification")
        property string displayBody: notification
            ? (notification.body || bodyFallback)
            : bodyFallback
        property string displayAppIcon: notification
            ? (notification.appIcon || appIconFallback)
            : appIconFallback
        property string displayImage: notification
            ? (notification.image || imageFallback)
            : imageFallback
        property int displayUrgency: notification
            ? notification.urgency
            : urgencyFallback
        property var displayActions: notification
            ? (notification.actions || [])
            : []

        signal clicked()
        signal closed()
        signal actionInvoked(string actionId)

        implicitHeight: content.implicitHeight
        radius: 8
        clip: true

        color: displayUrgency === NotificationUrgency.Critical
            ? Singletons.Colors.notifiCardCriticalBackground
            : Singletons.Colors.notifiCardBackground

        border.width: 1
        border.color: hoverHandler.hovered
            ? Singletons.Colors.notifiCardHoverBorderBackground
            : Singletons.Colors.notifiCardBorderBackground

        HoverHandler {
            id: hoverHandler
        }

        MouseArea {
            anchors.fill: parent
            enabled: true
            cursorShape: Qt.PointingHandCursor
            z: 0
            onClicked: cardRoot.clicked()
        }

        ColumnLayout {
            id: content
            z: 1

            width: parent.width
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 12
                Layout.rightMargin: 12
                spacing: 12

                NotificationIcon {
                    Layout.preferredWidth: compact ? 38 : 40
                    Layout.preferredHeight: compact ? 38 : 40
                    source: root.iconSource(displayImage || displayAppIcon)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: displaySummary || "Notification"
                            textFormat: Text.PlainText
                            color: Singletons.Colors.foreground
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: compact ? 14 : 13
                            font.weight: compact ? Font.Bold : Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            visible: !compact && time.length > 0
                            text: time
                            color: Singletons.Colors.foreground
                            opacity: 0.5
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: displayBody
                        visible: text.length > 0
                        textFormat: Text.PlainText
                        color: Singletons.Colors.foreground
                        opacity: 0.8
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                        maximumLineCount: compact ? 3 : 6
                        elide: Text.ElideRight
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                Layout.bottomMargin: 12
                spacing: 8
                visible: displayActions.length > 0

                Repeater {
                    model: displayActions

                    delegate: NotificationButton {
                        Layout.fillWidth: true
                        normalColor: "#303030"
                        hoverColor: "#454545"
                        borderColor: "#414141"
                        hoverBorderColor: "#666666"
                        text: modelData.text || modelData.identifier
                        onClicked: cardRoot.actionInvoked(modelData.identifier)
                    }
                }
            }
        }

        Item {
            id: progressContainer

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: 3
            z: 2
            clip: true

            Rectangle {
                anchors.left: parent.left
                anchors.bottom: parent.bottom

                width: parent.width * Math.max(0, Math.min(1, cardRoot.progress))
                height: parent.height

                radius: parent.height / 2

                color: Singletons.Colors.foreground
                opacity: 0.6
            }
        }

    }
}
