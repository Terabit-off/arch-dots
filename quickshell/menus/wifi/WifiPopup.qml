import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Networking

PopupWindow {
    id: root

    property Item anchorItem
    property bool connected: root.wifiDevice ? root.wifiDevice.connected : false
    property var selectedNetwork: null
    property string password: ""
    property string errorText: ""
    property bool showPassword: false

    readonly property var wifiDevice: {
        for (const device of Networking.devices.values) {
            if (device.type === DeviceType.Wifi)
                return device
        }
        return null
    }

    implicitWidth: 290
    implicitHeight: 300
    color: "transparent"
    grabFocus: true

    anchor {
        item: anchorItem
        edges: Edges.Bottom
        gravity: Edges.Bottom
        margins.top: 25
    }

    onVisibleChanged: {
        if (visible && wifiDevice)
            wifiDevice.scannerEnabled = true

        if (!visible) {
            selectedNetwork = null
            password = ""
            errorText = ""
            showPassword = false
        }
    }

    Connections {
        target: root.selectedNetwork

        function onConnectionFailed(reason) {
            root.errorText = reason || "Failed to connect"
        }
    }

    Rectangle {
        id: card

        anchors.fill: parent
        radius: 18
        color: "#e91b1b1f"
        border.width: 1
        border.color: "#35ffffff"

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

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 12
                    color: root.wifiDevice && root.wifiDevice.connected
                           ? "#263f7f58" : "#18ffffff"

                    Text {
                        anchors.centerIn: parent
                        text: "󰖩"
                        color: root.wifiDevice && root.wifiDevice.connected
                               ? "#9bd1aa" : "#d0d0d0"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 21
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: "Wi-Fi"
                        color: "#f4f4f5"
                        font.pixelSize: 17
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.wifiDevice
                              ? (root.wifiDevice.connected
                                 ? "Connected to a network"
                                 : "Not connected")
                              : "Wi-Fi device unavailable"
                        color: root.wifiDevice && root.wifiDevice.connected
                               ? "#8fc99f" : "#85858d"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 10
                    color: scanMouse.containsMouse
                           ? "#24ffffff" : "#12ffffff"

                    Text {
                        anchors.centerIn: parent
                        text: "󰑐"
                        color: "#d0d0d4"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 17

                        RotationAnimation on rotation {
                            running: root.wifiDevice !== null &&
                                     root.wifiDevice.scannerEnabled
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
                        enabled: root.wifiDevice !== null

                        onClicked: {
                            root.wifiDevice.scannerEnabled = true
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#18ffffff"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: root.selectedNetwork
                          ? "Other networks" : "Available networks"
                    color: "#92929a"
                    font.pixelSize: 10
                    font.weight: Font.Medium
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#15ffffff"
                }

                Text {
                    text: networkList.count
                    color: "#62626a"
                    font.pixelSize: 9
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: networkList

                    anchors.fill: parent

                    clip: true
                    spacing: 5

                    boundsBehavior: Flickable.StopAtBounds

                    model: root.wifiDevice
                        ? root.wifiDevice.networks
                        : null

                    delegate: Rectangle {
                        id: delegateRoot

                        required property var modelData

                        property bool expanded: false
                        property string password: ""
                        property bool showPassword: false

                        width: networkList.width

                        // Обычная высота / раскрытая высота
                        height: expanded
                            ? networkRow.height +
                            expandedContent.implicitHeight +
                            20
                            : 56

                        radius: 11

                        color: modelData.connected
                            ? "#1b3044"
                            : networkMouse.containsMouse
                                ? "#16ffffff"
                                : "#0bffffff"

                        border.width: modelData.connected ? 1 : 0
                        border.color: "#386b91"

                        Behavior on height {
                            NumberAnimation {
                                duration: 220
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }

                        // ============================================================
                        // ОСНОВНАЯ СТРОКА
                        // ============================================================

                        RowLayout {
                            id: networkRow

                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                            }

                            height: 56

                            anchors.leftMargin: 10
                            anchors.rightMargin: 10

                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36

                                radius: 10

                                color: modelData.connected
                                    ? "#263f7f58"
                                    : "#15ffffff"

                                Text {
                                    anchors.centerIn: parent

                                    text: signalIcon(modelData.signalStrength)

                                    color: signalColor(modelData.signalStrength)

                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 19
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true

                                spacing: 2

                                Text {
                                    Layout.fillWidth: true

                                    text: modelData.name || "Hidden network"

                                    color: "#eeeeef"

                                    font.pixelSize: 12
                                    font.weight: modelData.connected
                                                ? Font.DemiBold
                                                : Font.Normal

                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true

                                    text: networkState(modelData)

                                    color: modelData.connected
                                        ? "#8fc99f"
                                        : "#77777f"

                                    font.pixelSize: 10
                                }
                            }

                            Text {
                                visible: modelData.security !== WifiSecurityType.Open

                                text: "󰌾"

                                color: "#85858c"

                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 14
                            }

                            Text {
                                visible: modelData.connected

                                text: "󰄬"

                                color: "#8fc99f"

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

                                Behavior on rotation {
                                    NumberAnimation {
                                        duration: 180
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }
                        }

                        // ============================================================
                        // РАСКРЫТАЯ ЧАСТЬ
                        // ============================================================

                        ColumnLayout {
                            id: expandedContent

                            anchors {
                                left: parent.left
                                right: parent.right
                                top: networkRow.bottom

                                leftMargin: 10
                                rightMargin: 10
                                bottomMargin: 10
                            }

                            spacing: 7

                            visible: expanded

                            opacity: expanded ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 120
                                }
                            }

                            // --------------------------------------------------------
                            // OPEN NETWORK
                            // --------------------------------------------------------

                            Rectangle {
                                visible: modelData.security === WifiSecurityType.Open

                                Layout.fillWidth: true
                                Layout.preferredHeight: 34

                                radius: 9

                                color: connectMouse.containsMouse
                                    ? "#6f8fce"
                                    : "#5f7fba"

                                Text {
                                    anchors.centerIn: parent

                                    text: modelData.connected
                                        ? "Disconnect"
                                        : "Connect"

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
                                        if (modelData.connected) {
                                            modelData.disconnect()
                                        } else {
                                            modelData.connect()
                                        }

                                        delegateRoot.expanded = false
                                    }
                                }
                            }

                            // --------------------------------------------------------
                            // PASSWORD
                            // --------------------------------------------------------

                            RowLayout {
                                visible: modelData.security !== WifiSecurityType.Open &&
                                        !modelData.connected

                                Layout.fillWidth: true

                                spacing: 6

                                TextField {
                                    id: passwordField

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 34

                                    placeholderText: "Wi-Fi password"

                                    echoMode: delegateRoot.showPassword
                                            ? TextInput.Normal
                                            : TextInput.Password

                                    text: delegateRoot.password

                                    color: "#eeeeef"

                                    placeholderTextColor: "#66666d"

                                    font.pixelSize: 11

                                    background: Rectangle {
                                        radius: 9

                                        color: "#141419"

                                        border.width: 1

                                        border.color: passwordField.activeFocus
                                                    ? "#5275b0"
                                                    : "#20ffffff"
                                    }

                                    onTextChanged: {
                                        delegateRoot.password = text
                                    }

                                    onAccepted: {
                                        passwordButton.clicked()
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34

                                    radius: 9

                                    color: eyeMouse.containsMouse
                                        ? "#20ffffff"
                                        : "#12ffffff"

                                    Text {
                                        anchors.centerIn: parent

                                        text: delegateRoot.showPassword
                                            ? "󰈈"
                                            : "󰈉"

                                        color: "#9999a0"

                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 15
                                    }

                                    MouseArea {
                                        id: eyeMouse

                                        anchors.fill: parent

                                        hoverEnabled: true

                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: {
                                            delegateRoot.showPassword =
                                                !delegateRoot.showPassword
                                        }
                                    }
                                }

                                Rectangle {
                                    id: passwordButton

                                    Layout.preferredWidth: 90
                                    Layout.preferredHeight: 34

                                    radius: 9

                                    color: passwordMouse.containsMouse
                                        ? "#6f8fce"
                                        : "#5f7fba"

                                    opacity: delegateRoot.password.length > 0
                                            ? 1
                                            : 0.4

                                    Text {
                                        anchors.centerIn: parent

                                        text: "Connect"

                                        color: "white"

                                        font.pixelSize: 10
                                        font.weight: Font.DemiBold
                                    }

                                    MouseArea {
                                        id: passwordMouse

                                        anchors.fill: parent

                                        hoverEnabled: true

                                        cursorShape: Qt.PointingHandCursor

                                        enabled: delegateRoot.password.length > 0

                                        onClicked: {
                                            modelData.connectWithPsk(
                                                delegateRoot.password
                                            )
                                        }
                                    }
                                }
                            }

                            // --------------------------------------------------------
                            // DISCONNECT
                            // --------------------------------------------------------

                            Rectangle {
                                visible: modelData.connected

                                Layout.fillWidth: true
                                Layout.preferredHeight: 34

                                radius: 9

                                color: disconnectMouse.containsMouse
                                    ? "#30272a"
                                    : "#201f21"

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
                                        modelData.disconnect()
                                        delegateRoot.expanded = false
                                    }
                                }
                            }

                            // --------------------------------------------------------
                            // FORGET
                            // --------------------------------------------------------

                            Rectangle {
                                visible: modelData.known &&
                                        !modelData.connected

                                Layout.fillWidth: true
                                Layout.preferredHeight: 30

                                radius: 8

                                color: forgetMouse.containsMouse
                                    ? "#30272a"
                                    : "transparent"

                                Text {
                                    anchors.centerIn: parent

                                    text: "Forget network"

                                    color: "#a98288"

                                    font.pixelSize: 10
                                }

                                MouseArea {
                                    id: forgetMouse

                                    anchors.fill: parent

                                    hoverEnabled: true

                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        modelData.forget()
                                        delegateRoot.expanded = false
                                    }
                                }
                            }
                        }

                        // ============================================================
                        // CLICK ПО СТРОКЕ
                        // ============================================================

                        MouseArea {
                            id: networkMouse

                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                            }

                            height: 56

                            hoverEnabled: true

                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                delegateRoot.expanded =
                                    !delegateRoot.expanded

                                if (delegateRoot.expanded) {
                                    delegateRoot.password = ""
                                    delegateRoot.showPassword = false

                                    passwordField.forceActiveFocus()
                                }
                            }
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 7
                    visible: networkList.count === 0

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.wifiDevice ? "󰤪" : "󰤮"
                        color: "#5d5d65"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 29
                    }

                    Text {
                        width: 240
                        text: root.wifiDevice
                              ? "No networks found"
                              : "Wi-Fi device not found"
                        color: "#77777f"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }

function networkState(network) {
    if (!network)
        return ""

    if (network.stateChanging)
        return "Connecting..."

    if (network.connected)
        return "Connected"

    if (network.known)
        return "Saved network"

    if (network.security === WifiSecurityType.Open)
        return "Open network"

    return "Password required"
}

function signalIcon(strength) {
    if (strength >= 0.75)
        return "󰤨"
    if (strength >= 0.5)
        return "󰤥"
    if (strength >= 0.25)
        return "󰤢"
    return "󰤟"
}

function signalColor(strength) {
    if (strength >= 0.5)
        return "#8fc99f"
    if (strength >= 0.25)
        return "#e5c07b"
    return "#e06c75"
}
}
