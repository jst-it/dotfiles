import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "mrrobot.menu"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    // Rebranded: \ue900 is the Omarchy square logo, and it only exists in the
    // "omarchy" icon font. Dropping fontFamily falls back to bar.fontFamily,
    // the Nerd Font the rest of the bar glyphs already use.
    text: "\udb82\udcc7"
    horizontalMargin: 7.5
    onPressed: function(button) {
      if (!root.bar) return
      if (button === Qt.RightButton) root.bar.run("xdg-terminal-exec")
      else root.bar.run("omarchy-shell shell toggle mrrobot.menu '{\"menu\":\"favorites\"}'")
    }
  }
}
