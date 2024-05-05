import 'package:flutter/material.dart';
import 'package:kittkatflutterlibrary/lang/kkfl_lang.dart';
import 'package:kittkatflutterlibrary/theming/kkfl_theming.dart';
import 'package:kittkatflutterlibrary/widgets/kkfl_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quizflip/src/app_data.dart';
import 'package:quizflip/src/flashcard.dart';
import 'package:quizflip/src/persistant.dart';
import 'package:quizflip/src/widgets/overview_page.dart';
import 'src/pref_storage.dart';
import 'src/lang/en_us.dart' as en_us;

void main() async {
  await initialize();
  runApp(ThemedWidget(theme: theme, widget: const QuizFlip()));
}

/// This initialized some important stuff, that needs to be loaded before the main part of the app
/// loads.
Future<void> initialize() async {
  // Ensure flutter bindings, used for shared preferences.
  WidgetsFlutterBinding.ensureInitialized();

  // Wait for shared preferences to load.
  await initializePrefs();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  appVersion = "${packageInfo.version}+${packageInfo.buildNumber}";

  // Set language.
  setLangMap(en_us.getLangMap);

  // Set aspect ratio.
  Aspect.aspectWidth = 3;
  Aspect.aspectHeight = 4;

  // Load in app data.
  loadAppData();

  CardList.setCards(loadFlashcards());

  // If there are no prexisting cards, or something was saved incorrectly and not saved as a String,
  // create the list of introduction flashcards.
  if (CardList.cards.isEmpty) {
    // List of new flashcards to be added.
    List<Flashcard> newCards = [
      // Flashcard for how to make a new card.
      Flashcard(
        key: getLang('introcard_how_to_new_card'),
        deck: '/introduction/',
        values: [getLang('introcard_how_to_new_card_answer')],
      ),
      // Flashcard for how to sort cards.
      Flashcard(
        key: getLang('introcard_how_to_sort_cards'),
        deck: '/introduction/',
        values: [getLang('introcard_how_to_sort_cards_answer')],
      ),
      // Flashcard for how to practice the flashcards.
      Flashcard(
        key: getLang('introcard_how_to_practice'),
        deck: '/introduction/',
        values: [getLang('introcard_how_to_practice_answer')],
      ),
    ]; //newCards
    CardList.setCards(newCards);
    // Save flashcards.
    saveCards();
  } //e if
} //initialize

/// [QuizFlip].
class QuizFlip extends StatelessWidget {
  const QuizFlip({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "${getLang('title')} $appVersion",
      theme: theme.getThemeDataLight(context),
      darkTheme: theme.getThemeDataDark(context),
      themeMode: theme.getThemeMode(context),
      home: const OverviewPage(),
    );
  } //build
}//QuizFlip
