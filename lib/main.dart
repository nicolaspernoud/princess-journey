import 'package:flutter/material.dart';
import 'package:princess_journey/screens/journey.dart';
import 'package:provider/provider.dart';
import 'screens/you.dart';
import 'screens/home.dart';
import 'models/user.dart';
import 'package:flutter/foundation.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  User u = User(hasTimer: true);
  u.readUser();
  //CDateTime.customTime = DateTime(2021, 01, 26, 17, 28);
  runApp(
    ChangeNotifierProvider.value(
      value: u,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Princess Journey",
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(title: "Princess Journey"),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var main = (int id) {
      switch (id) {
        case 0:
          {
            return Home();
          }
          break;
        case 1:
          {
            return Journey();
          }
          break;
        default:
          {
            return You();
          }
          break;
      }
    }(_selectedIndex);
    var scaffold = Scaffold(
      appBar: AppBar(
          //title: Text(widget.title, style: TextStyle(color: Colors.pinkAccent)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon/icon.png',
                fit: BoxFit.contain,
                height: 32,
              ),
              const SizedBox(width: 8),
              Container(
                  child: Text("${widget.title}",
                      style: TextStyle(color: Colors.pinkAccent)))
            ],
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.pink),
      body: Center(
          child: Padding(padding: const EdgeInsets.all(10), child: main)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Your day',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Your journey',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'You',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
    return scaffold;
  }
}
