# Explication du fonctionnement du Package `faiadashu`

Ce document a pour but d'expliquer l'architecture et le fonctionnement du package Flutter `faiadashu`, afin qu'un développeur puisse comprendre comment l'utiliser, le modifier et l'étendre.

## 1. Qu'est-ce que `faiadashu` ?

`faiadashu` (prononcé "FHIR-Dash") est une bibliothèque de **widgets Flutter** conçue pour créer des applications de santé rapidement. Son objectif principal est de **fournir une interface utilisateur prête à l'emploi pour afficher et remplir des questionnaires médicaux** basés sur le standard international **HL7® FHIR®**.

En bref, si vous avez une ressource `Questionnaire` FHIR, ce package vous permet de la transformer en une interface utilisateur interactive dans votre application Flutter avec très peu de code.

## 2. Concepts Clés et Utilisation

Pour utiliser ce package, il faut comprendre deux concepts de base de FHIR :

*   **`Questionnaire`**: C'est une ressource FHIR qui définit une série de questions. Elle décrit la structure, le texte, les types de réponses attendues (texte, choix, date, etc.) et la logique de base (comme les conditions d'affichage d'une question).
*   **`QuestionnaireResponse`**: C'est une autre ressource FHIR qui contient les réponses d'un patient à un `Questionnaire` spécifique.

Le package `faiadashu` fournit un widget qui prend un `Questionnaire` en entrée et produit un `QuestionnaireResponse` en sortie.

### Comment l'utiliser : Exemple de base

Le widget principal que vous utiliserez est le `QuestionnaireFiller`. Voici un exemple minimaliste de son utilisation dans une page Flutter :

```dart
import 'package:faiadashu/faiadashu.dart';
import 'package:faiadashu/questionnaires/questionnaires.dart';
import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';

// Un ResourceProvider est nécessaire pour charger des ressources FHIR
// comme les ValueSets, etc. Ici, un provider vide pour l'exemple.
final resourceProvider = QuestionnaireResourceProvider.inMemory({});

class QuestionnairePage extends StatelessWidget {
  final Questionnaire questionnaire;

  const QuestionnairePage({super.key, required this.questionnaire});

  @override
  Widget build(BuildContext context) {
    return QuestionnaireScrollerPage(
      // Le QuestionnaireScrollerPage fournit un Scaffold de base
      questionnaire: questionnaire,
      resourceProvider: resourceProvider,
      onCompleted: (questionnaireResponse) {
        // Callback appelé quand l'utilisateur termine le questionnaire.
        // Vous pouvez ici sauvegarder ou envoyer le QuestionnaireResponse.
        print(questionnaireResponse.toJson());
        Navigator.pop(context);
      },
    );
  }
}
```

**Que fait ce code ?**
1.  Il crée un `QuestionnaireScrollerPage`, qui est une page pré-construite contenant un `Scaffold` et un `AppBar`.
2.  Il utilise un `QuestionnaireFiller` en interne pour afficher les questions du `questionnaire` fourni.
3.  L'utilisateur peut faire défiler (`Scroller`) toutes les questions.
4.  Un bouton "Terminer" est automatiquement ajouté. Lorsqu'il est pressé, le `onCompleted` callback est déclenché, vous donnant accès au `QuestionnaireResponse` rempli par l'utilisateur.

---

## 3. Architecture Détaillée

Le package est structuré pour séparer clairement les responsabilités, ce qui le rend plus maintenable et plus facile à comprendre.

### Structure du Projet (`lib/`)

Voici le rôle des principaux répertoires dans `lib/` :

*   `questionnaires/` : Le cœur du package. Contient toute la logique et les widgets pour les questionnaires.
    *   `model/` : La logique métier. Gère l'état du `QuestionnaireResponse` en mémoire, la validation des réponses, le calcul des scores, l'évaluation des expressions `FHIRPath`, etc. **Cette partie ne contient aucun code Flutter d'interface utilisateur.**
    *   `view/` : La couche de présentation. Contient tous les widgets Flutter pour afficher les questionnaires, les groupes, et chaque type de question (`item`). C'est ici que `QuestionnaireFiller` et `QuestionnaireScroller` sont définis.
*   `resource_provider/` : Un système simple pour charger des ressources FHIR (comme des `ValueSet` ou des `CodeSystem` qui peuvent être nécessaires pour répondre à certaines questions). `QuestionnaireResourceProvider.inMemory` est utile pour les tests, tandis que vous pourriez implémenter votre propre provider pour charger depuis une API REST FHIR.
*   `fhir_types/` : Contient des widgets ou des formateurs pour des types de données FHIR spécifiques qui ne sont pas des questions, comme l'affichage d'une date (`FhirDateTimeText`) ou la prévisualisation d'une pièce jointe.
*   `observations/` : Contient des widgets pour afficher des ressources `Observation` FHIR, qui sont souvent le résultat d'un questionnaire rempli.
*   `l10n/` : Gère l'internationalisation (i18n) du package. Les textes de l'interface (comme les boutons "Suivant", "Précédent") sont définis ici en plusieurs langues.
*   `logging/` : Un simple wrapper autour du package `logging` de Dart pour un logging unifié.

### Diagramme d'Architecture Simplifié

```mermaid
graph TD
    subgraph "Application Flutter"
        A[Votre Page]
    end

    subgraph "Package faiadashu"
        B(QuestionnaireFiller)
        C{Modèle de Données}
        D{Vue (Widgets)}
        E[Logique FHIRPath / Validation]
        F[Widgets par type de question]
        G{Resource Provider}
    end

    subgraph "Serveur / Données"
      H(API FHIR)
      I(Fichiers locaux)
    end

    A -- "utilise" --> B
    B --> C & D
    C --> E
    D --> F
    B --> G
    G -- "charge depuis" --> H & I
```

