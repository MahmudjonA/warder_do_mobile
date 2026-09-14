import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/stats_entities.dart';

/// Bitta kunning holatini doira/halqa ko'rinishida chizadi.
///
/// Kalendar (raqam bilan) va haftalik jadval (raqamsiz, kichik) — ikkalasi ham
/// shu bitta widgetdan foydalanadi.
class StatusCircle extends StatelessWidget {
  const StatusCircle({
    required this.status,
    required this.progressPercent,
    this.color = AppColors.primary,
    this.label,
    this.size = 30,
    super.key,
  });

  final DayStatus status;
  final int progressPercent;

  /// Odat rangi (haftalik jadval) yoki default primary (kalendar).
  final Color color;

  /// Kun raqami. `null` — haftalik jadval (raqamsiz).
  final String? label;

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StatusPainter(
          status: status,
          progress: progressPercent / 100,
          color: color,
        ),
        child: label == null ? null : Center(child: _label()),
      ),
    );
  }

  Widget _label() {
    final Color textColor;
    switch (status) {
      case DayStatus.done:
        textColor = Colors.white;
      case DayStatus.partial:
      case DayStatus.pending:
        textColor = color;
      case DayStatus.missed:
        textColor = AppColors.textSecondary;
      case DayStatus.rest:
      case DayStatus.vacation:
        textColor = AppColors.textPrimary;
      case DayStatus.future:
      case DayStatus.notDue:
        textColor = AppColors.textTertiary;
    }

    return Text(
      label!,
      style: TextStyle(
        fontSize: size * 0.42,
        height: 1,
        fontWeight: status == DayStatus.done
            ? FontWeight.w700
            : FontWeight.w500,
        color: textColor,
      ),
    );
  }
}

class _StatusPainter extends CustomPainter {
  const _StatusPainter({
    required this.status,
    required this.progress,
    required this.color,
  });

  final DayStatus status;
  final double progress;
  final Color color;

  /// Dam olish / ta'til kunlari uchun kichik belgi ranglari.
  static const Color _restDot = Color(0xFF4FA8E8);
  static const Color _vacationDot = AppColors.success;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    switch (status) {
      case DayStatus.done:
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..style = PaintingStyle.fill
            ..color = color,
        );

      case DayStatus.partial:
      case DayStatus.pending:
        const stroke = 2.5;
        final r = radius - stroke / 2;
        canvas.drawCircle(
          center,
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..color = color.withValues(
              alpha: status == DayStatus.pending ? 0.55 : 0.3,
            ),
        );
        if (status == DayStatus.partial && progress > 0) {
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: r),
            -math.pi / 2,
            2 * math.pi * progress.clamp(0.0, 1.0),
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = stroke
              ..strokeCap = StrokeCap.round
              ..color = color,
          );
        }

      case DayStatus.rest:
      case DayStatus.vacation:
        // Reja bo'yicha "dam" kun — kichik nuqta bilan ajratamiz.
        canvas.drawCircle(
          Offset(center.dx, size.height - 1.5),
          1.6,
          Paint()..color = status == DayStatus.rest ? _restDot : _vacationDot,
        );

      case DayStatus.missed:
      case DayStatus.future:
      case DayStatus.notDue:
        break;
    }
  }

  @override
  bool shouldRepaint(_StatusPainter old) =>
      old.status != status || old.progress != progress || old.color != color;
}
