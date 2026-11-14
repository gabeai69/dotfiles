pragma Singleton
import qs.modules.common
import QtQuick
import Quickshell

/**
 * "Keep system awake" toggle.
 *
 * Hyprland ignores Wayland idle inhibitors on layer surfaces, so the original
 * IdleInhibitor-based approach never worked. Instead, this stops hypridle while
 * the toggle is on and starts it again when it is turned off.
 */
Singleton {
    id: root

    property bool inhibit: false

    Connections {
        target: Persistent
        function onReadyChanged() {
            root.inhibit = Persistent.states.idle.inhibit;
            root.apply();
        }
    }

    function toggleInhibit(active = null) {
        if (active !== null) {
            root.inhibit = active;
        } else {
            root.inhibit = !root.inhibit;
        }
        Persistent.states.idle.inhibit = root.inhibit;
    }

    function apply() {
        if (root.inhibit)
            Quickshell.execDetached(["pkill", "-x", "hypridle"]);
        else
            Quickshell.execDetached(["bash", "-c", "pidof hypridle >/dev/null || setsid -f hypridle >/dev/null 2>&1"]);
    }

    onInhibitChanged: apply()

    // hypridle is started at login by Hyprland and restarted by the Idle settings
    // page, so keep it stopped while the toggle is on.
    Timer {
        running: root.inhibit
        repeat: true
        interval: 5000
        onTriggered: root.apply()
    }
}
