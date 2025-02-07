import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

// The code in MyApp sets up the whole app. It creates the app-wide state, names the app,
// defines the visual theme, and sets the "home" widget—the starting point of your app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Naming App',
        theme: ThemeData(
          // This is the theme of your application.
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// The `MyAppState` class defines the app's state using `ChangeNotifier`,
// one of the easiest ways to manage app state in Flutter:
// - MyAppState defines the data the app needs to function.
//   Right now, it only contains a single variable with the current random word pair.
// - It extends `ChangeNotifier`, which means that it can notify others about its own changes.
//   For example, if the current word pair changes, some widgets in the app need to know.
// - The state is created and provided to the whole app using a `ChangeNotifierProvider`
//   (see code above in MyApp). This allows any widget in the app to get hold of the state.
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  // The `getNext()` method reassigns current with a new random `WordPair`.
  // It also calls `notifyListeners()`(a method of `ChangeNotifier`) that ensures
  // that anyone watching `MyAppState` is notified.
  // It is called from `MyHomePage` `ElevatedButton`'s callback.
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  // This widget is the home page of your application.
  @override
  // Every widget defines a `build()` method that's automatically called every time
  // the widget's circumstances change so that the widget is always up to date:
  Widget build(BuildContext context) {
    // `MyHomePage` tracks changes to the app's current state using the watch method:
    var appState = context.watch<MyAppState>();

  // Every build method must return a widget or a nested tree of widgets. In this case,
  // the top-level widget is `Scaffold`, it's a helpful widget that is found in
  // the vast majority of real-world Flutter apps.
    return Scaffold(
      // Column is one of the most basic layout widgets in Flutter.
      // It takes any number of children and puts them in a column from top to bottom.
      // By default, the column visually places its children at the top.
      body: Column(
        children: [
          Text('A random awesome idea:'),
          // This second `Text` widget takes `appState`, and accesses the only member
          // of that class, `current` (which is a `WordPair`).
          // `WordPair` provides several helpful getters, such as `asUpperCase`,
          // `asPascalCase` or `asSnakeCase`. Here, we simply use `asLowerCase`.
          Text(appState.current.asLowerCase),
          ElevatedButton(
            onPressed: () {
              appState.getNext();
            },
            child: Text('Next'),
          ),
        ],
      ),
    );
  }
}
