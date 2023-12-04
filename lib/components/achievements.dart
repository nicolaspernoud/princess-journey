import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:princess_journey/models/user.dart';

import '../i18n.dart';

class Achievements extends StatefulWidget {
  const Achievements({super.key});

  @override
  AchievementsState createState() => AchievementsState();
}

class AchievementsState extends State<Achievements> {
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(builder: (context, user, child) {
      return Column(children: [
        Card(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ListTile(
                          leading: const Icon(Icons.explore),
                          title: Text(MyLocalizations.of(context)!
                              .tr("journey_so_far")),
                          subtitle: Text(MyLocalizations.of(context)!
                              .journeySoFarDetails(
                                  user.daysOfFasting, user.maxDaysOfFasting)))
                    ]))),
        if (user.maxDaysOfFasting >= 1)
          Card(
              color: Colors.amber,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.spa),
                          title: Text(MyLocalizations.of(context)!
                              .tr("butterfly_princess")),
                          subtitle: Text(MyLocalizations.of(context)!
                              .tr("butterfly_princess_details")),
                        )
                      ]))),
        if (user.maxDaysOfFasting >= 3)
          Card(
              color: Colors.blueAccent,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.weekend),
                          title: Text(MyLocalizations.of(context)!
                              .tr("princess_of_nothing")),
                          subtitle: Text(MyLocalizations.of(context)!
                              .tr("princess_of_nothing_details")),
                        )
                      ]))),
        if (user.maxDaysOfFasting >= 14)
          Card(
              color: Colors.lightGreen,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.house_siding),
                          title: Text(MyLocalizations.of(context)!
                              .tr("princess_of_the_palace")),
                          subtitle: Text(MyLocalizations.of(context)!
                              .tr("princess_of_the_palace_details")),
                        )
                      ]))),
        if (user.maxDaysOfFasting >= 28)
          Card(
              color: Colors.purple,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.alt_route),
                          title: Text(MyLocalizations.of(context)!
                              .tr("princess_of_the_path")),
                          subtitle: Text(MyLocalizations.of(context)!
                              .tr("princess_of_the_path_details")),
                        )
                      ]))),
        if (user.weight > 0 && user.weight <= user.targetWeight)
          Card(
              color: Colors.pink[100],
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.favorite),
                          title: Text(
                              MyLocalizations.of(context)!.tr("not_an_end")),
                          subtitle: Text(MyLocalizations.of(context)!
                              .tr("not_an_end_details")),
                        )
                      ]))),
        if (user.weight > user.targetWeight &&
            user.lesserWeight <= user.targetWeight)
          Card(
              color: Colors.pink[100],
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.favorite_border),
                          title: Text(
                              MyLocalizations.of(context)!.tr("not_a_failure")),
                          subtitle: Text(MyLocalizations.of(context)!
                              .tr("not_a_failure_details")),
                        )
                      ])))
      ]);
    });
  }
}
