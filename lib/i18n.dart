import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:intl/intl.dart';

import 'models/user.dart';

class MyLocalizations {
  MyLocalizations(this.locale);

  final Locale locale;

  static MyLocalizations? of(BuildContext context) {
    return Localizations.of<MyLocalizations>(context, MyLocalizations);
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'cancel': 'CANCEL',
      'your_day': 'Your day',
      'your_journey': 'Your journey',
      'you': 'You',
      'journey_so_far': 'Your journey so far...',
      'fasting_completed': 'Fasting completed !',
      'treat_yourself': 'Treat yourself with a nice balanced meal...',
      'butterfly_princess': 'The butterfly princess',
      'butterfly_princess_details': "You've managed to fast for one day...",
      'princess_of_nothing': 'The princess of nothing',
      'princess_of_nothing_details':
          "You've managed to fast for 3 consecutives days...",
      'princess_of_the_palace': 'The princess of the palace',
      'princess_of_the_palace_details':
          "You've managed to fast for two weeks...",
      'princess_of_the_path': 'The princess of the path',
      'princess_of_the_path_details':
          "You've managed to fast for four weeks...",
      'not_an_end': 'Not an end, but a beginning',
      'not_an_end_details':
          "You've managed to attain your desired weight. It is not the end of your journey, but the beginning of your new life...",
      'not_a_failure': "Not a failure !",
      'not_a_failure_details':
          "You've once managed to attain your target weight, keep up your efforts to stay below. Most beautiful journeys haves curvy paths...",
      "what_did_you_drink": "What did you drink today ?",
      "custom_intake": 'Custom intake',
      "select_duration": 'Select the fasting duration',
      "taking_break": "Taking a break from the fasting...",
      "create_fasting_period":
          'Create a fasting period by tapping the button below',
      "create": "Create",
      "edit": "Edit",
      "success": "Success",
      "failure": "Failure",
      "the_begining": "The begining of your new life...",
      "your_weight": "Your weight...",
      "your_bmi": "Your body mass index...",
      "your_water_intake": "Your water intake...",
      "tell_us": "Tell us about you...",
      "your_gender": "Your gender",
      "male": "Male",
      "female": "Female",
      "your_height": "Your height (cm)",
      "your_weight_kg": "Your weight (kg)",
      "your_desired_weight": "Your desired weight (kg)",
      "your_daily_water_goal": "Your daily water intake goal (mL) ",
      "remote_storage": "Store data on remote server",
      "hostname": "Hostname",
      "token": "Security token",
      "remote_user_id": "Remote user ID",
      "user": "User",
      "loading_users": "Loading user...",
      "cannot_load_users": "Server configuration error, data will not be saved."
    },
    'fr': {
      'cancel': 'ANNULER',
      'your_day': 'Votre journée',
      'your_journey': 'Votre voyage',
      'you': 'Vous',
      'journey_so_far': 'Votre voyage à ce jour...',
      'fasting_completed': 'Jeûne terminé !',
      'treat_yourself': 'Faites vous plaisir avec un bon repas équilibré...',
      'butterfly_princess': 'La princesse papillon',
      'butterfly_princess_details': "Vous avez réussi à jeûner un jour...",
      'princess_of_nothing': 'La princesse de rien',
      'princess_of_nothing_details':
          "Vous avez réussi à jeûner pendant 3 jours consécutifs...",
      'princess_of_the_palace': 'La princesse du palais',
      'princess_of_the_palace_details':
          "Vous avez réussi à jeûner deux semaines consécutives...",
      'princess_of_the_path': 'La princesse du chemin',
      'princess_of_the_path_details':
          "Vous avez réussi à jeûner quatre semaines consécutives...",
      'not_an_end': 'Pas une fin, mais un début',
      'not_an_end_details':
          "Vous avez réussi à atteindre votre poids cible. Ce n'est pas la fin de votre voyage, mais le début de votre nouvelle vie...",
      'not_a_failure': "Ce n'est pas un échec !",
      'not_a_failure_details':
          "Vous avez déjà réussi à atteindre votre poids cible, mais êtes repassé au dessus. Continuez vos efforts : les plus beau voyages empruntent des chemins avec quelques courbes...",
      "what_did_you_drink": "Qu'avez vous bu aujourd'hui ?",
      "custom_intake": 'autre quantité',
      "select_duration": 'Choisissez la durée du jeûne',
      "taking_break": "Période d'alimentation...",
      "create_fasting_period":
          'Démarrez une période de jeûne en utilisant le bouton ci dessous',
      "create": "Démarrer",
      "edit": "Modifier",
      "success": "Succès",
      "failure": "Paupietterie",
      "the_begining": "Le début de votre nouvelle vie...",
      "your_weight": "Votre poids...",
      "your_bmi": "Votre indice de masse corporelle...",
      "your_water_intake": "Votre apport en eau...",
      "tell_us": "Quelques mots sur vous...",
      "your_gender": "Votre sexe",
      "male": "Homme",
      "female": "Femme",
      "your_height": "Votre taille (cm)",
      "your_weight_kg": "Votre poids (kg)",
      "your_desired_weight": "Votre poids souhaité (kg)",
      "your_daily_water_goal": "Votre apport en eau quotidien (mL) ",
      "remote_storage": "Stocker les données sur un serveur distant",
      "hostname": "Nom du serveur",
      "token": "Jeton de sécurité",
      "remote_user_id": "ID de l'utilisateur distant",
      "user": "Utilisateur",
      "loading_users": "Chargement des utilisateurs...",
      "cannot_load_users":
          "Erreur de configuration serveur : les données ne seront pas sauvegardées."
    },
  };

  String tr(String token) {
    return _localizedValues[locale.languageCode]![token] ?? token;
  }

  static String localizedValue(String locale, String token) {
    final lcl = ['en', 'fr'].contains(locale) ? locale : 'en';
    return _localizedValues[lcl]![token] ?? token;
  }

  String journeySoFarDetails(int days, int maxDays) {
    if (locale.languageCode == 'fr') {
      return "Vous jeûnez depuis $days jours consécutifs.\n"
          "Votre record est de $maxDays jours consécutifs.";
    }
    return "Fasting for $days consecutives days.\n"
        "Longest ever fasting is $maxDays consecutives days.";
  }

  String fastingHours(User? user) {
    if (locale.languageCode == 'fr') {
      return "Jeûne de ${user?.activeFastingPeriod?.duration ?? ""} heures...";
    }
    return "Fasting ${user?.activeFastingPeriod?.duration ?? ""} hours...";
  }

  String fastingHoursDetails(User? user) {
    if (locale.languageCode == 'fr') {
      final df = DateFormat("HH:mm le dd/MM/yyyy ");
      return "Depuis ${df.format(user!.activeFastingPeriod!.start)}\nJusqu'à ${df.format(user.activeFastingPeriod!.end)}";
    }
    final df = DateFormat("yyyy-MM-dd HH:mm");
    return "From ${df.format(user!.activeFastingPeriod!.start)}\nUntil ${df.format(user.activeFastingPeriod!.end)}";
  }

  String nextFastingPeriod(User user) {
    if (locale.languageCode == 'fr') {
      final df = DateFormat("HH:mm le dd/MM/yyyy ");
      return "Votre prochain jeûne pourrait démarrer à ${df.format(user.fastingPeriods.last.start.add(const Duration(days: 1)))}";
    }
    final df = DateFormat("yyyy-MM-dd HH:mm");
    return "Your next fasting period should start at ${df.format(user.fastingPeriods.last.start.add(const Duration(days: 1)))}";
  }
}

class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  const MyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<MyLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async 'load' operation
    // isn't needed to produce an instance of MyLocalizations.
    return SynchronousFuture<MyLocalizations>(MyLocalizations(locale));
  }

  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;
}
