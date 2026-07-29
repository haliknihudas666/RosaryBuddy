import 'dart:math';
import 'package:flutter/material.dart';

// ─── Layout ───────────────────────────────────────────────────────────────────

/// Positions of every object in the rosary.
class _Layout {
  /// Map from bead index (0..58) → canvas offset.
  final Map<int, Offset> beadPositions;

  /// The cross pendant centre.
  final Offset crossCenter;

  /// The junction where the pendant tail meets the oval (bottom of oval).
  final Offset junction;

  final double cx, cy, rx, ry;
  final double crossH, crossW, crossBarThick;
  final double smallR, largeR;

  const _Layout({
    required this.beadPositions,
    required this.crossCenter,
    required this.junction,
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
    required this.crossH,
    required this.crossW,
    required this.crossBarThick,
    required this.smallR,
    required this.largeR,
  });
}

_Layout _buildLayout(Size size) {
  final cx = size.width / 2;
  // Keep oval in top ~50 % of the canvas; rest is tail + cross.
  final rx = size.width * 0.36;
  final ry = size.height * 0.22;
  final cy = size.height * 0.06 + ry; // small top padding + ry

  final junctionY = cy + ry;

  // Distribute tail height so the cross fits within the canvas.
  final bottomPad = size.height * 0.04;
  final tailAvailable = size.height - junctionY - bottomPad;
  // 4 tail beads + 1 cross-space = 5 slots, with cross taking ~1.3 slots.
  final tailSpacing = tailAvailable / 5.3;

  final crossH = tailSpacing * 1.15;
  final crossW = crossH * 0.62;
  final crossBarThick = crossH * 0.18;

  // Bead radii relative to width
  final smallR = (size.width * 0.014).clamp(4.5, 7.0);
  final largeR = smallR * 1.72;

  final positions = <int, Offset>{};

  // ── Circle beads (4..58) – 55 beads on the oval ─────────────────────────
  // We place them counterclockwise in screen-space starting just to the right
  // of the bottom junction, so "1st Mystery" appears at ~4–5 o'clock.
  //
  // In Flutter's parametric coords: x = cx + rx·cos(t), y = cy + ry·sin(t)
  // Increasing t → clockwise in screen; decreasing t → counterclockwise.
  // We want to go counterclockwise from the junction (t=π/2, straight bottom)
  // so we *subtract* step for each successive bead.
  const totalCircle = 55;
  const fullStep = 2 * pi / totalCircle; // angle per bead

  for (int i = 0; i < totalCircle; i++) {
    final beadIdx = i + 4;
    // Half-step offset centres beads between junction neighbours.
    final t = pi / 2 - (i + 0.5) * fullStep;
    positions[beadIdx] = Offset(cx + rx * cos(t), cy + ry * sin(t));
  }

  // ── Tail beads (0..3) – hanging below junction ───────────────────────────
  // Ordering (top to bottom): bead 3 → bead 2 → bead 1 → bead 0 (large)
  for (int i = 0; i < 4; i++) {
    final beadIdx = 3 - i; // 3, 2, 1, 0 going downward
    positions[beadIdx] = Offset(cx, junctionY + tailSpacing * (i + 1));
  }

  final crossCenterY =
      junctionY + tailSpacing * 4 + tailSpacing * 0.55 + crossH / 2;

  return _Layout(
    beadPositions: positions,
    crossCenter: Offset(cx, crossCenterY),
    junction: Offset(cx, junctionY),
    cx: cx,
    cy: cy,
    rx: rx,
    ry: ry,
    crossH: crossH,
    crossW: crossW,
    crossBarThick: crossBarThick,
    smallR: smallR,
    largeR: largeR,
  );
}

// ─── Painter ──────────────────────────────────────────────────────────────────

/// Draws the full rosary:  oval thread · tail thread · beads · cross.
///
/// Pass [repaint] (a [Listenable]) so the painter refreshes on every
/// animation tick for the glow-pulse effect.
class RosaryPainter extends CustomPainter {
  final int activeBeadIndex; // -1 = cross
  final Set<int> completedBeads;
  final Animation<double> pulseAnim;
  final bool isDark;

  final Color threadColor;
  final Color smallBeadColor;
  final Color largeBeadColor;
  final Color activeBeadColor;
  final Color completedBeadColor;
  final Color crossColor;

  RosaryPainter({
    required this.activeBeadIndex,
    required this.completedBeads,
    required this.pulseAnim,
    required this.isDark,
  }) : threadColor = isDark ? const Color(0xFF5C3D2E) : const Color(0xFF8C7355),
       smallBeadColor = isDark
           ? const Color(0xFFF5E6D3)
           : const Color(0xFFFFFFFF),
       largeBeadColor = const Color(0xFFCA8A04),
       activeBeadColor = const Color(0xFFCA8A04),
       completedBeadColor = isDark ? const Color(0xFF22C55E) : const Color(0xFF1E8F4A),
       crossColor = const Color(0xFFCA8A04),
       super(repaint: pulseAnim);

  // Cache layout between frames (only recomputed when size changes).
  _Layout? _cachedLayout;
  Size? _cachedSize;

