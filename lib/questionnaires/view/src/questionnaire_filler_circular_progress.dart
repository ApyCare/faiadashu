import 'dart:math';

import 'package:collection/collection.dart';
import 'package:faiadashu/questionnaires/model/model.dart';
import 'package:faiadashu/questionnaires/view/view.dart'
    show QuestionnaireResponseFiller;
import 'package:flutter/material.dart';

/// A circular progress indicator for the filling of a [QuestionnaireModel]
class QuestionnaireFillerCircularProgress extends StatelessWidget {
  final double radius;

  static const double defaultRadius = 36.0;

  const QuestionnaireFillerCircularProgress({
    this.radius = defaultRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius,
      height: radius,
      child: AnimatedBuilder(
        animation: QuestionnaireResponseFiller.of(context)
            .questionnaireResponseModel
            .answeredChangeNotifier,
        builder: (context, __) {
          final newColors = QuestionnaireResponseFiller.of(context)
              .questionnaireResponseModel
              .orderedResponseItemModels()
              .where((rim) => rim.isAnswerable)
              .map<Color?>(
            (rim) {
              return rim.isAnswered ? Colors.green : null;
            },
          );

          return RepaintBoundary(
            child: CustomPaint(
              painter: _ProgressPainter(
                radius,
                colors: newColors,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double radius;
  final Iterable<Color?> colors;

  static const double strokeWidth = 4.0;

  _ProgressPainter(this.radius, {required this.colors}) : super();

  final Paint _inactive = Paint()
    ..color = Colors.black12
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    const doublePi = pi + pi;

    canvas.drawArc(
      Offset.zero & Size(radius - strokeWidth, radius - strokeWidth),
      0,
      doublePi,
      false,
      _inactive,
    );

    final sweepAngle = doublePi / colors.length;

    /// If any of the colors is null, the progress is not completed.
    /// This is used to determine the color of the progress.
    /// Red if not completed, green if completed.
    final notCompleted = colors.any((c) => c == null);

    final paint = Paint()
      ..color = notCompleted ? Colors.pink : Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    colors.forEachIndexed((i, sweepColor) {
      if (sweepColor != null) {
        canvas.drawArc(
          Offset.zero & Size(radius - strokeWidth, radius - strokeWidth),
          i * sweepAngle,
          sweepAngle,
          false,
          paint,
        );
      }
    });
  }

  @override
  bool shouldRepaint(_ProgressPainter oldDelegate) {
// OPTIMIZE: This is not behaving as expected: compares object to itself.
    /*    final shouldRepaint =
        !const IterableEquality().equals(oldDelegate.colors, colors);

    return shouldRepaint; */
    return true;
  }
}
