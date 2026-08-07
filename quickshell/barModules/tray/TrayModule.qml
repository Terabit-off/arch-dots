import Quickshell.Services.SystemTray
import Qt5Compat.GraphicalEffects
import Quickshell
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    color: '#4b4b4b4b'
    radius: 5
    Layout.fillHeight: true
    visible: SystemTray.items.values.length > 0
    implicitWidth: trayLayout.implicitWidth + 10

    RowLayout {
        id: trayLayout
        layoutDirection: Qt.LeftToRight
        spacing: 5
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 5
        }

        Repeater {
            model: SystemTray.items
            delegate: Item {
                id: itemParent
                width: 15
                height: 13
                
                Image {
                    id: iconImage
                    anchors.fill: parent
                    source: modelData.icon
                    fillMode: Image.PreserveAspectFit
                    visible: true
                }

                QsMenuAnchor {
                    id: contextMenu
                    menu: modelData.menu
                    anchor {
                        window: rootPanel
                        item: root
                        rect.x: root.x
                        rect.y: root.y + root.height + 5
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            modelData.activate();
                        } else if(mouse.button === Qt.RightButton){
                            contextMenu.open()
                        }
                    }
                }
            }
        }
    }
}