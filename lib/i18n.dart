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
    "en": {
      "butterfly_princess_details": "You've managed to fast for one day...",
      "butterfly_princess": "The butterfly princess",
      "cancel": "CANCEL",
      "cannot_load_users":
          "Server configuration error, data will not be saved.",
      "create_fasting_period":
          "Create a fasting period by tapping the button below",
      "create": "Create",
      "custom_intake": "Custom intake",
      "edit": "Edit",
      "failure": "Failure",
      "fasting_completed": "Fasting completed !",
      "female": "Female",
      "hostname": "Hostname",
      "journey_so_far": "Your journey so far...",
      "loading_users": "Loading user...",
      "male": "Male",
      "not_a_failure_details":
          "You've once managed to attain your target weight, keep up your efforts to stay below. Most beautiful journeys haves curvy paths...",
      "not_a_failure": "Not a failure !",
      "not_an_end_details":
          "You've managed to attain your desired weight. It is not the end of your journey, but the beginning of your new life...",
      "not_an_end": "Not an end, but a beginning",
      "princess_of_nothing_details":
          "You've managed to fast for 3 consecutives days...",
      "princess_of_nothing": "The princess of nothing",
      "princess_of_the_palace_details":
          "You've managed to fast for two weeks...",
      "princess_of_the_palace": "The princess of the palace",
      "princess_of_the_path_details":
          "You've managed to fast for four weeks...",
      "princess_of_the_path": "The princess of the path",
      "remote_storage": "Store data on remote server",
      "remote_user_id": "Remote user ID",
      "select_duration": "Select the fasting duration",
      "success": "Success",
      "taking_break": "Taking a break from the fasting...",
      "tell_us": "Tell us about you...",
      "the_begining": "The begining of your new life...",
      "token": "Security token",
      "treat_yourself": "Treat yourself with a nice balanced meal...",
      "user": "User",
      "weight_is_too_different":
          "Weight is too different from previous value...",
      "what_did_you_drink": "What did you drink today ?",
      "you": "You",
      "your_bmi": "Your body mass index...",
      "your_daily_water_goal": "Your daily water intake goal (mL) ",
      "your_day": "Your day",
      "your_desired_weight": "Your desired weight (kg)",
      "your_gender": "Your gender",
      "your_height": "Your height (cm)",
      "your_journey": "Your journey",
      "your_water_intake": "Your water intake...",
      "your_weight_kg": "Your weight (kg)",
      "your_weight": "Your weight...",
    },
    "fr": {
      "butterfly_princess_details": "Vous avez réussi à jeûner un jour...",
      "butterfly_princess": "La princesse papillon",
      "cancel": "ANNULER",
      "cannot_load_users":
          "Erreur de configuration serveur : les données ne seront pas sauvegardées.",
      "create_fasting_period":
          "Démarrez une période de jeûne en utilisant le bouton ci dessous",
      "create": "Démarrer",
      "custom_intake": "autre quantité",
      "edit": "Modifier",
      "failure": "Paupietterie",
      "fasting_completed": "Jeûne terminé !",
      "female": "Femme",
      "hostname": "Nom du serveur",
      "journey_so_far": "Votre voyage à ce jour...",
      "loading_users": "Chargement des utilisateurs...",
      "male": "Homme",
      "not_a_failure_details":
          "Vous avez déjà réussi à atteindre votre poids cible, mais êtes repassé au dessus. Continuez vos efforts : les plus beau voyages empruntent des chemins avec quelques courbes...",
      "not_a_failure": "Ce n'est pas un échec !",
      "not_an_end_details":
          "Vous avez réussi à atteindre votre poids cible. Ce n'est pas la fin de votre voyage, mais le début de votre nouvelle vie...",
      "not_an_end": "Pas une fin, mais un début",
      "princess_of_nothing_details":
          "Vous avez réussi à jeûner pendant 3 jours consécutifs...",
      "princess_of_nothing": "La princesse de rien",
      "princess_of_the_palace_details":
          "Vous avez réussi à jeûner deux semaines consécutives...",
      "princess_of_the_palace": "La princesse du palais",
      "princess_of_the_path_details":
          "Vous avez réussi à jeûner quatre semaines consécutives...",
      "princess_of_the_path": "La princesse du chemin",
      "remote_storage": "Stocker les données sur un serveur distant",
      "remote_user_id": "ID de l'utilisateur distant",
      "select_duration": "Choisissez la durée du jeûne",
      "success": "Succès",
      "taking_break": "Période d'alimentation...",
      "tell_us": "Quelques mots sur vous...",
      "the_begining": "Le début de votre nouvelle vie...",
      "token": "Jeton de sécurité",
      "treat_yourself": "Faites vous plaisir avec un bon repas équilibré...",
      "user": "Utilisateur",
      "weight_is_too_different":
          "Le poids est trop différent du poids précédent...",
      "what_did_you_drink": "Qu'avez vous bu aujourd'hui ?",
      "you": "Vous",
      "your_bmi": "Votre indice de masse corporelle...",
      "your_daily_water_goal": "Votre apport en eau quotidien (mL) ",
      "your_day": "Votre journée",
      "your_desired_weight": "Votre poids souhaité (kg)",
      "your_gender": "Votre sexe",
      "your_height": "Votre taille (cm)",
      "your_journey": "Votre voyage",
      "your_water_intake": "Votre apport en eau...",
      "your_weight_kg": "Votre poids (kg)",
      "your_weight": "Votre poids...",
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
      return "Depuis ${df.format(user!.activeFastingPeriod!.start)}\n${fastingHoursEnd(user.activeFastingPeriod!.end)}";
    }
    final df = DateFormat("yyyy-MM-dd HH:mm");
    return "From ${df.format(user!.activeFastingPeriod!.start)}\n${fastingHoursEnd(user.activeFastingPeriod!.end)}";
  }

  String fastingHoursEnd(DateTime end) {
    if (locale.languageCode == 'fr') {
      final df = DateFormat("HH:mm le dd/MM/yyyy ");
      return "Jusqu'à ${df.format(end)}";
    }
    final df = DateFormat("yyyy-MM-dd HH:mm");
    return "Until ${df.format(end)}";
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
