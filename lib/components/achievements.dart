import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:princess_journey/models/user.dart';

class Achievements extends StatefulWidget {
  @override
  _AchievementsState createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
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
                          leading: Icon(Icons.explore),
                          title: Text("Your journey so far..."),
                          subtitle: Text(
                              "Fasting for ${user.daysOfFasting} consecutives days.\n"
                              "Longest ever fasting is ${user.maxDaysOfFasting} consecutives days."))
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
                          leading: Icon(Icons.spa),
                          title: Text("The butterfly princess"),
                          subtitle:
                              Text("You've managed to fast for one day..."),
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
                          leading: Icon(Icons.weekend),
                          title: Text("The princess of nothing"),
                          subtitle: Text(
                              "You've managed to fast for 3 consecutives days..."),
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
                          leading: Icon(Icons.house_siding),
                          title: Text("The princess of the palace"),
                          subtitle:
                              Text("You've managed to fast for two weeks..."),
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
                          leading: Icon(Icons.alt_route),
                          title: Text("The princess of the path"),
                          subtitle:
                              Text("You've managed to fast for four weeks..."),
                        )
                      ])))
      ]);
    });
  }
}
