pragma Singleton

import QtQuick

QtObject {

    readonly property color barBackground: 'transparent'
    readonly property color foreground: '#ffffff'
    readonly property color foregroundDim: '#7e7e7e'
    readonly property color barBorderColor: 'transparent'
    readonly property color barModuleColor: '#634b4b4b'

    readonly property color criticalColor: '#f38ba8'

    readonly property color buttonBackgroundColor: "transparent"
    readonly property color buttonBackgroundColorHover: "#1affffff"
    readonly property color activeButtonBackgroundColor: "#33ffffff"

    // Left side --- WorkSpace
    readonly property color wsUrgentForeground: '#cecbcb'
    readonly property color wsFocusForeground: '#ffffff'
    readonly property color wsNotFocusForeground: '#7e7e7e' 
    
    readonly property color wsFocusBackground: '#92323232'
    readonly property color wsUrgentBackground: '#93a37171'
    readonly property color wsNotFocusBackground: 'transparent'


    // Menus 
    readonly property color menuBackground: '#ba1c1c1c'
    readonly property color separatorColor: '#bd939393'
    readonly property color menuBorderColor: '#db6e6e6e'
    readonly property real menuBorderRadius: 5

    // sliders
    readonly property color sliderBackgroundColor: '#494949'
    readonly property color sliderBackgroundFillColor: '#e9e9e9'
    readonly property color sliderHandlerColor:'#f0f0f0'
    readonly property color sliderHandlerBorderColor: '#bd939393'
    readonly property real sliderHandlerBorderRadius: 2

    // Notification
    readonly property color notifiCardBackground: '#f11c1c1c'
    readonly property color notifiCardCriticalBackground: '#422529'

    readonly property color notifiCardBorderBackground: '#db6e6e6e'
    readonly property color notifiCardHoverBorderBackground: '#ffffff'

    // Overview / Cards
    readonly property color overviewBackground: '#be1c1c1c'
    readonly property color overviewCardBackground: '#262626'
    readonly property color overviewCardHoverBackground: '#494949'
    readonly property color overviewCardBorder: '#3d3d3d'
    readonly property color overviewCardHoverBorder: '#db6e6e6e'
    readonly property real overviewBorderRadius: 10
}