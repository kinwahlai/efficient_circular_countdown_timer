import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularCountdownPainter extends CustomPainter {
  final double progress;
  final Color? fillColor;
  final Color? ringColor;
  final Color? backgroundColor;
  final Gradient? fillGradient;
  final Gradient? ringGradient;
  final Gradient? backgroundGradient;
  final double strokeWidth;
  final StrokeCap strokeCap;

  // Paint and Shader caches for performance
  Paint? _backgroundPaint;
  Paint? _ringPaint;
  Paint? _fillPaint;
  Size? _lastSize;
  Gradient? _lastBackgroundGradient;
  Gradient? _lastRingGradient;
  Gradient? _lastFillGradient;

  CircularCountdownPainter({
    required this.progress,
    this.fillColor,
    this.ringColor,
    this.backgroundColor,
    this.fillGradient,
    this.ringGradient,
    this.backgroundGradient,
    required this.strokeWidth,
    required this.strokeCap,
  });

  void _updatePaints(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width < size.height ? size.width : size.height) / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background paint
    if (_backgroundPaint == null || _lastSize != size || _lastBackgroundGradient != backgroundGradient) {
      _backgroundPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap;
      if (backgroundGradient != null) {
        _backgroundPaint!.shader = backgroundGradient!.createShader(rect);
      } else if (backgroundColor != null) {
        _backgroundPaint!.color = backgroundColor!;
      }
      _lastBackgroundGradient = backgroundGradient;
    }

    // Ring paint
    if (_ringPaint == null || _lastSize != size || _lastRingGradient != ringGradient) {
      _ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap;
      if (ringGradient != null) {
        _ringPaint!.shader = ringGradient!.createShader(rect);
      } else if (ringColor != null) {
        _ringPaint!.color = ringColor!;
      }
      _lastRingGradient = ringGradient;
    }

    // Fill paint
    if (_fillPaint == null || _lastSize != size || _lastFillGradient != fillGradient) {
      _fillPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeCap;
      if (fillGradient != null) {
        _fillPaint!.shader = fillGradient!.createShader(rect);
      } else if (fillColor != null) {
        _fillPaint!.color = fillColor!;
      }
      _lastFillGradient = fillGradient;
    }

    _lastSize = size;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _updatePaints(size);
    Paint paint = Paint()
      ..color = ringColor!
      ..strokeWidth = strokeWidth!
      ..strokeCap = strokeCap!
      ..style = PaintingStyle.stroke;

    if (ringGradient != null) {
      final rect = Rect.fromCircle(
          center: size.center(Offset.zero), radius: size.width / 2);
      paint.shader = ringGradient!.createShader(rect);
    } else {
      paint.shader = null;
    }

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
    double lprogress = (progress * 2 * math.pi);
    double startAngle = math.pi * 1.5;

    if (fillGradient != null) {
      final rect = Rect.fromCircle(
          center: size.center(Offset.zero), radius: size.width / 2);
      paint.shader = fillGradient!.createShader(rect);
    } else {
      paint.shader = null;
      paint.color = fillColor!;
    }

    canvas.drawArc(Offset.zero & size, startAngle, lprogress, false, paint);

    if (backgroundColor != null || backgroundGradient != null) {
      final backgroundPaint = Paint();

      if (backgroundGradient != null) {
        final rect = Rect.fromCircle(
            center: size.center(Offset.zero), radius: size.width / 2.2);
        backgroundPaint.shader = backgroundGradient!.createShader(rect);
      } else {
        backgroundPaint.color = backgroundColor!;
      }
      canvas.drawCircle(
          size.center(Offset.zero), size.width / 2.2, backgroundPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CircularCountdownPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        fillColor != oldDelegate.fillColor ||
        ringColor != oldDelegate.ringColor ||
        backgroundColor != oldDelegate.backgroundColor ||
        fillGradient != oldDelegate.fillGradient ||
        ringGradient != oldDelegate.ringGradient ||
        backgroundGradient != oldDelegate.backgroundGradient ||
        strokeWidth != oldDelegate.strokeWidth ||
        strokeCap != oldDelegate.strokeCap;
  }
}