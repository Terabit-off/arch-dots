import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root
    property Item anchorItem
    visible: false
    grabFocus: true
    implicitWidth: 290
    implicitHeight: 300
    color: "transparent"
    
    anchor {
        item: anchorItem
        edges: Edges.Bottom
        gravity: Edges.Bottom
        margins.top: 25
    }

    // Компонент для удобного запуска консольных утилит
    Component {
        id: scriptRunner
        Process {
            id: proc
            //onFinished: (exitCode) => { proc.destroy(); }
        }
    }

    function runCmd(cmd) {
        var p = scriptRunner.createObject(root);
        p.command = ["sh", "-c", cmd];
        p.start();
        root.visible = false; // Закрываем панель после клика
    }

    // Задний фон панели с размытием или полупрозрачностью
    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e" // Тёмная тема (Catppuccin Mocha)
        radius: 12
        border.color: "#313244"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12

            // Заголовок панели
            Text {
                text: "Панель инструментов"
                color: "#cdd6f4"
                font.pointSize: 12
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            // Сетка с инструментами
            GridLayout {
                columns: 2
                Layout.fillWidth: true
                Layout.fillHeight: true

                // --- СКРИНШОТЫ ---
                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: "📸 Снимок области"
                    onClicked: {
                        // Используем grim + slurp для Wayland (Hyprland/Sway). 
                        // Если у вас X11, замените на: "maim -s | xclip -selection clipboard -t image/png"
                        root.runCmd("grim -g \"$(slurp)\" - | wl-copy");
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: "🖥️ Весь экран"
                    onClicked: {
                        // Для Wayland. Для X11: "maim | xclip -selection clipboard -t image/png"
                        root.runCmd("grim - | wl-copy");
                    }
                }

                // --- СИСТЕМНЫЕ УТИЛИТЫ ---
                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: "🧪 Пипетка (Цвет)"
                    onClicked: {
                        // hyprpicker для Wayland. Для X11 можно xcolor
                        root.runCmd("hyprpicker -a");
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: "📹 Запись экрана"
                    onClicked: {
                        // Запуск простейшего регионального рекордера (нужен wf-recorder)
                        root.runCmd("wf-recorder -g \"$(slurp)\" -f ~/Видео/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4");
                    }
                }

                // --- ДОПОЛНИТЕЛЬНО ---
                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: "📋 Буфер (Cliphist)"
                    onClicked: {
                        // Вызов меню истории буфера обмена через rofi/wofi
                        root.runCmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy");
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: "🔒 Заблокировать"
                    onClicked: {
                        // Замена на ваш экран блокировки (hyprlock, swaylock, i3lock)
                        root.runCmd("hyprlock");
                    }
                }
            }

            // Кнопка закрытия панели
            Button {
                text: "Закрыть"
                Layout.fillWidth: true
                onClicked: root.visible = false
                
                background: Rectangle {
                    color: parent.hovered ? "#f38ba8" : "#313244"
                    radius: 6
                }
                contentItem: Text {
                    text: parent.text
                    color: parent.hovered ? "#11111b" : "#cdd6f4"
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                }
            }
        }
    }
}
