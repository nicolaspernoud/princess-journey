import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:princess_journey/screens/journey.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'screens/you.dart';
import 'screens/home.dart';
import 'models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'i18n.dart';

User u = User(hasTimer: true);

main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager.initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager.registerPeriodicTask("1", "updateAndManageNotifications",
      frequency: Duration(minutes: 15),
      initialDelay: Duration(seconds: 5),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      inputData: {'locale': Platform.localeName.split("_")[0]});

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
      localizationsDelegates: [
        const MyLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('fr', ''),
      ],
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            children: <Widget>[
              Home(),
              Journey(),
              You(),
            ],
          )),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: MyLocalizations.of(context).tr("your_day"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: MyLocalizations.of(context).tr("your_journey"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: MyLocalizations.of(context).tr("you"),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        u.stopTimer();
        break;
      default:
        u.startTimer();
    }
  }
}

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    // Update views
    User user = User();
    await user.readUser();
    // Send notification when fasting period completed
    if (user.dailyFastingProgress == 1) {
      FlutterLocalNotificationsPlugin flip =
          new FlutterLocalNotificationsPlugin();
      var android =
          new AndroidInitializationSettings('@mipmap/notification_icon');
      var ios = new IOSInitializationSettings();
      var settings = new InitializationSettings(android: android, iOS: ios);
      flip.initialize(settings);
      _showNotificationWithDefaultSound(
          flip,
          MyLocalizations.localizedValue(
              inputData["locale"], "fasting_completed"),
          MyLocalizations.localizedValue(
              inputData["locale"], "treat_yourself"));
    }
    return Future.value(true);
  });
}

Future _showNotificationWithDefaultSound(
    flip, String title, String message) async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'princess-journey-id', 'princess-journey', 'princess-journey-channel',
      importance: Importance.max, priority: Priority.high, color: Colors.pink);
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flip.show(0, title, message, platformChannelSpecifics,
      payload: 'Default_Sound');
}
