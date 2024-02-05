import 'package:quizflip/src/flashcard.dart';

abstract class Study {
  /// Index of the currently reviewing card.
  int _index;
  /// Whether or not the card is showing its value.
  bool _isShowingValue;
  /// The cards being reviewed
  List<Flashcard> _cards;
  /// The currently reviewing card.
  Flashcard get currentCard => _cards[index];

  int get index { return _index; }
  int get length { return _cards.length; }
  bool get isShowingValue { return _isShowingValue; }
  String get currentKey { return currentCard.key; }
  String get currentValue { return currentCard.values[0]; }
  String get currentDeck { return currentCard.deck.toString(); }
  int get confidence { return currentCard.confidence; }

  Study({required List<Flashcard> cards}) : _index = 0, _isShowingValue = false, _cards = cards {
    _index = 0;
    _isShowingValue = false;
    _cards.shuffle();
  }//Constructor

  void flipCard() {
    _isShowingValue = !_isShowingValue;
  }//e flipCard()

  void changeCard() {
    _isShowingValue = false;
  }//e _updateCurrentCard()

  void setConfidence(int cnfdnc) {
    currentCard.setConfidence(cnfdnc);
  }//e setConfidence()

}//Study

class Review extends Study {
  Review({required super.cards});

  /// Checks if there is a next card, if so, return true. Otherwise, return false.
  bool hasNextCard() {
    if (_index + 1 == _cards.length) return false;
    return true;
  }//hasNextCard

  /// Checks if there is a previous card, if co, return true. Otherwise, return false.
  bool hasPrevCard() {
    if (_index <= 0) return false;
    return true;
  }//hasPreviousCard

  /// Updates the current card. [offset] is the number of card to move forward + or backward -.
  void _updateCurrentCard(int offset) {
    super.changeCard();
    _index += offset;
  }//_updateCurrentCard

  void nextCard() {
    if (!hasNextCard()) return;
    _updateCurrentCard(1);
  }//nextCard

  void prevCard() {
    if (!hasPrevCard()) return;
    _updateCurrentCard(-1);
  }//prevCard

  /// Returns the data about the review session.
  Map<String, num> getData() {
    double score = 0;
    double percentScore = 0;

    for (int i = 0; i < _cards.length; i++) {
      Flashcard c = _cards[i];

      if (c.confidence != -1) {
        score += c.confidence / 2;
      }//e if
    }//e for
    percentScore = (score / _cards.length) * 100;
    percentScore.round();
    return {
      'points': score,
      'total': _cards.length,
      'percent': percentScore
    };
  }//getData
}//Review

class Practice extends Study {

  /// A counter used to track how many cards were practiced.
  int _cardsPracticed = 0;
  int get cardsPracticed { return _cardsPracticed; }

  Practice({required super.cards});

  /// Updates the current card to the card at the [index] + [offset].
  void _updateCurrentCard() {
    super.changeCard();
    _index = 0;
  }//e _updateCurrentCard()

  void nextCard() {
    Flashcard currCard = currentCard;
    _cards = _cards.sublist(1);
    _cards.shuffle();
    _cards.add(currCard);
    _cardsPracticed++;
    _updateCurrentCard();
  }//nextCard

}//Practice