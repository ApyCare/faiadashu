// ignore_for_file: avoid_escaping_inner_quotes, unnecessary_brace_in_string_interps, unnecessary_string_interps, always_use_package_imports

import 'package:intl/intl.dart' as intl;
import 'fdash_localizations.g.dart';

/// The translations for French (`fr`).
class FDashLocalizationsFr extends FDashLocalizations {
  FDashLocalizationsFr([super.locale = 'fr']);

  @override
  String get validatorRequiredItem => 'Cette question doit être complétée.';

  @override
  String errorWrongQuizResponse() => 'La réponse est incorrecte.';

  @override
  String validatorMinLength(int minLength) {
    return intl.Intl.pluralLogic(
      minLength,
      locale: localeName,
      one: 'Entrez au moins un caractère.',
      other: 'Entrez au moins $minLength caractères.',
    );
  }

  @override
  String validatorMaxLength(int maxLength) {
    return intl.Intl.pluralLogic(
      maxLength,
      locale: localeName,
      other: 'Entrez jusqu\'à $maxLength caractères.',
    );
  }

  @override
  String get validatorUrl => 'Entrez une URL valide au format https://...';

  @override
  String get validatorRegExp => 'Entrez une réponse valide.';

  @override
  String validatorEntryFormat(String entryFormat) {
    return 'Entrez au format $entryFormat.';
  }

  @override
  String get validatorNan => 'Entrez un nombre valide.';

  @override
  String validatorMinValue(String minValue) {
    return 'Entrez une valeur de $minValue ou plus.';
  }

  @override
  String validatorMaxValue(String maxValue) {
    return 'Entrez une valeur jusqu\'à $maxValue.';
  }

  @override
  String get dataAbsentReasonAskedDeclined => 'Je choisis de ne pas répondre.';

  @override
  String get narrativePageTitle => 'Narratif';

  @override
  String get questionnaireGenericTitle => 'Questionnaire';

  @override
  String get questionnaireUnknownTitle => 'Sans titre';

  @override
  String get questionnaireUnknownPublisher => 'Éditeur inconnu';

  @override
  String get validatorDate => 'Entrez une date valide.';

  @override
  String get validatorTime => 'Entrez une heure valide.';

  @override
  String get validatorDateTime => 'Entrez une date et une heure valides.';

  @override
  String validatorMinOccurs(int minOccurs) {
    return intl.Intl.pluralLogic(
      minOccurs,
      locale: localeName,
      one: 'Sélectionnez au moins une option.',
      other: 'Sélectionnez $minOccurs options ou plus.',
    );
  }

  @override
  String validatorMaxOccurs(int maxOccurs) {
    return intl.Intl.pluralLogic(
      maxOccurs,
      locale: localeName,
      one: 'Sélectionnez jusqu\'à une option.',
      other: 'Sélectionnez jusqu\'à $maxOccurs options.',
    );
  }

  @override
  String validatorSingleSelectionOrSingleOpenString(Object openLabel) {
    return 'Sélectionnez une option ou entrez du texte libre dans "${openLabel}".';
  }

  @override
  String validatorMaxSize(String maxSize) {
    return 'Sélectionnez un fichier de moins de $maxSize.';
  }

  @override
  String validatorMimeTypes(String mimeTypes) {
    return 'Sélectionnez un fichier des types suivants : $mimeTypes.';
  }

  @override
  String get dataAbsentReasonAskedDeclinedInputLabel => 'Je choisis de ne pas répondre.';

  @override
  String get dataAbsentReasonAskedDeclinedOutput => 'A refusé de répondre';

  @override
  String get dataAbsentReasonAsTextOutput => '[COMME TEXTE]';

  @override
  String get autoCompleteSearchTermInput => 'Entrez un terme de recherche...';

  @override
  String get responseStatusToCompleteButtonLabel => 'Compléter';

  @override
  String get responseStatusToInProgressButtonLabel => 'Modifier';

  @override
  String get progressQuestionnaireLoading => 'Le questionnaire est en cours de chargement...';

  @override
  String get handlingSaveButtonLabel => 'Enregistrer';

  @override
  String get handlingUploadButtonLabel => 'Téléverser';

  @override
  String get handlingUploading => 'Téléversement du questionnaire...';

  @override
  String get loginStatusLoggingIn => 'Connexion en cours...';

  @override
  String get loginStatusLoggedIn => 'Connecté...';

  @override
  String get loginStatusLoggingOut => 'Déconnexion en cours...';

  @override
  String get loginStatusLoggedOut => 'Déconnecté...';

  @override
  String get loginStatusUnknown => 'Pas sûr de ce qui se passe ?';

  @override
  String get loginStatusError => 'Quelque chose s\'est mal passé.';

  @override
  String get handlingSaved => 'Questionnaire enregistrée.';

  @override
  String get handlingUploaded => 'Questionnaire téléversée.';

  @override
  String aggregationScore(Object score) {
    return 'Score : $score';
  }

  @override
  String get aggregationTotalScoreTitle => 'Score Total';

  @override
  String get fillerOpenCodingOtherLabel => 'Autre';

  @override
  String fillerAddAnotherItemLabel(Object itemLabel) {
    return 'Ajouter un autre "${itemLabel}"';
  }

  @override
  String get fillerExclusiveOptionLabel => '(exclusif)';
}
