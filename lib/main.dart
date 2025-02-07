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
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(0, 255, 0, 1.0)),
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
    // Extract `appState`, and accesses the only member of that class,
    // `current` (which is a `WordPair`) into a separate variable for
    // use in the `BigCard` widget:
    var pair = appState.current;

  // Every build method must return a widget or a nested tree of widgets. In this case,
  // the top-level widget is `Scaffold`, it's a helpful widget that is found in
  // the vast majority of real-world Flutter apps.
    return Scaffold(
      // Column is one of the most basic layout widgets in Flutter.
      // It takes any number of children and puts them in a column from top to bottom.
      // By default, the column visually places its children at the top.
      body: Center( // <- This centers the `Column` itself
        child: Column(
          // This centers the children inside the Column along its main (vertical) axis:
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Here's a random name:"),
            // The `SizedBox` widget just takes space and doesn't render anything by itself.
            // It's commonly used to create visual "gaps":
            SizedBox(height: 30),
            BigCard(pair: pair),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                appState.getNext();
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // `theme.textTheme` accesses the app's font theme:
    // - This class includes members such as `bodyMedium` (for standard
    //   text of medium size), `caption` (for captions of images),
    //   or `headlineLarge` (for large headlines).
    // - The `displayMedium` property is a large style meant for display text.
    //   The word display is used in the typographic sense here, such as in
    //   display typeface. The documentation for `displayMedium` says that
    //   "display styles are reserved for short, important text".
    // - The theme's `displayMedium` property could theoretically be null.
    //   Dart is null-safe, so it won't let you call methods of objects that
    //   are potentially null. In this case though, you can use the ! operator
    //   ("bang operator") to assure Dart `displayMedium` is not null here.
    // - Calling `copyWith()` on `displayMedium` returns a copy of the text
    //   style with the changes you define. In this case, you're only changing
    //   the text's color.
    final style = theme.textTheme.displayMedium!.copyWith(
      // The `colorScheme`'s onPrimary property defines a color that is
      // a good fit for use on the app's primary color:
      color: theme.colorScheme.onPrimary,
    );


    return Card(
      // The `colorScheme` property contains many colors, and `primary`
      // is the most prominent, defining color of the app:
      color: theme.colorScheme.primary,
      child: Padding(
        // Flutter uses Composition over Inheritance whenever it can.
        // Here, instead of padding being an attribute of Text, it's a widget!
        // This way, widgets can focus on their single responsibility, such that
        // the developer has total freedom in how to compose the UI.
        // For example, you can use the `Padding` widget to pad text, images,
        // buttons, your own custom widgets, or the whole app.
        // The widget doesn't care what it's wrapping.
        padding: const EdgeInsets.all(20),
        // The pair `WordPair` provides several helpful getters, such as `asUpperCase`,
        // `asPascalCase` or `asSnakeCase`. Here, we simply use `asLowerCase`:
        child: Text(
          pair.asLowerCase,
          style: style,
          // `semanticsLabel` should replace the default text,
          // but doesn't seem to be working:
          semanticsLabel: '${pair.first} ${pair.second}',
        ),
      ),
    );
  }
}
