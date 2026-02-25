import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import "timezone-utils.js" as TimezoneUtils

PluginComponent {
    id: root

    property var timezones: []
    property var pluginService: null
    property bool isLoading: true
    property bool iconOnly: false
    property bool use12h: false 

    function loadTimezones() {
        if (pluginService && pluginService.loadPluginData) {
            var saved = pluginService.loadPluginData("worldClock", "timezones", []);
            timezones = (saved && Array.isArray(saved)) ? saved : [];
            iconOnly = pluginService.loadPluginData("worldClock", "iconOnly", false) === true;
            use12h = pluginService.loadPluginData("worldClock", "use12h", false) === true;
            isLoading = false;
        }
    }

    Component.onCompleted: {
        loadTimezones();
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.loadTimezones()
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            StyledText {
                text: "\u{1F310}\uFE0E"
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
                visible: root.iconOnly
            }

            Repeater {
                model: root.iconOnly ? [] : root.timezones
                StyledText {
                    text: {
                        if (!systemClock || !systemClock.date) return "...";
                        var label = (modelData && modelData.label) ? modelData.label : modelData.timezone.split('/').pop().replace(/_/g, ' ');
                        var fmt = root.use12h ? "hh:mm A, MMM Do" : "HH:mm, MMM Do";
                        var time = TimezoneUtils.getTimeInTimezone(modelData.timezone, fmt);
                        return label + " " + time;
                    }
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    popoutContent: Component {
        Column {
            spacing: Theme.spacingL
            StyledText {
                text: "World Clock"
                font.pixelSize: Theme.fontSizeXLarge
                font.weight: Font.Bold
                color: Theme.surfaceText
            }
            Column {
                width: parent.width
                spacing: Theme.spacingS
                Repeater {
                    model: root.timezones
                    StyledRect {
                        width: parent.width
                        height: 60
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerHigh
                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingL
                            anchors.verticalCenter: parent.verticalCenter
                            StyledText {
                                text: (modelData && modelData.label) ? modelData.label : modelData.timezone.split('/').pop().replace(/_/g, ' ')
                                color: Theme.surfaceText
                                font.pixelSize: Theme.fontSizeLarge
                            }
                            StyledText {
                                text: {
                                    if (!systemClock || !systemClock.date) return "Loading...";
                                    var fmt = root.use12h ? "hh:mm A, MMM Do" : "HH:mm, MMM Do";
                                    return TimezoneUtils.getTimeInTimezone(modelData.timezone, fmt);
                                }
                                color: Theme.surfaceVariantText
                                font.pixelSize: Theme.fontSizeMedium
                            }
                        }
                    }
                }
            }
        }
    }

    popoutWidth: 360
    popoutHeight: 400
}
