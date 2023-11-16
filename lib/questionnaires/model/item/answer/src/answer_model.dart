import 'package:faiadashu/faiadashu.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';
import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';

/// Models a single answer within a [QuestionItemModel].
abstract class AnswerModel<I, V> extends ResponseNode {
  /// Textual depiction of an unanswered question.
  static const nullText = '—';

  final QuestionItemModel responseItemModel;
  V? _value;

  V? get value => _value;

  /// Set the [value].
  ///
  /// This will also validate it and set the errorText accordingly.
  set value(V? newValue) {
    if (_value != newValue) {
      final isAnswered = responseItemModel.isAnswered;
      final isUnanswered = responseItemModel.isUnanswered;
      final isPopulated = responseItemModel.isPopulated;

      _value = newValue;

      final isAnsweredChange = isAnswered != responseItemModel.isAnswered ||
          isUnanswered != responseItemModel.isUnanswered ||
          isPopulated != responseItemModel.isPopulated;

      responseItemModel.handleChangedAnswer(
        this,
        isAnsweredChange: isAnsweredChange,
      );
    }
  }

  QuestionnaireItemModel get questionnaireItemModel =>
      responseItemModel.questionnaireItemModel;

  QuestionnaireResponseModel get questionnaireResponseModel =>
      responseItemModel.questionnaireResponseModel;

  QuestionnaireModelDefaults get modelDefaults =>
      questionnaireResponseModel.questionnaireModel.questionnaireModelDefaults;

  Locale get locale => questionnaireResponseModel.locale;

  QuestionnaireItem get qi => questionnaireItemModel.questionnaireItem;

  /// Is the control for the answer to be enabled?
  ///
  /// * true: users may manipulate the control
  /// * false: users may not manipulate the control
  bool get isControlEnabled =>
      responseItemModel.displayVisibility == DisplayVisibility.shown;

  /// Returns the human-readable entry format.
  ///
  /// See: http://hl7.org/fhir/R4/extension-entryformat.html
  String? get entryFormat {
    return qi.extension_
        ?.extensionOrNull('http://hl7.org/fhir/StructureDefinition/entryFormat')
        ?.valueString;
  }

  /// Construct a new, unpopulated answer model.
  AnswerModel(this.responseItemModel) : super(responseItemModel);

  /// Returns a human-readable, localized, textual description of the model.
  ///
  /// Returns [RenderingString.nullText] if the question is unanswered.
  RenderingString get display;

  /// Validates a new input value. Does not change the [value].
  ///
  /// This is used to validate external input from a view.
  ///
  /// Returns null when [inputValue] is invalid; otherwise
  /// Returns [ValidationError].
  ValidationError? validateInput(I? inputValue);

  /// Validates a value against the constraints of the answer model.
  /// Does not change the [value] of the answer model.
  ///
  /// Returns null when [inputValue] is invalid; otherwise
  /// Returns [ValidationError].
  ValidationError? validateValue(V? inputValue);

  /// Validates whether the current [value] will pass the completeness check.
  ///
  /// Completeness means that the validity criteria are met,
  /// in order to submit a [QuestionnaireResponse] as complete.
  ///
  /// Since an individual answer does not know whether it is required, this
  /// is not taken into account.
  ///
  /// Returns an empty list when the answer is valid, otherwise
  /// Returns a list of [ValidationError].
  List<ValidationError> validate({
    bool updateErrorText = true,
    bool notifyListeners = false,
  }) {
    final validationError = validateValue(value);

    if (_validationError == validationError && validationError != null) {
      return [validationError];
    }

    if (updateErrorText) {
      _validationError = validationError;
    }

    if (notifyListeners) {
      this.notifyListeners();
    }

    return _validationError != null ? [_validationError!] : [];
  }

  /// Returns whether any answer (valid or invalid) has been provided.
  bool get isNotEmpty => !isEmpty;

  /// Returns whether this question is unanswered.
  bool get isEmpty;

  /// Is there a dialog shown on screen?
  bool isDialogShown = false;

  ValidationError? _validationError;

  /// Returns an error text for display in the answer's control.
  ///
  /// This might return an error text from the parent [QuestionItemModel].
  String? displayErrorText(FDashLocalizations localizations) =>
      _validationError?.getMessage(localizations) ??
      responseItemModel.getErrorText(localizations);

  /// Returns a [QuestionnaireResponseAnswer] based on the current value.
  ///
  /// Can optionally add nested [items].
  ///
  /// This is the link between the presentation model and the underlying
  /// FHIR domain model.
  QuestionnaireResponseAnswer? createFhirAnswer(
    List<QuestionnaireResponseItem>? items,
  );

  List<QuestionnaireResponseAnswer>? createFhirCodingAnswers(
    List<QuestionnaireResponseItem>? items,
  ) {
    throw UnimplementedError('createFhirCodingAnswers not implemented.');
  }

  bool get hasCodingAnswers => false;

  /// Populate an answer model with a value from the FHIR domain model.
  void populate(QuestionnaireResponseAnswer answer);

  /// Populate an answer model with a multiple-choice answer from the FHIR domain model.
  void populateCodingAnswers(List<QuestionnaireResponseAnswer>? answers) {
    throw UnimplementedError('populateCodingAnswers not implemented.');
  }

  /// Populates the answer from the result of a FHIRPath expression.
  ///
  /// This function is designed for a very specific internal purpose and should
  /// not be invoked by application code.
  void populateFromExpression(dynamic evaluationResult) {
    throw UnimplementedError('populateFromExpression not implemented.');
  }

  static int _uidCounter = 0;

  /// INTERNAL USE ONLY - do not invoke!
  @override
  String calculateNodeUid() {
    _uidCounter++;

    return '${parentNode?.nodeUid}/$_uidCounter';
  }
}
