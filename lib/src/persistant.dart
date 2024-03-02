import 'dart:convert';

import 'package:quizflip/src/app_data.dart';
import 'package:quizflip/src/flashcard.dart';
import 'package:quizflip/src/pref_storage.dart';
import 'package:quizflip/src/update.dart';

/// Saves the cards to shared preferences
void saveCards() {
  prefs.setString('flashcards', json.encode({
    'metadata': {'version': dataVersion},
    'flashcards': CardList.cards,
    }));
}//_saveCards

List<Flashcard> loadFlashcards() {
  String? jsonContent = prefs.getString('flashcards');
  if (jsonContent == null) return [];

  Map<String, dynamic> metadata = json.decode(jsonContent)['metadata'];
  // TODO version check
  if (metadata['version'] < dataVersion) {
    updateFlashcards(metadata['version']);
  }
  List<dynamic> cardsJson = json.decode(jsonContent)['flashcards'];
  List<Flashcard> flashcards =
    [for (dynamic card in cardsJson) Flashcard.fromJson(card)];
  return flashcards;
}