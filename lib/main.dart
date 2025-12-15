import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:princess_journey/screens/journey.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'globals.dart';
import 'screens/you.dart';
import 'screens/home.dart';
import 'models/user.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'i18n.dart';

User u = User(id: 0, hasTimer: true);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    Workmanager().initialize(callbackDispatcher);
    Workmanager().registerPeriodicTask("1", "updateAndManageNotifications",
        frequency: const Duration(minutes: 15),
        initialDelay: const Duration(seconds: 5),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        inputData: {'locale': Platform.localeName.split("_")[0]});
  }
  await App().init();
  if (App().prefs.remoteStorage) {
    u.persister = APIPersister(
      base: "${App().prefs.hostname}/api",
      token: App().prefs.token,
      targetId: App().prefs.userId,
    );
  }
  u.read();
  //CDateTime.customTime = DateTime(2021, 01, 26, 17, 28);
  runApp(
    ChangeNotifierProvider.value(
      value: u,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Princess Journey",
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.pink,
            elevation: 4,
            shadowColor: Theme.of(context).shadowColor,
          )),
      home: const MainPage(
        title: "Princess Journey",
      ),
      localizationsDelegates: const [
        MyLocalizationsDelegate(),
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
      ],
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  late PageController _pageController;

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
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
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
              Text(widget.title,
                  style: const TextStyle(color: Colors.pinkAccent))
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
            children: const <Widget>[
              Home(),
              Journey(),
              You(),
            ],
          )),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.today),
            label: MyLocalizations.of(context)?.tr("your_day"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore),
            label: MyLocalizations.of(context)?.tr("your_journey"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: MyLocalizations.of(context)?.tr("you"),
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

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Update views
    User user = User(
      id: 0,
    );
    await App().init();
    if (App().prefs.remoteStorage) {
      user.persister = APIPersister(
        base: "${App().prefs.hostname}/api",
        token: App().prefs.token,
        targetId: App().prefs.userId,
      );
    }
    await user.read();
    // Send notification when fasting period completed
    if (user.dailyFastingProgress == 1) {
      FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();
      var android =
          const AndroidInitializationSettings('@mipmap/notification_icon');
      var ios = const DarwinInitializationSettings();
      var settings = InitializationSettings(android: android, iOS: ios);
      flip.initialize(settings);
      _showNotificationWithDefaultSound(
          flip,
          MyLocalizations.localizedValue(
              inputData!["locale"], "fasting_completed"),
          MyLocalizations.localizedValue(
              inputData["locale"], "treat_yourself"));
    }
    return Future.value(true);
  });
}

Future _showNotificationWithDefaultSound(
    FlutterLocalNotificationsPlugin flip, String title, String message) async {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'princess-journey-id', 'princess-journey',
      channelDescription: 'princess-journey-channel',
      importance: Importance.max,
      priority: Priority.high,
      color: Colors.pink);
  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flip.show(0, title, message, platformChannelSpecifics,
      payload: 'Default_Sound');
}
