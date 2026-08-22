import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: overviewWindow

    // Скрываем окно по умолчанию
    visible: false

    // Размещение поверх всех окон
    WlrLayers.layer: WlrLayers.Overlay
    
    // Захват клавиатуры для быстрого закрытия по Esc
    WlrKeyboardFocus.policy: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Центрирование: если anchor'ы не привязаны к краям, PanelWindow выравнивается по центру
    width: 900
    height: 600

    // IPC обработчик для внешней активации
    IpcHandler {
        target: "overview"

        function open() {
            overviewWindow.visible = true;
        }

        function close() {
            overviewWindow.visible = false;
        }

        function toggle() {
            overviewWindow.visible = !overviewWindow.visible;
        }
    }

    // Закрытие по нажатию Esc
    Shortcut {
        sequence: "Escape"
        onActivated: overviewWindow.visible = false
    }

    // Внешний контейнер обзора
    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e" // Dark Theme (Catppuccin Mocha)
        radius: 16
        border.color: "#89b4fa"
        border.width: 2

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Заголовок
            Text {
                text: "Открытые окна"
                color: "#cdd6f4"
                font.pixelSize: 20
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            // Сетка открытых окон
            GridView {
                id: windowGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                cellWidth: 260
                cellHeight: 160

                // Подключаем менеджер окон Wayland
                model: ToplevelManager.toplevels

                delegate: Rectangle {
                    required property var modelData

                    width: windowGrid.cellWidth - 15
                    height: windowGrid.cellHeight - 15
                    color: mouseArea.containsMouse ? "#45475a" : "#313244"
                    radius: 10
                    border.color: mouseArea.containsMouse ? "#89b4fa" : "transparent"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        // Иконка / Имя приложения
                        Text {
                            text: modelData.appId !== "" ? modelData.appId : "Приложение"
                            color: "#89b4fa"
                            font.bold: true
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        // Заголовок окна
                        Text {
                            text: modelData.title !== "" ? modelData.title : "Без названия"
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            // Переносим фокус на выбранное окно и закрываем обзор
                            modelData.activate();
                            overviewWindow.visible = false;
                        }
                    }
                }
            }
        }
    }
}