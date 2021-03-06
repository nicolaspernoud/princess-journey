import 'package:flutter/material.dart';
import 'package:princess_journey/components/mermaid.dart';
import 'package:princess_journey/components/princess.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [Princess(), Mermaid()]);
  }
}
