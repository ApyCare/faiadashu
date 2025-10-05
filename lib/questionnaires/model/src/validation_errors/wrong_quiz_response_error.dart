import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class WrongQuizResponseError extends ValidationError {
  final String? hint;

  WrongQuizResponseError(super.nodeUid, {this.hint});

  @override
  String? getMessage(FDashLocalizations localizations) {
    if (hint != null && hint!.isNotEmpty) {
      return '${localizations.errorWrongQuizResponse} $hint';
    }
    return localizations.errorWrongQuizResponse;
  }
}
