pragma Singleton

import QtQuick

QtObject {

    // Right side
    readonly property color barBackground: '#00202020'//'#cf595959'
    readonly property color foreground: '#c9c9c9'
    readonly property color barBorderColor: '#00939393'
    readonly property real trayIconColor: 0.5415 
    readonly property real trayIconSaturation: 0

    // Left side --- WorkSpace
    readonly property color wsFocusBackground: '#c9c9c9'
    readonly property color wsNotFocusBackground: 'transparent'
    readonly property color wsUrgentBackground: '#6d8b3f3f'

    readonly property color wsUrgentForeground: '#c9c9c9'
    readonly property color wsFocusForeground: '#222e34'
    readonly property color wsNotFocusForeground: '#c9c9c9'

    // Center --- Music




    //Panel
    readonly property color panelBackground: 'transparent'//'#bd202020'
    readonly property color separatorColor: 'transparent'//'#bd939393'
    readonly property color moduleSeparatorColor: '#bd939393'
    readonly property color moduleBorderColor: '#bde6e6e6'
    readonly property color moduleBackgroundColor: '#202020'
    readonly property real moduleBorderRadius: 15
    readonly property real panelBorderRadius: 15

    // sliders
    readonly property color sliderBackgroundColor: '#494949'
    readonly property color sliderBackgroundFillColor: '#e9e9e9'
    readonly property color sliderHandlerColor:'#f0f0f0'
    readonly property color sliderHandlerBorderColor: '#bd939393'
    readonly property real sliderHandlerBorderRadius: 2

    // Buttons
    readonly property color buttonOffBackground: 'transparent'
    readonly property color buttonOnBackground: '#ffffff'
    readonly property color buttonBorderColor: '#bd939393'
    readonly property color buttonOffHoverColor: '#373737'
    readonly property color buttonOnHoverColor: '#707070'
    readonly property real buttonBorderWidth: 2

    readonly property color buttonOnTextColor: '#2c2c2c'
    readonly property color buttonOffTextColor: '#c9c9c9'

    // Notification
    readonly property color notifyCardBackground: '#161616'



}



    //ROSE WALLPAPER

    // readonly property color barBackground: '#7d595959'
    // readonly property color foreground: '#7DB0C1'
    // readonly property real trayIconColor: 0.5415 
    //readonly property real trayIconSaturation: 1

    // readonly property color wsFocusBackground: '#7DB0C1'
    // readonly property color wsNotFocusBackground: 'transparent'
    // readonly property color wsUrgentBackground: 'transparent'

    // readonly property color wsUrgentForeground: 'transparent'
    // readonly property color wsFocusForeground: '#222e34'
    // readonly property color wsNotFocusForeground: '#7DB0C1'