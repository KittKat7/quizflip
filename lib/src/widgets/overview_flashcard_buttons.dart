import 'package:flutter/material.dart';
import 'package:kittkatflutterlibrary/lang/kkfl_lang.dart';
import 'package:kittkatflutterlibrary/routing/kkfl_routing.dart';
import 'package:quizflip/src/flashcard.dart';
import 'package:quizflip/src/widgets/flashcard_button.dart';
import 'package:quizflip/src/widgets/flashcard_page.dart';
import 'package:kittkatflutterlibrary/widgets/kkfl_widgets.dart';

class OverviewFlashcardButtons extends StatefulWidget {
  const OverviewFlashcardButtons({super.key});

  @override
  State<OverviewFlashcardButtons> createState() =>
      _OverviewFlashcardButtonsState();
}

class _OverviewFlashcardButtonsState extends State<OverviewFlashcardButtons> {
  List<Flashcard> filteredCards = [];

  void _updateFilteredCards(List<Flashcard> fltrdCards) {
    filteredCards = fltrdCards;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    filteredCardsStream.listen((event) {
      _updateFilteredCards(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (Flashcard c in CardList.filteredCards) {
      Widget flashcardBtn = LongPressWidget(
          onLongPress: () => confirmPopup(
              context,
              getLang('hdr_delete_card'),
              getLang('msg_confirm_delete_card', [c.id]),
              () => CardList.removeCard(c)),
          child: FlashcardButton(
            card: c,
            onPressed: () =>
                Navigator.push(context, genRoute(FlashcardPage(card: c))),
            state: FlashcardButtonState.all,
          ));
      children.add(Padding(
          padding: const EdgeInsets.only(bottom: 5), child: flashcardBtn));
    } //for
    Column column = Column(
      children: children,
    );

    return column;
  } //build
}//_OverviewFlashcardButtonsState