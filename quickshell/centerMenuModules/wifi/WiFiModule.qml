import Quickshell.Io
import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls

import "../../Singletons" as Singletons

Rectangle {
    property bool opened: false
    property bool wifiActive: false
    property var networks: []
    property bool passError: false


    Layout.fillWidth: true
    //Layout.fillHeight: true
    implicitHeight: {
        if (opened){
            const s = 60 + lsV.contentHeight;
            if (400 < s) return 400;
            return s;
        }
        return 35;
    }
    clip: true
    radius: Singletons.Colors.moduleBorderRadius
    color: Singletons.Colors.moduleBackgroundColor
    border.color: Singletons.Colors.moduleBorderColor

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 220
            easing.type: Easing.InOutCubic
        }
    }


    property alias wifiUpdateProcess: wifiIsEnabled
    property alias loadingAnim: loadingText

    Process {
        id: wifiIsEnabled
        command: ["nmcli", "radio", "wifi"]
        running: true
        
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.startsWith("enabled")) {
                    wifiActive = true;
                    getWifiList.running = true;
                } else {
                    wifiActive = false;
                    loadingAnim.running = false
                }
            }
        }
    }
    Process {
        id: enableControl
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text === ""){
                    errorText.visible = false;
                    wifiActive = !wifiActive;
                }
                else {
                    errorText.visible = true
                }

            }
        }
    }
    Process {
        id: getWifiList
        command: ["sh", Quickshell.shellDir + "/centerMenuModules/wifi/wifi-list.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (wifiActive)
                    parseNetworks(this.text)

                loadingAnim.running = false
            }
        }
    }
    Process {
        id: setConnectProp
    }
    Process {
        id: setConnections

        onExited: function(exitCode) {
            if (exitCode === 0) {
                getWifiList.running = true
                return
            }

            passError = true
            errorTimer.restart()
        }
    }

    Timer {
        id: errorTimer
        interval: 5000
        running: passError
        onTriggered: {
            passError = false
        }
    }

    

    function parseNetworks(raw) {
        let result = []
        let lines = raw.trim().split("\n")

        for (let i = 0; i < lines.length; ++i) {
            let line = lines[i].trim()
            if (!line)
                continue

            let parts = line.split(":")
            if (parts.length < 6)
                continue

            result.push({
                active: parts[0], // is connected ?
                known: parts[1], // open/known/locked
                ssid: parts[2], // name
                signal: Number(parts[3]), // strength
                security: parts[4], // WPA2
                autoconnect: parts[5] // yes/no
            })
        }

        networks = result
        // like-  yes:known:my:96:WPA2:yes
    }
    
    ColumnLayout {
        anchors.fill: parent

        //HEADER
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 10
            Layout.topMargin: 10
            Layout.rightMargin: 10
            Layout.maximumHeight: 10
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: "WiFi "
                color: Singletons.Colors.foreground
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 12
                font.bold: true

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        opened = !opened;
                        parent.text = opened ? "WiFi " : "WiFi "
                    }
                }
                
            }
            Text {
                id: errorText
                text: "ERROR"
                color: Singletons.Colors.foreground
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 12
                font.bold: true
                visible: false
            } 

            Item { Layout.fillWidth: true }

            Text {
                text: "󰑓"
                color: Singletons.Colors.foreground
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 13
                font.bold: true

                RotationAnimation on rotation {
                    id: loadingText
                    to: 360
                    duration: 2000
                    loops: Animation.Infinite
                    direction: RotationAnimation.Clockwise
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!wifiActive) return;
                        loadingAnim.running = true
                        getWifiList.running = true
                    }
                }
            } 

            // Toggle Wi-Fi
            Rectangle {
                width: 21
                height: 11
                radius: 8
                color: wifiActive ? Singletons.Colors.toggleOnBackground : Singletons.Colors.toggleOffBackground

                Rectangle {
                    width: 9
                    height: 9
                    radius: 9
                    anchors.verticalCenter: parent.verticalCenter
                    x: wifiActive ? 11 : 0
                    color: wifiActive ? '#000000' : '#cccccc'
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (wifiActive){
                            enableControl.command = ["nmcli", "radio", "wifi", "off"];
                        }
                        else{
                            enableControl.command = ["nmcli", "radio", "wifi", "on"];
                        }
                        enableControl.running = true;
                        loadingAnim.running = true;
                    }
                }
            }
        }

        //DEVICES LIST
        ListView {
            id: lsV
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 5
            Layout.margins: 10

            model: networks

            property int openedIndex: -1

            delegate: Rectangle {
                id: parentRoot
                property bool isopen: index === lsV.openedIndex

                width: 226
                height: {
                    if (isopen) {
                        if (modelData.known === "locked"){
                            return 148
                        } 
                        else {
                            return 118
                        }
                    }
                    else {
                        // close
                        return 42
                    }
                }
                radius: 10
                clip: true
                color: modelData.active == "yes" ? Singletons.Colors.buttonOnBackground : Singletons.Colors.buttonOffBackground
                border.color: Singletons.Colors.buttonBorderColor


                Behavior on height {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.InOutCubic
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    // HEADER
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.maximumHeight: 42
                        Layout.minimumHeight: 42
                        color: 'transparent'

                        RowLayout {
                            anchors.fill: parent
                            spacing: 10
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 120

                                Text {
                                    text: modelData.ssid || "Unknown device"
                                    color: Singletons.Colors.foreground
                                    elide: Text.ElideRight
                                    font.pixelSize: 11
                                }

                                Text {
                                    text: modelData.active == "yes" ? "connected" : ""
                                    visible: text !== ""
                                    color: "#aaa"
                                    font.pixelSize: 11
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                            Text {
                                text: modelData.security + "\n" + modelData.signal+"%"
                                color: Singletons.Colors.foreground
                                font.pixelSize: 11
                            }
                            Text {
                                text: isopen ? "" : ""
                                color: Singletons.Colors.foreground
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (lsV.openedIndex !== index) {
                                    //open
                                    lsV.openedIndex = index
                                } else {
                                    // close
                                    lsV.openedIndex = -1
                                }
                            }
                        }
                    }

                    // SEPARATOR
                    Rectangle {
                        height: 1
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: 'transparent'

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.bottomMargin: 10
                            
                            TextField {
                                // height = 10
                                id: passwordField


                                visible: modelData.known === "locked"
                                Layout.fillWidth: true
                                placeholderText: "password"
                                echoMode: TextInput.Password
                                placeholderTextColor: Singletons.Colors.foreground
                                color: Singletons.Colors.foreground
                                font.pixelSize: 11
                                leftPadding: 12
                                rightPadding: 12

                                background: Rectangle {
                                    implicitWidth: parent.width
                                    implicitHeight: parent.height
                                    radius: 8
                                    color: Singletons.Colors.moduleBackgroundColor
                                    border.width: 1
                                    border.color: activeFocus ? '#8fd3ff' : passError ?'#bb4848' : Singletons.Colors.buttonBorderColor
                                }

                                SequentialAnimation on x {
                                    running: passError
                                    loops: 1

                                    NumberAnimation { to: passwordField.x - 5; duration: 40 }
                                    NumberAnimation { to: passwordField.x + 5; duration: 40 }
                                    NumberAnimation { to: passwordField.x; duration: 40 }
                                }

                                onPressed: {
                                    passError = false
                                }
                            }

                            CheckBox {
                                checked: modelData.autoconnect === "yes" ? true : false
                                indicator: Rectangle {
                                    implicitWidth: 15
                                    implicitHeight: 15
                                    x: parent.leftPadding
                                    y: parent.height / 2 - height / 2
                                    radius: 4
                                    border.width: 1
                                    border.color: parent.checked ? "#4da3ff" : "#6b7280"
                                    color: "#1f2430"

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 7
                                        height: 7
                                        radius: 2
                                        visible: parent.parent.checked
                                        color: "#4da3ff"
                                    }
                                }
                                contentItem: Text {
                                    text: "Autoconnect"
                                    color: Singletons.Colors.foreground
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: parent.indicator.width + parent.spacing
                                    font.pixelSize: 11

                                }
                                onToggled: {
                                    setConnectProp.command = ["nmcli", "connection", "modify", modelData.ssid, "connection.autoconnect", checked ? "yes" : "no"]
                                    setConnectProp.running = true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.maximumHeight: 25
                                    Layout.maximumWidth: 80
                                    Layout.minimumWidth: 80
                                    radius: 5
                                    border.color: Singletons.Colors.buttonBorderColor
                                    color: Singletons.Colors.moduleBackgroundColor
                                    visible: modelData.known === "known"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Forget"
                                        color: Singletons.Colors.foreground
                                        font.pixelSize: 11
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            setConnections.command = ["nmcli", "connection", "delete", modelData.ssid]
                                            setConnections.running = true
                                        }
                                    }
                                }
                                Item {
                                    Layout.fillWidth: true
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.maximumHeight: 25
                                    Layout.maximumWidth: 80
                                    Layout.minimumWidth: 80
                                    radius: 5
                                    border.color: Singletons.Colors.buttonBorderColor
                                    color: Singletons.Colors.moduleBackgroundColor

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.active === "yes" ? "Disconnect" : "Connect"
                                        color: Singletons.Colors.foreground
                                        font.pixelSize: 11
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if(modelData.active === "yes") {
                                                if (modelData.security === "open") 
                                                    setConnections.command = ["nmcli", "device", "wifi", "connect", modelData.ssid];
                                                else {
                                                    setConnections.command = ["nmcli", "device", "wifi", "connect", modelData.ssid, "password", passwordField.text];
                                                }
                                            }
                                            else {
                                                setConnections.command = ["nmcli", "connection", "down", "id", modelData.ssid]
                                            }
                                            setConnections.running = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }    
        }
    }
}