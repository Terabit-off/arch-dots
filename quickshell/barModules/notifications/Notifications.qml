import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import "../../Singletons" as Singletons

Rectangle {
    id: notificationsRoot

    color: '#4b4b4b4b'
    radius: 5
    Layout.fillHeight: true
    implicitWidth: 25

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "󰂚" 
            color: historyModel.count > 0 ? '#ff6a6a' : Singletons.Colors.foreground
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 15
        }
        Text {
            visible: historyModel.count > 0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
            text: historyModel.count 
            color:'#ff6a6a'
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
        }

    }


    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            centerPopup.visible = true
        }
    }

    ListModel {
        id: historyModel
    }

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: n => {
            if (n.urgency != NotificationUrgency.Low){

                historyModel.insert(0, {
                    notification: n,
                    notificationId: n.id,
                    showInPanel: true,

                    summary: n.summary,
                    body: n.body,
                    appName: n.appName,
                    urgency: n.urgency,
                    time: Qt.formatDateTime(new Date(), "HH:mm"),
                    image: n.image || "",
                    appIcon: n.appIcon || ""
                })
            }

            n.tracked = true
        }
    }

    PanelWindow {
        anchors {
            top: true
            right: true
        }
        margins {
            top: 28
            right: 12
        }

        implicitHeight: Math.max(0, column.implicitHeight)
        implicitWidth: 380

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 10

            Repeater {
                model: server.trackedNotifications

                delegate: Rectangle {
                    id: card
                    required property var modelData

                    Timer {
                        running: modelData.urgency !== NotificationUrgency.Critical

                        interval: 5000
                        repeat: false

                        onTriggered: {
                            visible = false
                            // hideFromPanel(modelData.notificationId)
                        }
                    }

                    visible: true

                    Layout.fillWidth: true
                    Layout.preferredHeight: layout.implicitHeight + 30
                    
                    radius: 5
                    color: modelData.urgency === NotificationUrgency.Critical
                            ? "#422529" : "#f11c1c1c"
                    border.width: 1
                    border.color: transientMouse.containsMouse 
                                  ? Singletons.Colors.foreground 
                                  : "#db6e6e6e"

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }

                    RowLayout {
                        id: layout
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        Rectangle {
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 36
                            color: "transparent"
                            
                            Image {
                                id: transientIcon
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                visible: false
                                source: card.modelData.image || card.modelData.appIcon || ""
                            }
                            
                            Rectangle {
                                id: transientMask
                                anchors.fill: parent
                                radius: 6
                                color: "white"
                                visible: false
                            }
                            
                            OpacityMask {
                                anchors.fill: parent
                                source: transientIcon
                                maskSource: transientMask
                                visible: transientIcon.status === Image.Ready
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.summary
                                color: Singletons.Colors.foreground
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: card.modelData.body
                                color: Singletons.Colors.foreground
                                opacity: 0.8
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        id: transientMouse
                        anchors.fill: parent 
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            notificationsRoot.activateOrDismiss(card.modelData)
                        }
                    }
                }
            }
        }
    }

    // notifi center
    PopupWindow {
        id: centerPopup

        grabFocus: true
        visible: false

        implicitWidth: 420
        implicitHeight: Math.min(
            550,
            Math.max(
                200,
                historyList.contentHeight + 95
            )
        )

        anchor {
            item: notificationsRoot
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.top: 25
        }

        color: "transparent"

        Rectangle {
            id: popupBackground

            anchors.fill: parent
            radius: 5
            color: "#f11c1c1c"

            border.width: 1
            border.color: "#db6e6e6e"

            opacity: centerPopup.visible ? 1 : 0
            scale: centerPopup.visible ? 1 : 0.96

            Behavior on opacity {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
            Behavior on scale {
                NumberAnimation { duration: 180; easing.type: Easing.OutBack }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                // HEADER
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

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
                            text: historyModel.count === 0
                                ? "Nothing new"
                                : `${historyModel.count} notifications`

                            color: Singletons.Colors.foreground
                            opacity: 0.5
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 30

                        radius: 8
                        color: "transparent"
                        opacity: historyModel.count > 0 ? 1 : 0.4

                        Text {
                            anchors.centerIn: parent
                            text: "Clear"
                            color: clearMouse.containsMouse
                                   ? "#ffffff"
                                   : Singletons.Colors.foreground
                            opacity: clearMouse.containsMouse ? 1.0 : 0.6
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }

                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: historyModel.count > 0

                            onClicked: {
                                clearHistory()
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Singletons.Colors.foreground
                    opacity: 0.1
                }

                // NOTIFICATIONS
                ListView {
                    id: historyList

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    clip: true
                    spacing: 12
                    boundsBehavior: Flickable.StopAtBounds
                    model: historyModel
                    
                    ScrollBar.vertical: ScrollBar {
                        active: true
                    }

                    delegate: Rectangle {
                        id: notificationCard

                        required property var notification
                        required property int index
                        required property string summary
                        required property string body
                        required property string appName
                        required property int urgency
                        required property string time
                        required property string image
                        required property string appIcon

                        width: historyList.width

                        height: Math.max(
                            70,
                            notificationContent.implicitHeight + 20
                        )

                        radius: 8

                        color: urgency === NotificationUrgency.Critical
                            ? "#422529"
                            : "#302f2f2f"

                        border.width: 1
                        border.color: urgency === NotificationUrgency.Critical
                                    ? "#55a54242"
                                    : (notificationMouse.containsMouse 
                                        ? Singletons.Colors.foreground 
                                        : "#db6e6e6e")

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 250
                                easing.type: Easing.OutCubic
                            }
                        }

                        RowLayout {
                            id: notificationContent
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            // ICON
                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: 8
                                color: "transparent"

                                Image {
                                    id: centerIcon
                                    anchors.fill: parent
                                    visible: false
                                    fillMode: Image.PreserveAspectCrop
                                    source: image || appIcon || ""
                                }
                                
                                Rectangle {
                                    id: centerIconMask
                                    anchors.fill: parent
                                    radius: 8
                                    color: "white"
                                    visible: false
                                }
                                
                                OpacityMask {
                                    anchors.fill: parent
                                    source: centerIcon
                                    maskSource: centerIconMask
                                    visible: centerIcon.status === Image.Ready
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: image === "" && appIcon === ""
                                    text: "󰂚"
                                    color: Singletons.Colors.foreground
                                    opacity: 0.5
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 18
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        Layout.fillWidth: true
                                        text: summary || appName || "Notification"
                                        color: Singletons.Colors.foreground
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 13
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: time
                                        color: Singletons.Colors.foreground
                                        opacity: 0.5
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                    text: body
                                    color: Singletons.Colors.foreground
                                    opacity: 0.8
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    lineHeight: 1.15
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }

                        MouseArea {
                            id: notificationMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                notificationsRoot.activateOrDismiss(
                                    notificationCard.notification,
                                )
                            }
                        }
                    }

                    // EMPTY STATE
                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        visible: historyModel.count === 0

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
                            color: Singletons.Colors.foreground
                            opacity: 0.5
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }


    function activateOrDismiss(notification) {
        if (!notification)
            return

        const actions = notification.actions || []

        if (actions.length > 0) {
            let action = actions[0]

            for (const candidate of actions) {
                if (candidate.identifier === "default") {
                    action = candidate
                    break
                }
            }

            if (action && action.invoke)
                action.invoke()
        }else {
            notification.dismiss()
        }

        removeFromHistory(notification.id)
        centerPopup.visible = false
    }

    function removeFromHistory(notificationId) {
        for (let i = 0; i < historyModel.count; ++i) {
            if (historyModel.get(i).notificationId === notificationId) {
                historyModel.remove(i, 1)
                return
            }
        }
    }
    
    function clearHistory() {
        for (let i = 0; i < historyModel.count; ++i) {
            const item = historyModel.get(i)
            if (item.notification)
                item.notification.dismiss()
        }
        historyModel.clear()
    }
    
    function hideFromPanel(notificationId) {
        for (let i = 0; i < historyModel.count; ++i) {
            const item = historyModel.get(i)

            if (item.notificationId === notificationId) {
                historyModel.setProperty(
                    i,
                    "showInPanel",
                    false
                )
                return
            }
        }
    }
}