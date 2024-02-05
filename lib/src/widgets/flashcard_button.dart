
import 'package:flutter/material.dart';
import 'package:kkfl_theming/kkfl_theming.dart';
import 'package:kkfl_widgets/kkfl_widgets.dart';
import 'package:quizflip/src/flashcard.dart';

class FlashcardButton extends StatelessWidget {

  final Flashcard card;
  final void Function()? onPressed;
  final bool isFlipped;

  const FlashcardButton({
    super.key,
    required this.card,
    this.isFlipped = false,
    required this.onPressed});

  @override
  Widget build(BuildContext context) {

    String deckTags = card.deck.toString();
    if (card.tags.isNotEmpty) {
      deckTags = '$deckTags ${card.tags}';
    }

    late Widget buttonChild = Column(children: [
      Marked(isFlipped? card.value : card.key),
      SimpleText(deckTags, isItalic: true,)]);
    // if (isFlipped) {
    //   buttonChild = 
    // } else {
    //   String deckTags = widget.card.deck;
    //   if (widget.card.tags.isNotEmpty) {
    //     deckTags = '$deckTags ${widget.card.tags}';
    //   }
    //   buttonChild = Column(children: [Marked(widget.card.key), SimpleText(deckTags, isItalic: true,)]);
    // }

    OutlinedButton button = OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isFlipped? colorScheme(context).primaryContainer
          : colorScheme(context).surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))
      ),
      onPressed: onPressed,
      child: buttonChild);
    
    Row expanded = Row(children: [Expanded(child: button)]);

    return expanded;
  }//build
}//FlashcardButton
