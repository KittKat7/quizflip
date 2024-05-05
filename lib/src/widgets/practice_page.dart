import 'package:flutter/material.dart';
import 'package:kittkatflutterlibrary/lang/kkfl_lang.dart';
import 'package:quizflip/src/flashcard.dart';
import 'package:quizflip/src/study.dart';
import 'package:quizflip/src/widgets/flashcard_button.dart';
import 'package:kittkatflutterlibrary/widgets/kkfl_widgets.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
} //PracticePage

class _PracticePageState extends State<PracticePage> {
  late Practice practice;

  @override
  void initState() {
    super.initState();
    practice = Practice(cards: CardList.filteredCards);
  } //initState

  @override
  Widget build(BuildContext context) {
    /// The aspect holds the main app components and keeps a specified aspect ratio.
    Aspect aspect = Aspect(
        child: SingleChildScrollView(
            child: FlashcardButton(
      card: practice.currentCard,
      state: practice.isShowingValue
          ? FlashcardButtonState.back
          : FlashcardButtonState.front,
      onPressed: () {
        practice.flipCard();
        setState(() {});
      },
    )));
    Center center = Center(child: aspect);

    /// The app bar to be displayed at the top of the screen. Has a centered title.
    AppBar appBar = AppBar(
      title: Marked(getLang('page_practice', [practice.cardsPracticed])),
      centerTitle: true,
    );

    Widget resetConfidence(Widget child) {
      return LongPressWidget(
          child: child,
          onLongPress: () {
            practice.setConfidence(-1);
            setState(() {});
          });
    }

    /// The bottomAppBar displayed on the bottom of the screen. Holds nevigation buttons, and
    /// confidence buttons/
    BottomAppBar bottomAppBar = BottomAppBar(
      child: Row(children: [
        const Expanded(child: SizedBox()),
        Expanded(
            child: resetConfidence(
          IconButton(
              onPressed: () {
                practice.setConfidence(0);
                setState(() {});
              },
              icon: Icon(practice.confidence == 0
                  ? Icons.remove_circle
                  : Icons.remove_circle_outline)),
        )),
        Expanded(
            child: resetConfidence(
          IconButton(
              onPressed: () {
                practice.setConfidence(1);
                setState(() {});
              },
              icon: Icon(practice.confidence == 1
                  ? Icons.circle
                  : Icons.circle_outlined)),
        )),
        Expanded(
            child: resetConfidence(
          IconButton(
              onPressed: () {
                practice.setConfidence(2);
                setState(() {});
              },
              icon: Icon(practice.confidence == 2
                  ? Icons.add_circle
                  : Icons.add_circle_outline)),
        )),
        Expanded(
            child: IconButton(
                onPressed: () {
                  practice.nextCard();
                  setState(() {});
                },
                icon: const Icon(Icons.arrow_forward_rounded))),
      ]),
    ); //bottomAppBar

    Scaffold scaffold = Scaffold(
      appBar: appBar,
      body: center,
      bottomNavigationBar: bottomAppBar,
    );
    PopScope popScope = PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          confirmPopup(
              context,
              getLang('hdr_confirm_leave_practice'),
              getLang('msg_confirm_leave_practice'),
              () => Navigator.pop(context));
        },
        child: scaffold);
    return popScope;
  }
}
