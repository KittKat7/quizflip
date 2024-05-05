import 'package:flutter/material.dart';
import 'package:kittkatflutterlibrary/theming/kkfl_theming.dart';
import 'package:kittkatflutterlibrary/widgets/kkfl_widgets.dart';
import 'package:quizflip/src/flashcard.dart';

enum FlashcardButtonState { front, back, all }

class FlashcardButton extends StatelessWidget {
  final Flashcard card;
  final void Function()? onPressed;
  final FlashcardButtonState state;
  final bool isFlipped;

  const FlashcardButton(
      {super.key,
      required this.card,
      required this.state,
      required this.onPressed})
      : isFlipped = state == FlashcardButtonState.back;

  @override
  Widget build(BuildContext context) {
    String deckTags = card.deck.toString();
    if (card.tags.isNotEmpty) {
      deckTags = '$deckTags ${card.tags}';
    }

    List<Widget> children = [];

    if (state == FlashcardButtonState.front) {
      children.addAll([
        Marked(card.key),
        SimpleText(
          deckTags,
          isItalic: true,
        )
      ]);
    } else if (state == FlashcardButtonState.back) {
      children.addAll([
        Marked(card.value),
        SimpleText(
          deckTags,
          isItalic: true,
        )
      ]);
    } else {
      children.addAll([
        Marked(card.key),
        const Divider(),
        Marked(card.value),
        SimpleText(
          deckTags,
          isItalic: true,
        )
      ]);
    }

    Widget buttonChild = Column(children: children);

    ElevatedButton button = ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor:
                isFlipped ? colorScheme(context).primaryContainer : null,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)))),
        onPressed: onPressed,
        child: buttonChild);

    Row expanded = Row(children: [Expanded(child: button)]);

    return expanded;
  } //build
}//FlashcardButton
