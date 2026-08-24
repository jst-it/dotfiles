import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.Commons
import qs.Ui

// Dedicated now-playing indicator for Cliamp specifically - not Omarchy's
// built-in generic omarchy.media widget, which surfaces whatever MPRIS
// player happens to be active (Spotify, a browser tab, ...). This one
// looks only for Cliamp's own MPRIS player (org.mpris.MediaPlayer2.cliamp,
// a stable dbusName with no instance suffix) and stays hidden whenever
// Cliamp isn't running.
BarWidget {
  id: root
  moduleName: "mrrobot.cliamp"

  readonly property var player: {
    var list = Mpris.players ? Mpris.players.values : []
    for (var i = 0; i < list.length; i++) {
      if (list[i] && list[i].dbusName === "org.mpris.MediaPlayer2.cliamp")
        return list[i]
    }
    return null
  }

  readonly property bool hasMedia: player !== null
    && (player.trackTitle || player.trackArtist)

  // Cliamp publishes the underlying stream/video's real metadata over MPRIS
  // (e.g. a YouTube video's actual title, or a radio stream's ICY tag) -
  // not the playlist's declared track name. "cliamp status --json" reports
  // the playlist-declared title instead ({"track":{"title":"Rain",...}}),
  // so prefer that and only fall back to the raw MPRIS title if the CLI
  // call fails (e.g. cliamp's IPC socket isn't up yet).
  property string playlistTitle: ""
  readonly property string title: playlistTitle || (player ? (player.trackTitle || "") : "")
  readonly property string barText: title
  readonly property bool playing: player !== null && player.isPlaying

  function refreshPlaylistTitle() {
    if (!hasMedia) return
    if (!cliampStatusProc.running) cliampStatusProc.running = true
  }

  onHasMediaChanged: if (hasMedia) refreshPlaylistTitle()
  Connections {
    target: root.player
    function onTrackTitleChanged() { root.refreshPlaylistTitle() }
  }

  Timer {
    interval: 4000
    running: root.hasMedia
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refreshPlaylistTitle()
  }

  Process {
    id: cliampStatusProc
    command: ["cliamp", "status", "--json"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var data = JSON.parse(String(text))
          root.playlistTitle = (data.track && data.track.title) ? data.track.title : ""
        } catch (e) {
          root.playlistTitle = ""
        }
      }
    }
  }
  readonly property color foreground: bar ? bar.foreground : Color.foreground

  function togglePlayback() {
    if (!player) return
    if (player.canTogglePlaying) player.togglePlaying()
    else if (playing && player.canPause) player.pause()
    else if (!playing && player.canPlay) player.play()
  }

  // Jump to Cliamp's terminal window wherever it is (workspace 5 at login,
  // but it can get moved). hyprctl's dispatch CLI on this Lua-config build
  // evaluates its argument as a Lua expression rather than classic
  // "dispatcher args" - hl.dsp.focus({ window = "class:..." }) is the
  // working form (see shell/plugins/bar/widgets/Workspaces.qml for the
  // same bar.run(hyprctl dispatch ...) pattern used for workspace focus).
  function focusWindow() {
    if (!bar) return
    bar.run("hyprctl dispatch " + Util.shellQuote('hl.dsp.focus({ window = "class:^(org.omarchy.cliamp)$" })'))
  }

  property real wheelAccum: 0
  property real pendingVolume: -1

  // Cliamp's MPRIS Volume write is a blocking D-Bus call; a fast scroll can
  // queue up many notches within milliseconds, and firing one write per
  // notch has been enough to wedge Cliamp's D-Bus handling entirely (seen
  // during testing: it stopped answering D-Bus calls at all, play/pause
  // included, until force-killed). Debounce so a burst of notches collapses
  // into a single write.
  Timer {
    id: volumeWriteTimer
    interval: 60
    onTriggered: {
      if (root.player && root.pendingVolume >= 0) root.player.volume = root.pendingVolume
      root.pendingVolume = -1
    }
  }

  function adjustVolume(delta) {
    if (!player || !player.volumeSupported) return
    // Coalesce raw wheel deltas into whole notches (120 units = one scroll
    // line) so a touchpad's many small events per gesture don't apply more
    // than one step per line, the way a physical mouse wheel would.
    wheelAccum += delta
    var notches = Math.trunc(wheelAccum / 120)
    if (notches === 0) return
    wheelAccum -= notches * 120
    var step = 0.05
    var base = pendingVolume >= 0 ? pendingVolume : player.volume
    pendingVolume = Math.max(0, Math.min(1, base + notches * step))
    volumeWriteTimer.restart()
  }

  visible: hasMedia
  implicitWidth: hasMedia ? button.implicitWidth : 0
  implicitHeight: button.implicitHeight

  TextMetrics {
    id: labelMetrics
    text: root.barText
    font.family: root.bar ? root.bar.fontFamily : Style.font.family
    font.pixelSize: Style.font.body
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    labelVisible: false
    hasVisualContent: true
    active: root.playing
    activeColor: button.foreground
    tooltipText: root.hasMedia ? root.barText : "Cliamp"
    fixedWidth: root.vertical ? root.barSize
      : (barGlyph.implicitWidth + barRow.spacing + labelMetrics.advanceWidth
        + button.scaledHorizontalMargin * 2)
    clip: true

    Row {
      id: barRow
      anchors.centerIn: parent
      spacing: Style.space(6)
      visible: !root.vertical

      Text {
        id: barGlyph
        anchors.verticalCenter: parent.verticalCenter
        text: root.playing ? "󰏤" : "󰐊"
        color: button.foreground
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.body
        renderType: Text.NativeRendering
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.barText
        color: button.foreground
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.body
        renderType: Text.NativeRendering
      }
    }

    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton) root.togglePlayback()
      else if (mouseButton === Qt.MiddleButton) root.focusWindow()
    }

    onWheelMoved: function(delta) {
      root.adjustVolume(delta)
    }
  }
}
