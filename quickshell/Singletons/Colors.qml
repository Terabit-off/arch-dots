import QtQuick
pragma Singleton

QtObject {
    // Typography
    readonly property string uiFont: "JetBrainsMono Nerd Font"
    readonly property string iconFont: "JetBrainsMono Nerd Font"
    // Base
    readonly property color barBackground: "transparent"
    readonly property color foreground: "#ffffff"
    readonly property color foregroundDim: "#7e7e7e"
    readonly property color foregroundMuted: "#71717a"
    readonly property color barBorderColor: "transparent"
    readonly property color barModuleColor: "#b94b4b4b"
    readonly property color criticalColor: "#f38ba8"
    readonly property color warningColor: "#f9e2af"
    readonly property color successColor: "#86efac"
    readonly property color weekendColor: "#ffd6d6"
    // Common surfaces / states
    readonly property color surface: "#d31c1c1c"
    readonly property color surfaceElevated: "#6f151515"
    readonly property color surfaceInput: "#27272a"
    readonly property color surfaceSelected: "#3f3f46"
    readonly property color surfaceHover: "#1affffff"
    readonly property color surfaceActive: "#33ffffff"
    readonly property color border: "#db6e6e6e"
    readonly property color borderSubtle: "#35ffffff"
    readonly property color separator: "#18ffffff"
    // Buttons
    readonly property color buttonBackgroundColor: "transparent"
    readonly property color buttonBackgroundColorHover: surfaceHover
    readonly property color activeButtonBackgroundColor: surfaceActive
    // Left side --- WorkSpace
    readonly property color wsUrgentForeground: "#cecbcb"
    readonly property color wsFocusForeground: "#ffffff"
    readonly property color wsNotFocusForeground: "#7e7e7e"
    readonly property color wsFocusBackground: "#92323232"
    readonly property color wsUrgentBackground: "#93a37171"
    readonly property color wsNotFocusBackground: "transparent"
    readonly property color separatorColor: "#bd939393"
    // Menus
    readonly property color menuBackground: "#e61c1c1c"
    readonly property color menuBackgroundElevated: "#ef232326"
    readonly property color menuBorderColor: border
    readonly property real menuBorderRadius: 10
    readonly property real menuPadding: 14
    readonly property real menuSectionSpacing: 10
    readonly property real controlRadius: 9
    readonly property real cardRadius: 10
    readonly property color menuHeaderBackground: "#12ffffff"
    readonly property color controlHover: "#24ffffff"
    readonly property color controlActive: "#36ffffff"
    readonly property color controlBorder: "#24ffffff"
    readonly property color controlBorderHover: "#48ffffff"
    readonly property color textSecondary: "#a1a1aa"
    readonly property color textTertiary: "#71717a"
    readonly property color successSubtle: "#2486efac"
    readonly property color warningSubtle: "#24f9e2af"
    readonly property color dangerSubtle: "#24f38ba8"
    // Sliders
    readonly property color sliderBackgroundColor: "#494949"
    readonly property color sliderBackgroundFillColor: "#e9e9e9"
    readonly property color sliderHandlerColor: "#f0f0f0"
    readonly property color sliderHandlerBorderColor: "#bd939393"
    readonly property real sliderHandlerBorderRadius: 2
    // Notification
    readonly property color notifiCardBackground: "#f11c1c1c"
    readonly property color notifiCardCriticalBackground: "#422529"
    readonly property color notifiCardBorderBackground: "#db6e6e6e"
    readonly property color notifiCardHoverBorderBackground: "#ffffff"
    // Overview / Cards
    readonly property color overviewBackground: "#be1c1c1c"
    readonly property color overviewCardBackground: "#262626"
    readonly property color overviewCardHoverBackground: "#494949"
    readonly property color overviewCardBorder: "#3d3d3d"
    readonly property color overviewCardHoverBorder: "#db6e6e6e"
    readonly property real overviewBorderRadius: 10
    // Dock
    readonly property color dockAccent: foreground
    readonly property color dockAccentDim: "#68ffffff"
    readonly property color dockPopupBackground: surfaceElevated
    readonly property color dockWindowBackground: "#12ffffff"
    readonly property color dockWindowHoverBackground: "#35ffffff"
    readonly property color dockWindowCurrentBackground: "#25ffffff"
    readonly property color dockWindowBorder: "#18ffffff"
    readonly property color dockWindowHoverBorder: "#55ffffff"
    readonly property color dockWindowCurrentBorder: "#40ffffff"
    readonly property color dockSeparator: "#18ffffff"
}
