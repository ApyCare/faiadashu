import 'package:faiadashu/questionnaires/model/model.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';
import 'package:fhir/r4.dart';

/// A pseudo-model for a questionnaire item of an unsupported type.
class UnsupportedAnswerModel extends AnswerModel<Object, Object> {
  UnsupportedAnswerModel(super.responseModel);

  @override
  QuestionnaireResponseAnswer? createFhirAnswer(
    List<QuestionnaireResponseItem>? items,
  ) {
    return null;
  }

  @override
  RenderingString get display => RenderingString.nullText;

  @override
  ValidationError? validateInput(Object? inValue) {
    return null;
  }

  @override
  ValidationError? validateValue(Object? inputValue) {
    return null;
  }

  @override
  bool get isEmpty => false;

  @override
  void populate(QuestionnaireResponseAnswer answer) {
    throw UnsupportedError('Cannot populate item of unknown type.');
  }
}
