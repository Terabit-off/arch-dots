//@ pragma UseQApplication
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick.Controls



PanelWindow {
    id: rootPanel
    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        left: 55
        right: 55
        top: 5
    }
    implicitHeight: 30

    property alias brightnessUpdateProcess: brightnessProcess
    
    //Colors.qml
    Colors {
        id: colors
    }
    MediaCenterWindow {
        id: mediaCenter
    }
    
    color: 'transparent'

    MouseArea {
        anchors.fill: parent
        onClicked: {
            mediaCenter.visible = true
            
        }
    }

    Rectangle {
        anchors.fill: parent
        color: colors.barBackground
        border.color: colors.barBorderColor
        radius: 25
        RowLayout {
            anchors.fill: parent
            anchors {
                leftMargin: 10
            }
            
            spacing: 12
        
            //LEFT
            Rectangle { 
                color: 'transparent'
                Layout.fillWidth: true
                Layout.minimumWidth: 10
                Layout.preferredWidth: 50
                Layout.maximumWidth: 700
                height: 24

                //Workspaces
                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    


                    Repeater {
                        model: Hyprland.workspaces

                        delegate: Rectangle {
                            width: modelData.focused ? 30 : 25
                            height: 20
                            radius: modelData.focused ? 8 : modelData.urgent ? 8 : 0

                            Behavior on color {
                                ColorAnimation { duration: 250 }
                            }
                            Behavior on radius {
                                NumberAnimation { duration: 250 }
                            }
                            Behavior on width {
                                NumberAnimation { duration: 250 }
                            }

                            color: modelData.focused ? colors.wsFocusBackground :
                                    modelData.urgent ? colors.wsUrgentBackground : colors.wsNotFocusBackground

                            Text {
                                anchors.centerIn: parent
                                text: modelData.id
                                color: modelData.focused
                                    ? colors.wsFocusForeground
                                    : colors.wsNotFocusForeground
                                font.bold: true
                                font.pixelSize: 14
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (modelData) {
                                        modelData.activate()
                                    }
                                }
                            }
                        }
                    }
                }

            }

            //CENTER
            Rectangle {
                id: centerSec
                color: 'transparent'
                Layout.fillWidth: true
                Layout.minimumWidth: 10
                Layout.preferredWidth: 50
                Layout.maximumWidth: 300
                height: 24
                
                MusicWidget { }
            }

            //RIGHT
            Rectangle {
                color: 'transparent'
                Layout.fillWidth: true
                Layout.minimumWidth: 10
                Layout.preferredWidth: 50
                Layout.maximumWidth: 700
                height: 24

                RowLayout {
                    anchors {
                        right: parent.right
                    }
                    spacing: 5

                    //TRAY
                    Rectangle {
                        color: 'transparent'
                        Layout.fillWidth: true
                        Layout.minimumWidth: 50
                        Layout.maximumWidth: 50
                        height: 24
                        RowLayout {
                            id: trayLayout
                            layoutDirection: Qt.RightToLeft
                            spacing: 5
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                rightMargin: 5
                            }

                            Repeater {
                                model: SystemTray.items
                                anchors {
                                }
                                delegate: Item {
                                    id: itemParent
                                    width: 14
                                    height: 14
                                    readonly property var item: modelData
                                    
                                    Image {
                                        id: iconImage
                                        anchors.fill: parent
                                        source: itemParent.item.icon
                                        fillMode: Image.PreserveAspectFit
                                        visible: false
                                    }
                                    Colorize {
                                        anchors.fill: iconImage
                                        source: iconImage
                                        hue: colors.trayIconColor
                                        saturation: colors.trayIconSaturation
                                        lightness: -0.2

                                        QsMenuAnchor {
                                            id: contextMenu
                                            menu: item.menu
                                            anchor {
                                                window: rootPanel
                                                margins {
                                                    left: 1050
                                                    top: 25
                                                }
                                            }
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                                            onClicked: (mouse) => {
                                                if (mouse.button === Qt.LeftButton) {
                                                    item.activate();
                                                } else if(mouse.button === Qt.RightButton){
                                                    contextMenu.open()
                                                }
                                            }
                                        
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Bluetooth
                    Rectangle {
                        color: 'transparent'
                        Layout.fillWidth: true
                        Layout.minimumWidth: 25
                        Layout.maximumWidth: 50
                        height: 24
                        Text {
                            id: bluetoothText
                            anchors.centerIn: parent
                            text: "󰂯" // 󰂲
                            font.pixelSize: 17
                            color: colors.foreground
                        }
                    }

                    //Wi-Fi
                    Rectangle {
                        color: 'transparent'
                        Layout.fillWidth: true
                        Layout.minimumWidth: 25
                        Layout.maximumWidth: 50
                        height: 24


                        Process {
                            id: wifiProcess
                            command: ["nmcli", "-t", "-f", "active", "dev", "wifi"]
                            running: true
                            
                            stdout: StdioCollector {

                                onStreamFinished: {
                                    if (this.text.startsWith("yes")) {
                                        wifiText.text = "󰖩"
                                    } else {
                                        wifiText.text = "󰖪"
                                    }
                                }
                            }
                        }

                        Text {
                            id: wifiText
                            anchors.centerIn: parent
                            text: "󰖪"//"󰖩"
                            font.pixelSize: 15
                            color: colors.foreground
                        }
                    }

                    //Brightness
                    Rectangle {
                        id: brightness
                        color: 'transparent'
                        Layout.fillWidth: true
                        Layout.minimumWidth: 50
                        Layout.maximumWidth: 50
                        height: 24

                        property int currentBrightness: 0
                        Process {
                            id: brightnessProcess
                            running: true
                            command: ["brightnessctl", "g"]
                            
                            stdout: StdioCollector {
                                onStreamFinished: brightness.currentBrightness = parseInt(this.text.trim())
                            }
                        }
                        Process {
                            id: brightnessDown
                            command: ["brightnessctl", "s", "5%-"]
                            
                            stdout: StdioCollector {
                                onStreamFinished: brightnessProcess.running = true
                            }
                        }
                        Process {
                            id: brightnessUp
                            command: ["brightnessctl", "s", "+5%"]
                            
                            stdout: StdioCollector {
                                onStreamFinished: brightnessProcess.running = true
                            }
                        }

                        Text {
                            
                            anchors.centerIn: parent
                            text: "󰃠  " + Math.round(brightness.currentBrightness / 64507 * 100)
                            font.bold: true
                            font.pixelSize: 14
                            color: colors.foreground
                        }

                        MouseArea {
                            anchors.fill: parent
                            onWheel: (wheel) => {
                                if (wheel.angleDelta.y > 0) {
                                    brightnessUp.running = true
                                } else {
                                    brightnessDown.running = true
                                }
                            }
                        }
                    }
                    //Volume
                    Rectangle {
                        color: 'transparent'
                        Layout.fillWidth: true
                        Layout.minimumWidth: 50
                        Layout.maximumWidth: 50
                        height: 24

                        PwObjectTracker {
                            id: audioTracker
                            objects: [Pipewire.defaultAudioSink]
                        }
                        property PwNode sink: Pipewire.defaultAudioSink
                        Text {
                            anchors.centerIn: parent
                            property var icon: {
                                if(parent.sink.audio.muted) return "󰝟"
                                return "󰕾"
                            }
                            text: parent.sink.audio.muted ? "󰝟  0" :  "󰕾  "+ Math.round(parent.sink.audio.volume * 100)
                            color:colors.foreground
                            font.pixelSize: 14
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            scrollGestureEnabled: true
                            onClicked: {
                                if (parent.sink) {
                                    // Инвертируем текущее состояние mute
                                    parent.sink.audio.muted = !parent.sink.audio.muted;
                                }
                            }

                            onWheel: (wheel) => {
                                if (parent.sink) {
                                    // Определяем шаг изменения (например, 5%)
                                    let step = 0.05;
                                    
                                    if (wheel.angleDelta.y > 0) {
                                        // Крутим вверх - прибавляем (но не выше 1.0)
                                        parent.sink.audio.volume = Math.min(parent.sink.audio.volume + step, 1.0);
                                    } else {
                                        // Крутим вниз - убавляем (но не ниже 0.0)
                                        parent.sink.audio.volume = Math.max(parent.sink.audio.volume - step, 0.0);
                                    }
                                }
                            }
                        }
                    }
                    // Battery
                    Rectangle {
                        color: 'transparent'
                        Layout.fillWidth: true
                        Layout.minimumWidth: 50
                        Layout.maximumWidth: 50
                        height: 24

                        readonly property var battery: UPower.displayDevice

                        Text {
                            id: batteryText
                            anchors.centerIn: parent

                            property var icon: {
                                if (parent.battery.state === UPowerDevice.Charging) return "󰂄";
                                if (parent.battery.percentage * 100>= 90) return "󰁹";
                                if (parent.battery.percentage * 100>= 50) return "󰁾";
                                if (parent.battery.percentage * 100 >= 20) return "󰁼";
                                return "󰂃";
                            }
                            color: colors.foreground
                            text: parent.battery ? icon + " " + Math.round(parent.battery.percentage * 100) + "%" : "--%"
                            font.bold: true
                            font.pixelSize: 14
                        }
                    
                    }
                    //Time
                    Rectangle {
                        color: 'transparent'
                        Layout.fillWidth: true
                        Layout.minimumWidth: 70
                        Layout.maximumWidth: 70
                        height: 24

                        Text {
                            id: timeText
                            anchors.centerIn: parent
                            text: Qt.formatDateTime(new Date(), "hh:mm")
                            color: colors.foreground
                            font.bold: true
                            font.pixelSize: 16
                        }
                        
                        
                    }

                    Timer {
                        interval: 10000  // каждые 10 сек
                        running: true
                        repeat: true
                        onTriggered: {
                            timeText.text = Qt.formatDateTime(new Date(), "HH:mm");
                            mediaCenter.updateTimeDate()
                            wifiProcess.running = true
                        }
                    }
                }
            }
        }
    }
}