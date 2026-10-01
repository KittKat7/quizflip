import 'dart:math';

import 'flashcard.dart';
import 'flashcard_tag.dart';

/// A list of flashcards
class CardList {
  /// The cards in the list
  final List<Flashcard> _cards;
  /// The cards in the list that dont match the filter
  List<Flashcard> _filteredCards;
  /// A map of the tags to their corresponding cards
  final Map<FlashcardTag, List<Flashcard>> _tagMap;
  /// A tag filter
  FlashcardTagFilter _filter;
  String get filterStr => _filter.filterStr;

  /// A singleton instance of a card list, used as an unfiltered list of all
  /// cards
  static CardList? _master;

  /// Constructor
  CardList({required List<Flashcard> cards})
    : _cards = [],
      _filteredCards = [],
      _tagMap = {},
      _filter = FlashcardTagFilter(filter: null)
    {
    // For every card in the passed list, add it to this list
    for (Flashcard c in cards) {
      addCard(c);
    }
  }

  /// Get the master [CardList]
  static CardList getMaster() {
    _master ??= CardList(cards: []);
    return _master!;
  }

  /// Returns a list of all available tags
  List<FlashcardTag> getTags() {
    return _tagMap.keys.toList();
  }

  /// Returns a list of filtered tags
  List<FlashcardTag> getFilteredTags() {
    List<FlashcardTag> tags = [];
    for (Flashcard c in _filteredCards) {
      for (FlashcardTag t in c.tags) {
        if (tags.contains(t)) continue;
        if (_filter.passedFilter(t)) tags.add(t);
      }
    }
    return tags;
  }

  /// Returns a list of all possible next-level tags in the filtering hierarchy
  List<String> getFilteredNextTags() {
    List<String> nextTags = [];
    List<FlashcardTag> filteredTags = getFilteredTags();
    for (FlashcardTag ft in filteredTags) {
      String? nt = _filter.getNextSubtagStr(ft);
      if (nt != null && !nextTags.contains(nt)) nextTags.add(nt);
    }
    return nextTags;
  }

  List<Flashcard> getAllCards() {
    return _cards.toList();
  }

  /// Returns a list of filtered cards
  List<Flashcard> getFilteredCards() {
    return _filteredCards.toList();
  }

  /// Add [card] to the list
  void addCard(Flashcard card) {
    // If the card is already added, dont add it again
    if (_cards.contains(card)) return;
    // Add the card to the card list
    _cards.add(card);
    // Associate the card with all its tags in the tag map
    for (FlashcardTag t in card.tags) {
      // If the tag exists, add the card to that tag
      if (_tagMap.containsKey(t)) {
        _tagMap[t]!.add(card);
      }
      // Else add the tag and the card to the tag
      else {
        _tagMap[t] = [card];
      }
    }
    // TODO replace with more efficient system
    filterList();
  }

  /// Add multiple cards to the list
  void addCards(List<Flashcard> cards) {
    for (Flashcard c in cards) {
      addCard(c);
    }
  }

  /// Remove [card] from the list
  void removeCard(Flashcard card) {
    // Skip if the card is not contained
    if (!_cards.contains(card)) return;
    // Remove the card from the list
    _cards.remove(card);
    // Remove from filtered cards
    if (_filteredCards.contains(card)) _filteredCards.remove(card);
    // Remove from associated tags
    for (FlashcardTag t in card.tags) {
      // Remove the card from a tag
      _tagMap[t]!.remove(card);
      // If there are no more cards with that tag, remove the tag
      if (_tagMap[t]!.isEmpty) {
        _tagMap.remove(t);
      }
    }
  }

  /// Removes all cards in the filtered list
  void removeFilteredCards() {
    List<Flashcard> tl = [];
    for (Flashcard c in _filteredCards) {
      tl.add(c);
    }
    for (Flashcard c in tl) {
      removeCard(c);
    }
  }

  /// Filters the list by a list of tags and return the new filtered list
  CardList filterList() {
    _filteredCards = [];
    // For every tag in the filter list, if these is a tag in this list that
    // starts with the filter tag, add all the cards from that filter tag to
    // the new list
    for (FlashcardTag lt in _tagMap.keys) {
      // For every matching card, add it to the new list
      if (_filter.passedFilter(lt)) {
        for (Flashcard c in _tagMap[lt]!) {
          if (!_filteredCards.contains(c)) _filteredCards.add(c);
        }
      }
    }
    return this;
  }

  /// Adds a new filtering level by appending a tag to the current filter string.
  void pushFilter(String next) {
    _filter.pushSubtag(next);
    filterList();
  }

  /// Removes the last level of filtering from the current filter
  void popFilter() {
    _filter.popSubtag();
    filterList();
  }

  /// Gets a card with the matching term. Throws an [Exception] if the card is
  /// not found.
  Flashcard getCard(String term) {
    for (Flashcard c in _cards) {
      if (c.term == term) return c;
    }
    throw Exception("Card Not Found!");
  }

  /// Get a random card from the list. Throws an exception if the list is empty.
  /// If [card] is passed, then choose a random card which is NOT the passed
  /// card.
  Flashcard getRandomCard([Flashcard? card]) {
    int i = Random().nextInt(_filteredCards.length);
    if (card != null) {
      if (_filteredCards[i] == card) i++;
    }
    return _filteredCards[i % _filteredCards.length];
  }

}


