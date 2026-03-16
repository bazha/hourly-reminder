import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../core/theme/app_colors.dart';
import '../core/utils/time_utils.dart';

// ─── Public widget ────────────────────────────────────────────────────────────

class WorkHoursClock extends StatefulWidget {
  final double startTime;
  final double endTime;
  final ValueChanged<double>? onStartTimeChanged;
  final ValueChanged<double>? onEndTimeChanged;
  final double size;
  final DateTime? currentTime;

  const WorkHoursClock({
    super.key,
    required this.startTime,
    required this.endTime,
    this.onStartTimeChanged,
    this.onEndTimeChanged,
    this.size = 280,
    this.currentTime,
  });

  @override
  State<WorkHoursClock> createState() => _WorkHoursClockState();
}

class _WorkHoursClockState extends State<WorkHoursClock> {
  String? _draggingHand;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onPanStart: (d) => _handlePanStart(d.localPosition),
      onPanUpdate: (d) => _handlePanUpdate(d.localPosition),
      onPanEnd: (_) => setState(() => _draggingHand = null),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _ClockPainter(
            startTime: widget.startTime,
            endTime: widget.endTime,
            draggingHand: _draggingHand,
            currentTime: widget.currentTime,
            colors: colors,
          ),
        ),
      ),
    );
  }

  // ─── Gesture helpers ────────────────────────────────────────────────────────

  void _handlePanStart(Offset pos) {
    final c = Offset(widget.size / 2, widget.size / 2);
    final t12 = _angleToTime12(_angle(c, pos));
    final ds = (t12 - widget.startTime % 12).abs();
    final de = (t12 - widget.endTime % 12).abs();
    setState(() => _draggingHand = ds <= de ? 'start' : 'end');
  }

  void _handlePanUpdate(Offset pos) {
    if (_draggingHand == null) return;
    final c = Offset(widget.size / 2, widget.size / 2);
    final t12 = _angleToTime12(_angle(c, pos));
    final cur = _draggingHand == 'start' ? widget.startTime : widget.endTime;
    final t24 = _to24h(t12, cur);
    final snapped = _snap(t24);
    HapticFeedback.selectionClick();
    if (_draggingHand == 'start') {
      widget.onStartTimeChanged?.call(snapped);
    } else {
      widget.onEndTimeChanged?.call(snapped);
    }
  }

  static double _angle(Offset c, Offset p) =>
      math.atan2(p.dy - c.dy, p.dx - c.dx);

  static double _angleToTime12(double a) {
    var n = a + math.pi / 2;
    if (n < 0) n += 2 * math.pi;
    final t = (n / (2 * math.pi)) * 12;
    return t >= 12 ? 0 : t;
  }

  static double _to24h(double t12, double cur) {
    final t2 = t12 + 12;
    return (cur - t12).abs() <= (cur - t2).abs() ? t12 : t2;
  }

  /// Snaps to 15-minute increments.
  static double _snap(double t) {
    final totalMin = (t * 60).round();
    final snapped = (totalMin / 15).round() * 15;
    return (snapped % 1440) / 60.0;
  }
}

// ─── Painter ──────────────────────────────────────────────────────────────────

class _ClockPainter extends CustomPainter {
  final double startTime;
  final double endTime;
  final String? draggingHand;
  final DateTime? currentTime;
  final AppColors colors;

  static const _glowFactor = 0.7;

  static const _cStart = AppColors.startColor;
  static const _cEnd   = AppColors.endColor;
  static const _cNow   = AppColors.nowColor;

