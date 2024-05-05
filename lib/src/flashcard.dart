import 'dart:async';
import 'dart:convert';
import 'package:quizflip/src/persistant.dart';

part 'flashcard_list.dart';
part 'filter_stack.dart';

/// The [Flashcard] class is used to represent all flashcards. The [key] String is the
/// term/question on the front of the [Flashcard]. The [values] List<String> is a list of all the
/// possible definitions/answers to the [key]. Only the one at index 0 is correct. All others are
/// false answers used in multiple choice tests. The [deck] String identifies what deck the
/// [Flashcard] belongs to. [tags] are optional decks. [id] is the flashcards unique ID, which is
/// the cards [deck] and [key] values combined, IE `/this/deck/card` if [deck] was `/this/deck/` and
/// if [key] was `card`.
class Flashcard {
  /// The term/question on the front of the flashcard.
  String _key;
  String get key => _key;
  set key(String key) {
    _key = key;
    saveCards();
  }

  /// The deck/folder the [Flashcard] is a part of.
  // String _deck;
  // String get deck => _deck;
  // set deck(String deck) {
  //   _deck = _validateDeck(deck);
  //   saveCards();
  // }
  FilterStack _deck;
  FilterStack get deck => _deck;

  /// The defitinions/answers on the back of the card. Index 0 is the correct answer, all other
  /// items are false answers, and will be used as decoys on multiple choice tests.
  List<String> _values;
  String get value => _values[0];
  List<String> get values => _values;
  List<String> get fValues => _values.sublist(1);
  set values(List<String> values) {
    _values = _validateValues(values);
    saveCards();
  }

  /// Optional decks this card is a part of. All tags start with a '#', and are separated by spaces.
  String _tags;
  String get tags => _tags;
  List<String> get tagsList => _tags.split(' ');
  set tags(String tags) {
    _tags = _validateTags(tags);
    saveCards();
  }

  /// How much confidence does the user have in this card?
  int _confidence;
  int get confidence => _confidence;
  void setConfidence(int cnfdnc) {
    _confidence = (cnfdnc < -1 || cnfdnc > 3) ? _confidence : cnfdnc;
    saveCards();
  }

  /// The unique ID of the card. A combination of [deck] and [key].
  String get id => (_deck.toString() + key).toLowerCase();

  Flashcard(
      {String? key,
      String? deck,
      List<String>? values,
      String? tags,
      int? confidence})
      : _deck = FilterStack(filterStr: deck ?? ''),
        _values = values ?? [''],
        _key = key ?? '',
        _tags = _validateTags(tags ?? ''),
        _confidence = (confidence ?? -1);

  /// Converts the [Flashcard] into a json encodable Map<String, dynamic>. The mappings are:
  /// `'key': [key]`, `'deck': [deck]`, `'values': [values]`, `'tags': [tags]`,
  /// `'cnfdnc': [confidence]`.
  Map<String, dynamic> toJson() => {
        'key': key,
        'deck': _deck.toString(),
        'values': _values,
        'tags': _tags,
        'cnfdnc': _confidence
      }; //toJson

  /// Takes a json decoded Map<String, dynamic> and returns a flashcard build using the data in the
  /// map. he mappings are: `'key': [key]`, `'deck': [deck]`, `'values': [values]`,
  /// `'tags': [tags]`, `'cnfdnc': [confidence]`.
  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
      key: json['key'],
      deck: json['deck'],
      values: List<String>.from(json['values']),
      tags: json['tags'],
      confidence: json['cnfdnc']); //fromJson

  @override
  String toString() {
    return json.encode(toJson());
  } //toString

  /// Returns the hashcode of [id] as it is used to distinguish the cards.
  @override
  int get hashCode => id.hashCode;

  /// Returns true if [other]'s [id] and [id] are the same. Otherwise returns false.
  @override
  bool operator ==(Object other) {
    return other is Flashcard ? id == other.id : false;
  }
} //Flashcard

String _validateTagStr(String str) {
  int a = 'a'.codeUnitAt(0);
  int A = 'A'.codeUnitAt(0);
  List<String> numberList = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  List<String> lowerList =
      List<String>.generate(26, (index) => String.fromCharCode(index + a));
  List<String> upperList =
      List<String>.generate(26, (index) => String.fromCharCode(index + A));
  List<String> specialList = ['_', '-', '.', '#'];
  // List<String> specialList = ['/', '#', '_', '-', '.', '+', '='];
  List<String> permittedChars =
      numberList + lowerList + upperList + specialList;

  // Remove leading or trailing white space.
  str = str.trim();
  // Ensure starting and ending with a '/'
  if (!str.startsWith('/')) str = '/$str';
  if (!str.endsWith('/')) str = '$str/';

  for (int i = 0; i < str.length; i++) {
    if (!permittedChars.contains(str.substring(i, i + 1))) {
      str.replaceAll(str.substring(i, i + 1), '_');
    } //if
  } //for

  return str;
} //_validateDeck

/// Validates the tag string.
String _validateTags(String tags) {
  return validateTagList(tags.split(' ')).join(' ');
} //validateTagStr

/// Validates the tag list.
List<String> validateTagList(List<String> tags) {
  tags = tags.toSet().toList();
  tags.remove('');

  for (int i = 0; i < tags.length; i++) {
    // Validate deck auto adds a '/' to the front if it is not already there. Remove that so the tag
    // starts with '#' instead of '/#'.
    tags[i] = _validateTagStr(tags[i]).substring(1);
  } //e for

  tags = tags.toSet().toList();
  tags.remove('');

  return tags;
} //validateTagList

List<String> _validateValues(List<String> values) {
  while (values.contains(' ')) {
    values.remove(' ');
  }
  return values;
}
