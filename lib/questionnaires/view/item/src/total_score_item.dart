import 'package:faiadashu/fhir_types/fhir_types.dart';
import 'package:faiadashu/l10n/l10n.dart';
import 'package:faiadashu/logging/logging.dart';
import 'package:faiadashu/questionnaires/questionnaires.dart';
import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

/// A styled display item for total scores.
///
/// Shows a large, animated score and also supports the Danish
/// sundhed.dk questionnaire-feedback extension.
class TotalScoreItem extends QuestionnaireAnswerFiller {
  TotalScoreItem(
    super.answerModel, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _TotalScoreItemState();
}

class _TotalScoreItemState extends State<TotalScoreItem> {
  static final _logger = Logger(_TotalScoreItemState);

  FhirDecimal? calcResult;

  _TotalScoreItemState();

  void _updateCalcResult() {
    calcResult =
        (widget.responseItemModel.firstAnswerModel as NumericalAnswerModel)
            .value
            ?.value;
  }

  @override
  void initState() {
    super.initState();

    _updateCalcResult();

    if (widget.questionnaireItemModel.isCalculated) {
      _logger.debug(
        'Adding listener to ${widget.questionnaireItemModel} for calculated expression',
      );
      widget.responseItemModel.questionnaireResponseModel.valueChangeNotifier
          .addListener(_questionnaireChanged);
    }
  }

  @override
  void dispose() {
    widget.responseItemModel.questionnaireResponseModel.valueChangeNotifier
        .removeListener(_questionnaireChanged);
    super.dispose();
  }

  void _questionnaireChanged() {
    _logger.debug(
      'questionnaireChanged(): ${widget.responseItemModel.nodeUid}',
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _updateCalcResult();
    });
    _logger.debug('calculated result: $calcResult');
  }

  /// Return a feedback string according to the Danish eHealth Sundhed DK spec.
  String? findDanishFeedback(int? score) {
    if (score == null) {
      return null;
    }
    final extensions =
        widget.questionnaireItemModel.questionnaireItem.extension_;

    if (extensions == null) {
      return null;
    }

    for (final ext in extensions) {
      if (ext.url?.value?.toString() !=
          'http://ehealth.sundhed.dk/fhir/StructureDefinition/ehealth-questionnaire-feedback') {
        continue;
      }

      final nestedExtensions = ext.extension_;
      if (nestedExtensions == null) {
        _logger.debug('Danish feedback extension without nested extensions.');
        continue;
      }

      final min =
          nestedExtensions.extensionOrNull('min')?.valueInteger?.value;
      final max =
          nestedExtensions.extensionOrNull('max')?.valueInteger?.value;

      if (min == null || max == null) {
        _logger.debug('Danish feedback extension missing min/max boundaries.');
        continue;
      }

      if (score < min || score > max) {
        continue;
      }

      final valueExtension = nestedExtensions.extensionOrNull('value');
      final feedback =
          valueExtension?.valueMarkdown?.value ?? valueExtension?.valueString;

      if (feedback == null) {
        _logger.debug('Danish feedback extension matched but contained no value.');
        continue;
      }

      return feedback;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questionnaireItemModel.isTotalScore) {
      final score = calcResult?.value?.round();
      final scoreText = score?.toString() ?? AnswerModel.nullText;
      final feedback = findDanishFeedback(score);

      return Center(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              FDashLocalizations.of(context).aggregationTotalScoreTitle,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                scoreText,
                key: ValueKey<String>(scoreText),
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: (feedback != null)
                  ? Container(
                      key: ValueKey<String>(feedback),
                      child: HtmlWidget(feedback),
                    )
                  : const SizedBox(
                      height: 16.0,
                      key: ValueKey<String>('no-feedback'),
                    ),
            ),
          ],
        ),
      );
    }

    return const SizedBox(
      height: 16.0,
    );
  }
}
