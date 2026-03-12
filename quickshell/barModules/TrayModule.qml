import Quickshell.Services.SystemTray
import Qt5Compat.GraphicalEffects
import Quickshell
import QtQuick
import QtQuick.Layouts

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
                        cursorShape: Qt.PointingHandCursor
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