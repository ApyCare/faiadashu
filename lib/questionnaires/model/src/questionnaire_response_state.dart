/// A global singleton that manages the state of whether a questionnaire response
/// has been provided for pre-filling.
///
/// This state is used throughout the application to determine if certain
/// validations (like wrong quiz response checking) should be skipped.
class QuestionnaireResponseState {
  static final QuestionnaireResponseState _instance = QuestionnaireResponseState._internal();
  
  factory QuestionnaireResponseState() {
    return _instance;
  }
  
  QuestionnaireResponseState._internal();
  
  /// Whether a questionnaire response has been provided for pre-filling.
  ///
  /// When `true`, it indicates that the questionnaire is being filled with
  /// existing response data, and certain validations (like quiz response
  /// checking) should be skipped.
  bool hasResponse = false;
  
  /// Resets the state to default (no response).
  /// 
  /// This can be called when starting a new questionnaire session.
  void reset() {
    hasResponse = false;
  }
}
