import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

// Bar widget for Proton VPN: shows connected/disconnected state via the
// shield icon's color/fill, and opens a small popup with a connect/disconnect
// button on click. Status comes from the same signal the toggle keybind
// (SUPER+SHIFT+V -> omarchy-protonvpn-toggle) uses: the "proton0" WireGuard
// interface nmcli reports for the official Proton VPN Linux client.
Panel {
  id: root
  moduleName: "mrrobot.protonvpn"
  ipcTarget: "mrrobot.protonvpn"

  readonly property int refreshIntervalMs: Math.max(2, Number(setting("refreshIntervalSec", 5))) * 1000

  property bool connected: false
  property bool appRunning: false
  property bool busy: false

  function refresh() {
    if (!statusProc.running) statusProc.running = true
  }

  function updateStatus(raw) {
    var lines = String(raw || "").split("\n")
    root.connected = lines.indexOf("connected") !== -1
    root.appRunning = lines.indexOf("app-running") !== -1
  }

  // Runs the same script the SUPER+SHIFT+V keybind uses, so behavior
  // (including the "quit the GTK app first" guard) stays in one place.
  function runToggle() {
    if (busy || toggleProc.running) return
    busy = true
    toggleProc.running = true
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: statusProc
    command: ["bash", "-c", "pgrep -x protonvpn-app >/dev/null && echo app-running; nmcli -t -f DEVICE,STATE device status 2>/dev/null | grep -q '^proton0:connected' && echo connected || echo disconnected"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.updateStatus(text) }
  }

  Process {
    id: toggleProc
    command: ["omarchy-protonvpn-toggle"]
    onExited: {
      root.busy = false
      settleTimer.restart()
    }
  }

  // Connect/disconnect isn't instant, so poll a couple more times shortly
  // after a toggle instead of relying solely on the steady-state interval.
  Timer { id: settleTimer; interval: 900; onTriggered: root.refresh() }

  Timer {
    interval: root.refreshIntervalMs
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    iconComponent: iconComp
    tooltipText: root.appRunning
      ? "Proton VPN — quit the app to use this toggle"
      : (root.connected ? "Proton VPN — connected" : "Proton VPN — disconnected")
    onPressed: function(b) {
      if (b === Qt.RightButton) root.runToggle()
      else root.toggle()
    }
  }

  Component {
    id: iconComp
    ProtonVpnIcon {
      anchors.fill: parent
      color: root.connected ? Color.accent : root.bar.foreground
      filled: root.connected
    }
  }

  PopupCard {
    id: popup
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.opened
    contentWidth: popup.fittedContentWidth(Style.space(230))
    contentHeight: popup.fittedContentHeight(column.implicitHeight)

    Column {
      id: column
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      spacing: Style.space(12)

      Item {
        width: parent.width
        implicitHeight: Math.max(headerIcon.height, headerLabels.implicitHeight)

        ProtonVpnIcon {
          id: headerIcon
          width: Style.font.display
          height: Style.font.display
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          color: root.connected ? Color.accent : root.bar.foreground
          filled: root.connected
        }

        Column {
          id: headerLabels
          anchors.left: headerIcon.right
          anchors.leftMargin: Style.space(12)
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(2)

          Text {
            text: "Proton VPN"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.title
            font.bold: true
          }

          Text {
            text: root.connected ? "CONNECTED" : "DISCONNECTED"
            color: root.connected ? Color.accent : Qt.darker(root.bar.foreground, 1.4)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
            font.bold: true
            font.letterSpacing: 1.2
          }
        }
      }

      PanelSeparator {
        foreground: root.bar.foreground
      }

      Text {
        visible: root.appRunning
        width: parent.width
        wrapMode: Text.WordWrap
        text: "Quit the Proton VPN app first — it can't run alongside this toggle."
        color: Qt.darker(root.bar.foreground, 1.3)
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.bodySmall
      }

      Button {
        width: parent.width
        enabled: !root.appRunning && !root.busy
        opacity: enabled ? 1.0 : 0.5
        bordered: true
        text: root.busy ? "Working…" : (root.connected ? "Disconnect" : "Connect")
        foreground: root.bar.foreground
        fontFamily: root.bar.fontFamily
        horizontalPadding: Style.spacing.controlPaddingX
        verticalPadding: Style.spacing.controlPaddingY + Style.space(2)
        onClicked: root.runToggle()
      }
    }
  }
}
