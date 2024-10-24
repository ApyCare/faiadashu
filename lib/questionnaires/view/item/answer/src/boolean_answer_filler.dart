import 'package:faiadashu/l10n/l10n.dart';
import 'package:faiadashu/questionnaires/questionnaires.dart';
import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';

class BooleanAnswerFiller extends QuestionnaireAnswerFiller {
  BooleanAnswerFiller(
    super.answerModel, {
    super.key,
  });
  @override
  State<StatefulWidget> createState() => _BooleanItemState();
}

class _BooleanItemState extends QuestionnaireAnswerFillerState<FhirBoolean,
    BooleanAnswerFiller, BooleanAnswerModel> {
  _BooleanItemState();

  @override
  // ignore: no-empty-block
  void postInitState() {
    // Intentionally do nothing.
  }

  @override
  Widget createInputControl() => _BooleanInputControl(
        answerModel,
        focusNode: firstFocusNode,
      );
}

class _BooleanInputControl extends AnswerInputControl<BooleanAnswerModel> {
  const _BooleanInputControl(
    super.answerModel, {
    super.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          focusNode: focusNode,
          value: (answerModel.isTriState)
              ? answerModel.value?.value
              : (answerModel.value?.value != null),
          activeColor:
              (answerModel.displayErrorText(FDashLocalizations.of(context)) !=
                      null)
                  ? Theme.of(context).colorScheme.error
                  : null,
          tristate: answerModel.isTriState,
          onChanged: (answerModel.isControlEnabled)
              ? (newValue) {
                  focusNode?.requestFocus();
                  answerModel.value = answerModel.isTriState
                      ? ((newValue != null) ? FhirBoolean(newValue) : null)
                      : (newValue ?? false)
                          ? FhirBoolean(true)
                          : null;
                }
              : null,
        ),
        if (answerModel.displayErrorText(FDashLocalizations.of(context)) !=
            null)
          Text(
            answerModel.displayErrorText(FDashLocalizations.of(context))!,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}
