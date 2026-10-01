import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '/models/flashcard.dart';
import 'cardlist.dart';

late final SharedPreferences prefs;

/// Initializes the shared preferences instance with a unique prefix.
/// Sets up the storage prefix to avoid namespace conflicts and creates
/// the initial preferences object.
Future<void> initializeFileStorage() async {
  SharedPreferences.setPrefix('QuizFlip.');
  prefs = await SharedPreferences.getInstance();
}

/// Returns the saved version number from storage.
/// Used for compatibility checks when loading flashcards.
/// Returns -1 if no version has been saved yet.
int getSavedVersion() {
  return prefs.getInt('version') ?? -1;
}

/// Parses a CSV string into a list of [Flashcard] objects.
/// Skips the header row (term, definition) and reconstructs flashcards
/// from the remaining data rows.
List<Flashcard> parseFromCSV(String cardsCSV) {
  final List<List<dynamic>> decodedData = csv.decode(cardsCSV);
  List<Flashcard> parsed = [];
  for (List<dynamic> c in decodedData) {
    List<String> ct = List<String>.from(c);
    if (ct[0].toLowerCase() == "term") continue;
    parsed.add(Flashcard.fromCSV(ct));
  }
  return parsed;
}

/// Loads all flashcards from storage.
/// Retrieves the serialized CSV string and parses it into [Flashcard] objects.
/// If no cards are stored, returns a default example list.
List<Flashcard> loadFlashcards() {
  String? cardsStr = prefs.getString('cardsCSV');
  if (cardsStr == null) return Flashcard.exampleList;
  return parseFromCSV(cardsStr);
}

/// Saves all flashcards to local storage in CSV format.
/// Converts each [Flashcard] into a CSV row, encodes them into a single string,
/// and stores it in SharedPreferences under the key 'cardsCSV'.
Future<void> saveFlashcards(List<Flashcard> cards) async {
  List<List<String>> decodedData = [];
  for (Flashcard c in cards) {
    decodedData.add(c.toCSV());
  }
  String cardsCSV = csv.encode(decodedData);
  await prefs.setString('cardsCSV', cardsCSV);
}

/// Imports flashcards from a CSV file selected by the user. Opens a file picker
/// to allow the user to select a .csv file, reads the file contents, parses it
/// into flashcards, and saves them to storage.
Future<void> importFromCSV() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  String fileString;

  if (result != null) {
    Uint8List fileBytes = result.files.first.bytes!;
    fileString = String.fromCharCodes(fileBytes);
  } else {
    print("import cancelled");
    return;
  }

  CardList.getMaster().addCards(parseFromCSV(fileString));
  await saveFlashcards(CardList.getMaster().getAllCards());
}

/// Exports flashcards to a CSV file and downloads it to the user's device.
Future<void> exportToCSV() async {
  String csvContent = prefs.getString('cardsCSV') ?? '';
  
  // Create a base64-encoded data URL
  final bytes = utf8.encode(csvContent);
  final base64String = base64Encode(bytes);
  final uri = 'data:text/csv;base64,$base64String';
  
  // Create a download link and trigger it
  web.HTMLAnchorElement()
    ..href = uri
    ..download = 'flashcards.csv'
    ..click();
}
