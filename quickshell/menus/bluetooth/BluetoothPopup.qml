import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Wayland

import "../../Singletons" as Singletons

PopupWindow {
    id: root

    property Item anchorItem

    visible: false
    grabFocus: true

    implicitWidth: 290
    implicitHeight: 400
    color: "transparent"

    anchor {
        item: anchorItem
        edges: Edges.Bottom
        gravity: Edges.Bottom
        margins.top: 25
    }

    onVisibleChanged: {
        if (!visible) {
            if (root.adapter) root.adapter.discovering = false
        }
    }

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property bool discovering: adapter ? adapter.discovering : false
    readonly property var devices: adapter ? adapter.devices : null


    function toggleBluetooth() {
        if (root.adapter) root.adapter.enabled = !root.adapter.enabled
    }

    function toggleDiscovering() {
        if (root.adapter) root.adapter.discovering = !root.adapter.discovering
    }

    function connect(device) {
        if (device) device.connect()
    }

    function disconnect(device) {
        if (device) device.disconnect()
    }

    function pair(device) {
        if (device) device.pair()
    }

    function cancelPair(device) {
        if (device) device.cancelPair()
    }

    function forget(device) {
        if (device) device.forget()
    }

    Rectangle {
        id: card

        anchors.fill: parent
        radius: Singletons.Colors.menuBorderRadius
        color: Singletons.Colors.menuBackground
        border.width: 1
        border.color: Singletons.Colors.menuBorderColor

        opacity: root.visible ? 1 : 0
        scale: root.visible ? 1 : 0.96

        Behavior on opacity {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 12
                    color: root.enabled ? '#26828282' : "#18ffffff"

                    Text {
                        anchors.centerIn: parent
                        text: "󰂯"
                        color: root.enabled ? Singletons.Colors.foreground : Singletons.Colors.foregroundDim
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 21
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: "Bluetooth"
                        color: Singletons.Colors.foreground
                        font.pixelSize: 17
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.adapter ? root.adapter.name : "No adapters"
                        color: root.enabled ? Singletons.Colors.foreground : Singletons.Colors.foregroundDim
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }
                }

                // On/Off button
                Rectangle {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 24
                    radius: 12
                    color: root.enabled ? Singletons.Colors.buttonBackgroundColorHover : Singletons.Colors.buttonBackgroundColor

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        anchors.verticalCenter: parent.verticalCenter
                        x: root.enabled ? parent.width - width - 3 : 3
                        color: root.enabled ? Singletons.Colors.foreground : Singletons.Colors.foregroundDim

                        Behavior on x { NumberAnimation { duration: 160 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleBluetooth()
                    }
                }

                // Search button
                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 10
                    visible: root.enabled
                    color: scanMouse.containsMouse ? Singletons.Colors.buttonBackgroundColorHover : Singletons.Colors.buttonBackgroundColor

                    Text {
                        anchors.centerIn: parent
                        text: "󰑐"
                        color: Singletons.Colors.foreground
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 17

                        RotationAnimation on rotation {
                            running: root.discovering
                            from: 0
                            to: 360
                            duration: 900
                            loops: Animation.Infinite
                        }
                    }

                    MouseArea {
                        id: scanMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleDiscovering()
                    }
                }
            }

            // Subheader
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: root.discovering ? "Searching..." : "Devices"
                    color: Singletons.Colors.foregroundDim
                    font.pixelSize: 10
                    font.weight: Font.Medium
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Singletons.Colors.separatorColor
                }

                Text {
                    text: deviceList.count
                    color: Singletons.Colors.foregroundDim
                    font.pixelSize: 9
                }
            }

            // Device list
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: deviceList
                    anchors.fill: parent
                    clip: true
                    spacing: 5
                    boundsBehavior: Flickable.StopAtBounds

                    model: root.devices

                    delegate: Rectangle {
                        id: delegateRoot
                        required property var modelData
                        property bool expanded: false

                        width: deviceList.width
                        height: expanded 
                            ? networkRow.height + expandedContent.implicitHeight + 20 
                            : 56
                        radius: 5
                        color: modelData.connected 
                            ? '#e0282828' 
                            : '#d2242424'

                        border.width: modelData.connected ? 1 : 0
                        border.color: '#78818181'

                        Behavior on height {
                            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                        }
                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }

                        RowLayout {
                            id: networkRow
                            anchors {
                                left: parent.left; 
                                right: parent.right; 
                                top: parent.top 
                            }
                            height: 56
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                color: "transparent"
                                

                                Text {
                                    anchors.centerIn: parent
                                    //visible: deviceIconImage.status !== Image.Ready
                                    text: getDeviceIcon(modelData.icon)
                                    color: Singletons.Colors.foregroundDim
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 19
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name || modelData.deviceName || modelData.address
                                    color: Singletons.Colors.foreground
                                    font.pixelSize: 12
                                    font.weight: modelData.connected ? Font.DemiBold : Font.Normal
                                    elide: Text.ElideRight
                                }

                                RowLayout {
                                    spacing: 4
                                    Text {
                                        text: deviceStateText(modelData)
                                        color: modelData.connected ? "#86efac" : Singletons.Colors.foregroundDim
                                        font.pixelSize: 10
                                    }
                                    Text {
                                        visible: modelData.batteryAvailable
                                        text: modelData.batteryAvailable ? "• " + Math.round(modelData.battery * 100) + "%" : ""
                                        color: Singletons.Colors.foregroundDim
                                        font.pixelSize: 10
                                    }
                                }
                            }

                            Text {
                                visible: modelData.connected
                                text: "󰄬"
                                color: Singletons.Colors.foregroundDim
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 17
                            }

                            Text {
                                visible: !modelData.connected && !expanded
                                text: "󰅂"
                                color: "#686870"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 16
                                rotation: expanded ? 90 : 0
                                Behavior on rotation { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                            }
                        }

                        // expanded Menu
                        ColumnLayout {
                            id: expandedContent
                            anchors {
                                left: parent.left;
                                right: parent.right; 
                                top: networkRow.bottom; 
                                leftMargin: 10; 
                                rightMargin: 10; 
                                bottomMargin: 10
                            }

                            spacing: 7
                            visible: expanded
                            opacity: expanded ? 1 : 0
                            Behavior on opacity { 
                                NumberAnimation { duration: 120 }
                            }

                            //  Connect/pair
                            Rectangle {
                                visible: !modelData.connected
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                radius: 9
                                color: connectMouse.containsMouse ? '#6dadadad' : '#6d707070'

                                Text {
                                    anchors.centerIn: parent
                                    text: {
                                        if (modelData.pairing) return "Cancle"
                                        if (modelData.paired) return "Connect"
                                        return "Pair"
                                    }
                                    color: "white"
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    id: connectMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData.pairing) root.cancelPair(modelData)
                                        else if (modelData.paired) root.connect(modelData)
                                        else root.pair(modelData)
                                        delegateRoot.expanded = false
                                    }
                                }
                            }

                            // Button disconnect
                            Rectangle {
                                visible: modelData.connected
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                radius: 9
                                color: disconnectMouse.containsMouse ? "#30272a" : "#201f21"
                                border.width: 1
                                border.color: "#20ffffff"

                                Text {
                                    anchors.centerIn: parent
                                    text: "Disconnect"
                                    color: "#d99aa1"
                                    font.pixelSize: 10
                                }

                                MouseArea {
                                    id: disconnectMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.disconnect(modelData)
                                        delegateRoot.expanded = false
                                    }
                                }
                            }

                            // Button forget
                            Rectangle {
                                visible: modelData.paired && !modelData.connected
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                radius: 8
                                color: forgetMouse.containsMouse ? "#30272a" : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "Forget"
                                    color: "#a98288"
                                    font.pixelSize: 10
                                }

                                MouseArea {
                                    id: forgetMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.forget(modelData)
                                        delegateRoot.expanded = false
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: networkMouse
                            anchors {
                                left: parent.left; 
                                right: parent.right; 
                                top: parent.top 
                            }
                            height: 56
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: delegateRoot.expanded = !delegateRoot.expanded
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 7
                    visible: deviceList.count === 0

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.enabled ? "󰂯" : "󰂲"
                        color: "#5d5d65"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 29
                    }

                    Text {
                        width: 240
                        text: !root.enabled ? "Bluetooth off" : (root.discovering ? "Searching..." : "Not found")
                        color: "#77777f"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }

    function deviceStateText(device) {
        if (!device) return ""
        if (device.connected) return "Connected"
        if (device.pairing) return "Pairing..."
        if (device.paired) return "Paired"
        return "Not paired"
    }

    function getDeviceIcon(iconName) {
        if (!iconName) return "󰂯";

        let name = iconName.toLowerCase();

        if (name.includes("headphone") || name.includes("headset")) return "󰋋";
        if (name.includes("mouse")) return "󰍽";
        if (name.includes("keyboard")) return "󰌌";
        if (name.includes("gaming") || name.includes("joypad")) return "󰊗";
        if (name.includes("phone") || name.includes("smartphone")) return "󰏲";
        if (name.includes("laptop")) return "󰌢";
        if (name.includes("computer") || name.includes("desktop")) return "󰇄";
        if (name.includes("audio") || name.includes("speaker")) return "󰓃";
        if (name.includes("network")) return "󰤨";
        
        return "󰂯";
    }
}