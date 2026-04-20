import Quickshell.Services.SystemTray
import Qt5Compat.GraphicalEffects
import Quickshell
import QtQuick
import QtQuick.Layouts


import "../../Singletons" as Singletons

Rectangle {
    color: 'transparent'
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumWidth: 21 * SystemTray.items.values.length
    Layout.maximumWidth: 21 * SystemTray.items.values.length
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
                        item: itemParent
                        rect.x: itemParent.x
                        rect.y: itemParent.y + itemParent.height
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