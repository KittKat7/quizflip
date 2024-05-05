part of 'flashcard.dart';

StreamController<List<Flashcard>> filteredCardStreamController =
    StreamController<List<Flashcard>>.broadcast();
Stream<List<Flashcard>> get filteredCardsStream =>
    filteredCardStreamController.stream;

/// A *static* wrapper class for [cards] and [filteredCards]. Has methods to add, remove, sort,
/// etc... the cards.
class CardList {
  static List<Flashcard> _cards = [];
  static List<Flashcard> get cards => List<Flashcard>.from(_cards);
  static List<Flashcard> _filteredCards = [];
  static List<Flashcard> get filteredCards =>
      List<Flashcard>.from(_filteredCards);
  static FilterStack _filter = FilterStack();
  static FilterStack get filter => _filter;

  static void notifyStream() {
    filteredCardStreamController.add(filteredCards);
  } //notifyStream

  // Pops a layer off of the filter.
  static String popFilter() {
    String str = _filter.pop();
    updateFilteredCards();
    return str;
  } //popFilter

  /// Pushes a new layer onto the filter, then updates the filtered cards.
  static void pushFilter(String layer) {
    _filter.push(layer);
    updateFilteredCards();
  } //pushFilter

  static void setFilter(List<String> filter) {
    _filter = FilterStack(filterList: filter);
    updateFilteredCards();
  }

  static void updateFilteredCards() {
    if (_filter.length == 0) {
      _filteredCards = List<Flashcard>.from(_cards);
      notifyStream();
      return;
    }

    List<Flashcard> filteredCards = [];

    for (Flashcard card in _cards) {
      if (card.deck.startsWith(_filter)) {
        filteredCards.add(card);
      }
    }

    _filteredCards = filteredCards;
    notifyStream();
  } //updateFilteredCards

  /// Adds a card to the list of cards. If the new card already exists in the deck, the card will
  /// not be added, and false will be returned. To replace the existing card, use [force]. If force
  /// is true, the existing card will be replaced. If the card is added successfully, true is
  /// returned.
  static bool addCard(Flashcard card, [bool force = false]) {
    // If the card already exists, check if [force] is false.
    if (containsCard(card)) {
      // If [force] is false, return false, as the card has not been added.
      if (!force) return false;
      // Otherwise, remove the card, and continue on so the card can be added.
      removeCard(card);
    } //if

    // TODO improve efficiency
    _cards.add(card);
    sortCards();

    updateFilteredCards();
    saveCards();
    return true;
  } //add

  /// Removes a given card from the list of cards. If the card was removed, returns true, otherwise,
  /// returns false.
  static bool removeCard(Flashcard card) {
    bool removed = _cards.remove(card);
    if (removed) {
      saveCards();
      updateFilteredCards();
    }
    return removed;
  } //remove

  /// Checks if a given card already exists in the loaded flashcard list. Returns true if the card
  /// exists, and false if the card does not exist.
  static bool containsCard(Flashcard card) {
    return _cards.contains(card);
  } //contains

  /// Checks if a given card already exists in the loaded flashcard list. Returns true if the card
  /// exists, and false if the card does not exist.
  static bool containsCardID(String key, String deck) {
    return _cards.contains(Flashcard(key: key, deck: deck));
  } //contains

  /// Sorts cards by alphabetical order, starting with the deck the card is in.
  static void sortCards() {
    _cards.sort((a, b) => a.id.compareTo(b.id));
  } //sort

  static void setCards(List<Flashcard> cards) {
    _cards = cards;
    updateFilteredCards();
  }
}//CardList