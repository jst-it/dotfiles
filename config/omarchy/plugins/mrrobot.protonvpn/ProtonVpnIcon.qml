import QtQuick
import QtQuick.Shapes
import qs.Commons

// Filled/outlined shield badge for Proton VPN state. Built with QtQuick.Shapes
// (the same CurveRenderer path-rendering Omarchy's BorderOverlay uses for
// gradient borders) rather than Canvas: Canvas renders into an offscreen FBO,
// and on some GPU/driver combos that surface shows up as a black/magenta
// checkerboard before the first real paint lands. Shape's CurveRenderer
// has no such failure mode.
Item {
  id: root

  property color color: Color.foreground
  property bool filled: false

  Shape {
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    transform: Scale {
      xScale: root.width / 24
      yScale: root.height / 24
    }

    ShapePath {
      fillColor: root.filled ? root.color : "transparent"
      strokeColor: root.color
      strokeWidth: root.filled ? 0 : 2.2
      joinStyle: ShapePath.RoundJoin
      capStyle: ShapePath.RoundCap

      // Classic shield outline in a 24x24 viewBox, scaled to fit via the
      // transform above.
      PathSvg { path: "M12,1L3,5V11C3,16.55 6.84,21.74 12,23C17.16,21.74 21,16.55 21,11V5L12,1Z" }
    }
  }
}
