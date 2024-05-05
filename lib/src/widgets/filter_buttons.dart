import 'package:flutter/material.dart';
import 'package:kittkatflutterlibrary/lang/kkfl_lang.dart';
import 'package:kittkatflutterlibrary/theming/src/theme.dart';
import 'package:quizflip/src/flashcard.dart';

class DeckButtons extends StatefulWidget {
  const DeckButtons({super.key});

  @override
  State<DeckButtons> createState() => _DeckButtonsState();
} //DeckButtons

class _DeckButtonsState extends State<DeckButtons> {
  List<String> appliedFilterList = [];

  List<String> filterList = [];

  void _updateFilters(List<Flashcard> fltrdCards) {
    filterList = [];

    for (Flashcard card in fltrdCards) {
      if (card.deck.startsWith(CardList.filter) &&
          card.deck.toList().length > CardList.filter.length) {
        String layer = card.deck.toList().sublist(CardList.filter.length)[0];
        if (!filterList.contains(layer)) {
          filterList.add(layer);
        } //if
      } //if
    } //for

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _updateFilters(CardList.filteredCards);
    filteredCardsStream.listen((event) {
      _updateFilters(event);
    });
  } //initState

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [
      ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme(context).primaryContainer),
          onPressed: () => CardList.setFilter([]),
          child: Text(getLang('btn_all_cards')))
    ];

    List<String> appliedFilters = List<String>.from(CardList.filter.toList());
    List<String> prevFilters = [];

    for (String layer in appliedFilters) {
      prevFilters.add(layer);
      List<String> nlist = List.from(prevFilters);
      buttons.add(ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme(context).primaryContainer),
          onPressed: () => CardList.setFilter(nlist),
          child: Text(layer)));
    }

    for (String str in filterList) {
      buttons.add(ElevatedButton(
          onPressed: () => CardList.pushFilter(str), child: Text(str)));
    }

    return Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          children: buttons,
        ));
  }
}//_DeckButtonsState