  const _ClockPainter({
    required this.startTime,
    required this.endTime,
    this.draggingHand,
    this.currentTime,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - 4;

    _drawFace(canvas, c, r);
    _drawTicks(canvas, c, r);
    _drawLabels(canvas, c, r);
    _drawWorkArc(canvas, c, r);
    if (currentTime != null) _drawNowIndicator(canvas, c, r);
    _drawHandle(canvas, c, r, startTime, _cStart, draggingHand == 'start');
    _drawHandle(canvas, c, r, endTime,   _cEnd,   draggingHand == 'end');
    _drawCenter(canvas, c);
  }

  // ─── Face ───────────────────────────────────────────────────────────────────

  void _drawFace(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(c, r + 2,
        Paint()
          ..color = colors.clockRing
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    canvas.drawCircle(c, r,
        Paint()
          ..shader = RadialGradient(
            colors: [colors.clockFaceInner, colors.clockFaceOuter],
            stops: const [0.0, 1.0],
          ).createShader(Rect.fromCircle(center: c, radius: r)));
    canvas.drawCircle(c, r,
        Paint()
          ..color = colors.clockBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  // ─── Tick marks ─────────────────────────────────────────────────────────────

  void _drawTicks(Canvas canvas, Offset c, double r) {
    for (int i = 0; i < 24; i++) {
      final angle  = _timeAngle(i.toDouble());
      final isKey  = i % 6 == 0;   // 0, 6, 12, 18
      final isHalf = i % 3 == 0;   // 3, 9, 15, 21
      final len    = isKey ? 14.0 : (isHalf ? 9.0 : 5.0);
      final outerR = r - 5;
      canvas.drawLine(
        Offset(c.dx + (outerR - len) * math.cos(angle),
               c.dy + (outerR - len) * math.sin(angle)),
        Offset(c.dx +  outerR       * math.cos(angle),
               c.dy +  outerR       * math.sin(angle)),
        Paint()
          ..color = isKey ? colors.clockTickKey
                 : (isHalf ? colors.clockTickHalf : colors.clockTickMinor)
          ..strokeWidth = isKey ? 2.0 : (isHalf ? 1.5 : 1.0)
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  // ─── Hour labels ────────────────────────────────────────────────────────────

  void _drawLabels(Canvas canvas, Offset c, double r) {
    const entries = [(0, '00'), (6, '06'), (12, '12'), (18, '18')];
    for (final (h, label) in entries) {
      final angle = _timeAngle(h.toDouble());
      final lr    = r - 28;
      final pos   = Offset(c.dx + lr * math.cos(angle),
                           c.dy + lr * math.sin(angle));
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: colors.clockLabelColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  // ─── Work arc ───────────────────────────────────────────────────────────────

  void _drawWorkArc(Canvas canvas, Offset c, double r) {
    final sa  = _timeAngle(startTime);
    final ea  = _timeAngle(endTime);
    var   sw  = ea - sa;
    if (sw <= 0) sw += 2 * math.pi;

    final arcR = r - 24;
    final rect = Rect.fromCircle(center: c, radius: arcR);

    // Sector fill — very faint
    final sectorPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sa,
        endAngle: sa + sw,
        colors: [
          _cStart.withValues(alpha: 0.07),
          _cEnd.withValues(alpha: 0.07),
        ],
      ).createShader(rect.inflate(arcR));
    canvas.drawArc(rect.inflate(arcR), sa, sw, true, sectorPaint);

    // Glow layers (outer → inner)
    for (final (width, baseOpacity) in [
      (30.0, 0.04),
      (20.0, 0.08),
      (12.0, 0.18),
    ]) {
      canvas.drawArc(
        rect, sa, sw, false,
        Paint()
          ..shader = SweepGradient(
            startAngle: sa,
            endAngle: sa + sw,
            colors: [
              _cStart.withValues(alpha: baseOpacity + _glowFactor * 0.06),
              _cEnd.withValues(alpha: baseOpacity + _glowFactor * 0.06),
            ],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.butt,
      );
    }

    // Main crisp arc
    canvas.drawArc(
      rect, sa, sw, false,
      Paint()
        ..shader = SweepGradient(
          startAngle: sa,
          endAngle: sa + sw,
          colors: const [_cStart, _cEnd],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  // ─── Now indicator ──────────────────────────────────────────────────────────

  void _drawNowIndicator(Canvas canvas, Offset c, double r) {
    final t     = currentTime!.hour + currentTime!.minute / 60.0;
    final angle = _timeAngle(t);
    final inner = r * 0.14;
    final outer = r - 24;
    final tip   = Offset(c.dx + outer * math.cos(angle),
                         c.dy + outer * math.sin(angle));

    canvas.drawLine(
      Offset(c.dx + inner * math.cos(angle),
             c.dy + inner * math.sin(angle)),
      tip,
      Paint()
        ..color = _cNow.withValues(alpha: 0.90)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(tip, 4.0, Paint()..color = _cNow);
    canvas.drawCircle(tip, 4.0,
        Paint()
          ..color = _cNow.withValues(alpha: 0.35 + _glowFactor * 0.20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
  }

  // ─── Handles ────────────────────────────────────────────────────────────────

  void _drawHandle(
    Canvas canvas, Offset c, double r,
    double time, Color col, bool dragging,
  ) {
    final angle = _timeAngle(time);
    final hr    = r - 42;
    final pos   = Offset(c.dx + hr * math.cos(angle),
                         c.dy + hr * math.sin(angle));
    final sz    = dragging ? 26.0 : 22.0;

    // Outer glow
    canvas.drawCircle(pos, sz + 8,
        Paint()..color = col.withValues(alpha: 0.12 + _glowFactor * 0.08));
    canvas.drawCircle(pos, sz + 4,
        Paint()..color = col.withValues(alpha: 0.22 + _glowFactor * 0.10));

    // Filled circle
    canvas.drawCircle(pos, sz,
        Paint()
          ..shader = RadialGradient(
            colors: [col, col.withValues(alpha: 0.65)],
          ).createShader(Rect.fromCircle(center: pos, radius: sz)));

    // Ring
    canvas.drawCircle(pos, sz,
        Paint()
          ..color = colors.clockHandleRing.withValues(alpha: dragging ? 0.35 : 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    // Time label
    final tp = TextPainter(
      text: TextSpan(
        text: TimeUtils.formatTime(time),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  // ─── Center dot ─────────────────────────────────────────────────────────────

  void _drawCenter(Canvas canvas, Offset c) {
    canvas.drawCircle(c, 6 + _glowFactor * 2,
        Paint()..color = colors.clockCenterGlow);
    canvas.drawCircle(c, 5,
        Paint()
          ..shader = RadialGradient(
            colors: [colors.clockCenterDot, colors.clockCenterDot.withValues(alpha: 0.7)],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: 5)));
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  /// Maps a 24 h value to canvas angle: 0 h → top (−π/2), period = 12 h.
  static double _timeAngle(double t) =>
      (t / 12) * 2 * math.pi - math.pi / 2;

  @override
  bool shouldRepaint(_ClockPainter old) =>
      old.startTime != startTime ||
      old.endTime   != endTime   ||
      old.draggingHand != draggingHand ||
      old.currentTime  != currentTime  ||
      old.colors != colors;
}

