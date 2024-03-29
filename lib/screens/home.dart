import 'package:flutter/material.dart';
import 'package:princess_journey/components/mermaid.dart';
import 'package:princess_journey/components/princess.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: const [Princess(), Mermaid()]);
  }
}
