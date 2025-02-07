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

  // The `favorites` property is initialized with an empty list of word pairs;
  // there can never be any unwanted objects (like `null`) in there:
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

// `MyHomePage` is a stateful widge, a type of widget that has `State`.
// This widget is the home page of your application:
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// The underscore _ at the start of `_MyHomePageState` makes that class private,
// and this is enforced by the compiler. This class extends `State`, and can therefore
// manage its own values; it can change itself.
class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  // Every widget defines a `build()` method that's automatically called every time
  // the widget's circumstances change so that the widget is always up to date:
  Widget build(BuildContext context) {
    // Declare a new variable `page` of the type `Widget`:
    Widget page;
    // The `switch` statement assigns a screen to `page`, according to
    // the current value in `selectedIndex`:
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
      // Applying the "fail-fast principle", the switch statement also makes sure
      // to throw an error if `selectedIndex` is neither 0 or 1, which is
      // really useful if you ever add a new destination to the navigation rail
      // and forget to update this code:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // `LayoutBuilder`'s builder callback is called every time the constraints change.
    // This happens for instance when tThe user resizes the app's window or
    // rotates their phone from portrait to landscape mode:
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          // `_MyHomePageState` contains a `Row` with 2 children:
          // a `SafeArea` widget and an `Expanded` widget:
          body: Row(
            children: [
              // The `SafeArea` ensures that its child is not obscured by a hardware notch
              // or a status bar. In this app, the widget wraps around `NavigationRail`
              // to prevent the navigation buttons from being obscured by a mobile status bar:
              SafeArea(
                child: NavigationRail(
                  // Boolean indicating if the labels next to the icons should be shown:
                  // (only show when screen is equal or wider than 600 (logical) pixels)
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  // A selected index of 0 selects the first destination,
                  // a selected index of 1 selects the second destination, and so on:
                  selectedIndex: selectedIndex,
                  // `NavigationRail` also defines what happens when the user selects one
                  // of the destinations with `onDestinationSelected`. When the
                  // `onDestinationSelected` callback is called, you assign the destination
                  // to `selectedIndex` inside a `setState()` call:
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              // `Expanded` widgets are extremely useful in rows and columns — they let you
              // express layouts where some children take only as much space as they need
              // (`SafeArea`, in this case) and other widgets should take as much of the
              // remaining room as possible (`Expanded`, in this case):
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page, // <- updates the current page based on the `selectedIndex`
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // `MyHomePage` tracks changes to the app's current state using the watch method:
    var appState = context.watch<MyAppState>();
    // Extract `appState`, and accesses the only member of that class,
    // `current` (which is a `WordPair`) into a separate variable for
    // use in the `BigCard` widget:
    var pair = appState.current;

    // Choose the appropriate "Like" icon depending on whether
    // the current word pair is already in favorites:
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    // Column is one of the most basic layout widgets in Flutter.
    // It takes any number of children and puts them in a column from top to bottom.
    // By default, the column visually places its children at the top.
    return Center( // <- This centers the `Column` itself
      child: Column(
        // This centers the children inside the Column along its main (vertical) axis:
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          // The `SizedBox` widget just takes space and doesn't render anything by itself.
          // It's commonly used to create visual "gaps":
          SizedBox(height: 10),
          Row(
            // This tells `Row` not to take all available horizontal space:
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // If the list of favorites is empty, show a centered message "No favorites yet":
    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    // Otherwise, show a (scrollable) list starting with a summary,
    // and then iterating through all favorites to construct a `ListTile`
    // widget with title and icon for each one:
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
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