Cette architecture permet de :
1.  **Tester la logique métier** (le modèle) sans avoir besoin de lancer une application Flutter complète.
2.  **Personnaliser entièrement l'interface utilisateur** en créant vos propres widgets dans la couche "Vue" sans avoir à toucher à la logique de gestion du questionnaire.

### Logique Spécifique : Le mode "Quiz"
En plus de la logique de formulaire classique, le package gère une logique de "quiz". La distinction est **implicite** et se base sur la manière dont vous structurez les **scores** des réponses dans la ressource `Questionnaire` FHIR, via une extension `ordinalValue`.

C'est la **somme des scores (`ordinalValue`)** pour les options de réponse d'une question qui détermine son comportement :

#### Mode Quiz : `Somme des scores == 1`
Une question est traitée comme un quiz si la somme des `ordinalValue` de ses réponses est **exactement égale à 1**.
- **Configuration** : Dans votre `Questionnaire` FHIR, attribuez `ordinalValue: 1` à la bonne réponse et `0` (ou rien) aux mauvaises.
- **Comportement** : Si l'utilisateur choisit une réponse autre que celle avec le score de 1, une erreur de validation `WrongQuizResponseError` est déclenchée, affichant "La réponse est incorrecte."

#### Mode Questionnaire Classique (avec ou sans score)
- **Questionnaire à score (`Somme > 1`)** : Si la somme des `ordinalValue` est supérieure à 1 (par exemple, pour une échelle de 0 à 3), le système additionne les points sans considérer de réponse comme "fausse". C'est le comportement attendu pour les échelles médicales (PHQ-9, etc.).
- **Questionnaire sans score** : Si vous n'utilisez pas l'extension `ordinalValue`, aucune logique de score ou de quiz n'est appliquée.

| | **Mode Quiz** | **Mode Questionnaire à Score** | **Mode Questionnaire Classique** |
| :--- | :--- | :--- | :--- |
| **Condition** | La somme des `ordinalValue` est **égale à 1** | La somme des `ordinalValue` est **supérieure à 1** | Pas d'`ordinalValue` |
| **Objectif** | Valider une réponse (vrai/faux) | Calculer un score total | Collecter des données |
| **Validation** | Erreur si la réponse n'a pas le score `1` | Pas d'erreur de "bonne/mauvaise" réponse | Validation de base (obligatoire, etc.) |

## 4. Personnalisation et Outils

### Personnalisation de l'Apparence

Le moyen le plus simple de personnaliser l'apparence des questionnaires est d'utiliser le widget `QuestionnaireTheme`. Il s'agit d'un `InheritedWidget` (similaire au `Theme` de base de Flutter) qui vous permet de définir des styles spécifiques pour les différents éléments du questionnaire.

**Exemple :**
```dart
@override
Widget build(BuildContext context) {
  return QuestionnaireTheme(
    data: const QuestionnaireThemeData(
      questionnaireTitleStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
      // ... autres propriétés de style
    ),
    child: QuestionnaireScrollerPage(
      // ...
    ),
  );
}
```

### Outils de Développement (`tool/`)

Le répertoire `tool/` contient des scripts shell utiles pour la maintenance du package :
*   `generate_localizations.sh`: Ce script exécute la commande Flutter pour générer le code Dart à partir des fichiers de traduction (`.arb`) situés dans `lib/l10n/arb/`. Vous devez l'exécuter chaque fois que vous modifiez ou ajoutez des traductions.
*   `create_diagrams.sh`: Probablement utilisé pour générer des diagrammes pour la documentation (non essentiel pour l'utilisation du package).
*   `publish_pubdev.sh`: Un script pour automatiser la publication du package sur `pub.dev`, le dépôt de packages Dart.
*   `upgrade_packages.sh`: Met à jour toutes les dépendances du projet vers leurs dernières versions compatibles.

## 5. Points d'Attention pour les Développeurs

### Performances
Pour les questionnaires très longs et complexes (plusieurs centaines de questions, avec beaucoup de logique conditionnelle), le mode `QuestionnaireScroller` (qui rend tout d'un coup) peut potentiellement avoir un impact sur les performances de rendu initial. Le mode `QuestionnaireStepper` (qui rend page par page) est généralement plus performant dans ces cas-là.

### Dépendance à la version de FHIR
Le package dépend d'une version spécifique du package `fhir` (`^0.12.0` au moment de l'écriture). Cela signifie qu'il est conçu pour fonctionner avec une version spécifique de la spécification FHIR (probablement R4). Si votre projet utilise une autre version majeure de FHIR (comme R5 ou STU3), des problèmes de compatibilité surviendront.

### Extensibilité et Questions non supportées
Le package vise à supporter la majorité des types de questions définis par la spécification FHIR. Cependant, si vous utilisez des profils FHIR très spécifiques ou des extensions (`extension`) pour définir des types de questions non standards, le rendu par défaut pourrait ne pas fonctionner (`BrokenQuestionnaireItem`).
Pour supporter un nouveau type de question, il faudrait :
1.  Créer un nouveau widget dans la couche `view`.
2.  Modifier le `QuestionnaireItemFiller`, qui est le widget responsable de choisir le bon sous-widget en fonction du type de la question.

### Logique complexe et `FHIRPath`
Le package utilise `fhir_path` pour évaluer les expressions FHIRPath (utilisées pour la visibilité des questions, les calculs, etc.). Bien que puissant, le débogage d'expressions FHIRPath complexes peut être difficile. Il est recommandé de tester ces expressions de manière isolée.