  _Layout _layout(Size size) {
    if (_cachedSize != size) {
      _cachedLayout = _buildLayout(size);
      _cachedSize = size;
    }
    return _cachedLayout!;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  bool _isLargeBead(int idx) => idx == 0 || (idx >= 4 && (idx - 4) % 11 == 0);

  // ── Paint ────────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final lay = _layout(size);
    _drawThread(canvas, lay);
    _drawBeads(canvas, lay);
    _drawCross(canvas, lay);
  }

  void _drawThread(Canvas canvas, _Layout lay) {
    final p = Paint()
      ..color = threadColor
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Oval
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(lay.cx, lay.cy),
        width: lay.rx * 2,
        height: lay.ry * 2,
      ),
      p,
    );

    // Tail line: junction → cross top
    canvas.drawLine(
      lay.junction,
      Offset(lay.crossCenter.dx, lay.crossCenter.dy - lay.crossH / 2),
      p,
    );
  }

  void _drawBeads(Canvas canvas, _Layout lay) {
    lay.beadPositions.forEach((idx, pos) {
      final isLarge = _isLargeBead(idx);
      final r = isLarge ? lay.largeR : lay.smallR;
      final isActive = idx == activeBeadIndex;
      final isDone = completedBeads.contains(idx);

      // Glow pulse for active bead
      if (isActive) {
        final pulseR = r * (1.8 + pulseAnim.value * 1.0);
        canvas.drawCircle(
          pos,
          pulseR,
          Paint()
            ..color = activeBeadColor.withValues(
              alpha: 0.18 * (2 - pulseAnim.value),
            )
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 1.4),
        );
      }

      // Drop shadow
      canvas.drawCircle(
        pos + const Offset(0.8, 1.5),
        r * 0.9,
        Paint()
          ..color = Colors.black.withValues(alpha: isDark ? 0.30 : 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );

      // Fill
      final Color fill;
      if (isActive) {
        fill = activeBeadColor;
      } else if (isDone) {
        fill = completedBeadColor;
      } else if (isLarge) {
        fill = largeBeadColor;
      } else {
        fill = smallBeadColor;
      }
      canvas.drawCircle(pos, r, Paint()..color = fill);

      // Border
      canvas.drawCircle(
        pos,
        r,
        Paint()
          ..color = isActive
              ? activeBeadColor.withValues(alpha: 0.9)
              : (isDark
                  ? threadColor.withValues(alpha: 0.55)
                  : threadColor.withValues(alpha: 0.85))
          ..style = PaintingStyle.stroke
          ..strokeWidth = isActive ? 1.6 : 0.8,
      );

      // Shine highlight
      if (!isDone) {
        canvas.drawCircle(
          Offset(pos.dx - r * 0.28, pos.dy - r * 0.28),
          r * 0.32,
          Paint()..color = Colors.white.withValues(alpha: 0.35),
        );
      }

      // Active ring(s)
      if (isActive) {
        final scale = pulseAnim.value;
        canvas.drawCircle(
          pos,
          r + 3.5 * scale,
          Paint()
            ..color = activeBeadColor.withValues(alpha: 0.55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
        canvas.drawCircle(
          pos,
          r + 7 * scale,
          Paint()
            ..color = activeBeadColor.withValues(alpha: 0.20)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
      }

      // Green checkmark dot for completed large beads
      if (isDone && isLarge) {
        canvas.drawCircle(
          Offset(pos.dx + r * 0.6, pos.dy - r * 0.6),
          r * 0.38,
          Paint()..color = const Color(0xFF22C55E),
        );
      }
    });
  }

  void _drawCross(Canvas canvas, _Layout lay) {
    final isActive = activeBeadIndex == -1;
    final isDone = completedBeads.contains(-1);
    final color = isActive
        ? activeBeadColor
        : (isDone ? completedBeadColor : crossColor);

    if (isActive) {
      // Glow
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: lay.crossCenter,
            width: lay.crossW + 14,
            height: lay.crossH + 14,
          ),
          const Radius.circular(5),
        ),
        Paint()
          ..color = activeBeadColor.withValues(alpha: 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    final p = Paint()..color = color;

    // Vertical bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: lay.crossCenter,
          width: lay.crossBarThick,
          height: lay.crossH,
        ),
        const Radius.circular(2),
      ),
      p,
    );

    // Horizontal bar at 33 % from top
    final barY = lay.crossCenter.dy - lay.crossH / 2 + lay.crossH * 0.33;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(lay.crossCenter.dx, barY),
          width: lay.crossW,
          height: lay.crossBarThick,
        ),
        const Radius.circular(2),
      ),
      p,
    );

    // Outer ring when active
    if (isActive) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: lay.crossCenter,
            width: lay.crossW + 6,
            height: lay.crossH + 6,
          ),
          const Radius.circular(5),
        ),
        Paint()
          ..color = activeBeadColor.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(RosaryPainter old) =>
      old.activeBeadIndex != activeBeadIndex ||
      old.completedBeads.length != completedBeads.length ||
      old.isDark != isDark;
}
