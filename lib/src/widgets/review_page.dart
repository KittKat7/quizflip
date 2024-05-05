import 'package:flutter/material.dart';
import 'package:kittkatflutterlibrary/lang/kkfl_lang.dart';
import 'package:quizflip/src/flashcard.dart';
import 'package:quizflip/src/study.dart';
import 'package:quizflip/src/widgets/flashcard_button.dart';
import 'package:kittkatflutterlibrary/routing/kkfl_routing.dart';
import 'package:kittkatflutterlibrary/widgets/kkfl_widgets.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
} //PracticePage

class _ReviewPageState extends State<ReviewPage> {
  late Review review;

  @override
  void initState() {
    super.initState();
    review = Review(cards: CardList.filteredCards);
  } //initState

  @override
  Widget build(BuildContext context) {
    /// The aspect holds the main app components and keeps a specified aspect ratio.
    Aspect aspect = Aspect(
        child: SingleChildScrollView(
            child: FlashcardButton(
      card: review.currentCard,
      state: review.isShowingValue
          ? FlashcardButtonState.back
          : FlashcardButtonState.front,
      onPressed: () {
        review.flipCard();
        setState(() {});
      },
    )));
    Center center = Center(child: aspect);

    /// The app bar to be displayed at the top of the screen. Has a centered title.
    AppBar appBar = AppBar(
      title: Marked(getLang('page_review', [review.index + 1, review.length])),
      centerTitle: true,
    );

    Widget resetConfidence(Widget child) {
      return LongPressWidget(
          child: child,
          onLongPress: () {
            review.setConfidence(-1);
            setState(() {});
          });
    }

    List<Widget> children = [];

    if (review.hasPrevCard()) {
      children.add(Expanded(
          child: resetConfidence(IconButton(
              onPressed: () {
                review.prevCard();
                setState(() {});
              },
              icon: const Icon(Icons.arrow_back_rounded)))));
    } else {
      children.add(const Expanded(child: SizedBox()));
    }

    children.addAll([
      Expanded(
          child: resetConfidence(
        IconButton(
            onPressed: () {
              review.setConfidence(0);
              setState(() {});
            },
            icon: Icon(review.confidence == 0
                ? Icons.remove_circle
                : Icons.remove_circle_outline)),
      )),
      Expanded(
          child: resetConfidence(
        IconButton(
            onPressed: () {
              review.setConfidence(1);
              setState(() {});
            },
            icon: Icon(
                review.confidence == 1 ? Icons.circle : Icons.circle_outlined)),
      )),
      Expanded(
          child: resetConfidence(
        IconButton(
            onPressed: () {
              review.setConfidence(2);
              setState(() {});
            },
            icon: Icon(review.confidence == 2
                ? Icons.add_circle
                : Icons.add_circle_outline)),
      )),
    ]);

    if (review.hasNextCard()) {
      children.add(Expanded(
          child: resetConfidence(IconButton(
              onPressed: () {
                review.nextCard();
                setState(() {});
              },
              icon: const Icon(Icons.arrow_forward_rounded)))));
    } else {
      children.add(Expanded(
          child: resetConfidence(IconButton(
              onPressed: () {
                confirmPopup(context, getLang('hdr_finish_review'),
                    getLang('msg_finish_review'), () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      genRoute(_ReviewResultsPage(
                        review: review,
                      )));
                });
              },
              icon: const Icon(Icons.check)))));
    }

    /// The bottomAppBar displayed on the bottom of the screen. Holds nevigation buttons, and
    /// confidence buttons/
    BottomAppBar bottomAppBar = BottomAppBar(
      child: Row(children: children),
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
          confirmPopup(context, getLang('hdr_leave_review'),
              getLang('msg_leave_review'), () => Navigator.pop(context));
        },
        child: scaffold);
    return popScope;
  }
}

/// A simple static widget page which displayes the results of the review.
class _ReviewResultsPage extends StatelessWidget {
  const _ReviewResultsPage({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> results = review.getData();

    Widget child = Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
                child: Marked(getLang('txt_review_stats', [
              results['points'],
              results['total'],
              results['percent']
            ])))));

    /// The aspect holds the main app components and keeps a specified aspect ratio.
    Aspect aspect = Aspect(child: SingleChildScrollView(child: child));

    Center center = Center(child: aspect);

    /// The app bar to be displayed at the top of the screen. Has a centered title.
    AppBar appBar = AppBar(
      title: Marked(getLang('page_review')),
      centerTitle: true,
    );

    Scaffold scaffold = Scaffold(
      appBar: appBar,
      body: center,
    );

    PopScope popScope = PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          confirmPopup(context, getLang('hdr_leave_review'),
              getLang('msg_leave_review'), () => Navigator.pop(context));
        },
        child: scaffold);
    return popScope;
  } //build
}//_ReviewResultsPage

