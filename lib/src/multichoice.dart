import 'dart:math';

import 'package:quizflip/src/flashcard.dart';

/// [MultiChoice] is used for running multiple choice test on a given set of flashcards.
class MultiChoice {

  /// The cards to run the test on.
  final List<Flashcard> _cards;
  List<Flashcard> get cards => _cards;
  final DateTime _startingTime;
  final List<List<String>> _cardValues;
  List<List<String>> get cardValues => _cardValues;
  final List<String?> _userAnswers;
  List<String?> get userAnswers => _userAnswers;
  Duration _timeElapsed;
  int index;

  MultiChoice({required List<Flashcard> cards})
  : _cards = cards, _startingTime = DateTime.now(), _userAnswers = [], _cardValues = [],
  index = 0, _timeElapsed = const Duration() {
    _cards.shuffle();
    // The ideal number of answers each question should have.
    const int numOfAnswers = 4;
    // A list of all the answers.
    List<String> allAnswers = [];
    for (int i = 0; i < _cards.length; i++) {
      for (String a in _cards[i].values) {
        allAnswers.add(a);
      }//for
    }//for

    // Go through and collect up to [numOfAnswers] random answers for each card. One of the answers will be
    // correct, the others will not. The correct answer will be in a random index in the list of
    // answers for the card.
    for (int i = 0; i < _cards.length; i++) {
      _cardValues[i] = [_cards[i].value];
      
      // Add up to 3 false answers from the card.
      List<String> falseAnswers = _cards[i].fValues;
      while (_cardValues[i].length < numOfAnswers && falseAnswers.length > 1) {
        int rIndex = Random().nextInt(falseAnswers.length);
        _cardValues[i].add(falseAnswers[rIndex]);
        falseAnswers.removeAt(rIndex);
      }//while

      // If there are fewer than [numOfAnswers] answers, then take answers from other cards, until
      // there are the correct number of answers, or there are no other answers to use.
      if (_cardValues[i].length < numOfAnswers) {
        List<String> otherAnswers = List<String>.from(allAnswers);
        otherAnswers.removeWhere((element) => _cardValues[i].contains(element));

        while (_cardValues[i].length < numOfAnswers && otherAnswers.length > 1) {
          int rIndex = Random().nextInt(otherAnswers.length);
          _cardValues[i].add(otherAnswers[rIndex]);
          otherAnswers.removeAt(rIndex);
        }//while
      }//if
      _cardValues[i].shuffle();
    }//for
  }//Constructor

  /// Check if there is a next card after the current one.
  bool hasNextCard() {
    if (index + 1 == _cards.length) return false;
    return true;
  }//hasNextCard

  /// Check if there is a card before the current one.
  bool hasPrevCard() {
    if (index <= 0) return false;
    return true;
  }//hasPrevCard

  /// ```
  /// Map<String, dynamic> {
  ///   'key': key,
  ///   'deck': deck,
  ///   'values': cardValues
  /// };
  /// ```
  Map<String, dynamic> getCardData() {
    String key = _cards[index].key;
    String deck = _cards[index].deck.toString();
    List<String> cardValues = _cardValues[index];

    Map<String, dynamic> ret = {
      'key': key,
      'deck': deck,
      'values': cardValues,
    };

    return ret;
  }//getCardData

  /// Moves forward, and returns the data of the next card.
  Map<String, dynamic> nextCard() {
    if (index < _cards.length) index++;

    return getCardData();
  }//nextCard

  /// Moves backward, and returns the data of the previous card.
  Map<String, dynamic> prevCard() {
    if (index > 0) index--;
    
    return getCardData();
  }//prevCard

  /// Sets the users answer for the current card.
  void answerCard(String? answer) {
    _userAnswers[index] = answer;
  }//answerCard

  /// Returns the answer entered by the user for the current card
  String? getEnteredAnswer() {
    return _userAnswers[index];
  }//getEnteredAnswer

  /// Run to stop the timer.
  void endMultiChoice() {
    _timeElapsed = DateTime.now().difference(_startingTime);
  }//endMultiChoice

  ///
  /// ```
  /// Map<String, num> ret = {
  ///    'points': points,
  ///    'total': total,
  ///    'percent': percent,
  ///  };
  ///  ```
  Map<String, dynamic> getResults() {
    // The total number of cards.
    int total = _cards.length;
    // The number of points collected by the user.
    int points = 0;

    // For every card.
    for (int i = 0; i < total; i++) {
      // Current card from the list.
      var card = _cards[i];
      // Get teh correct answer for the card
      String correctAnswer = card.value;
      if (correctAnswer == _userAnswers[i]) {
        points++;
      }//e if
    }//e for

    // The percent of correct questions
    double percent = points / total;

    Map<String, dynamic> ret = {
      'points': points,
      'total': total,
      'percent': percent,
      'duration': _timeElapsed,
    };
    return ret;
  }//getResults
}//MultiChoice
