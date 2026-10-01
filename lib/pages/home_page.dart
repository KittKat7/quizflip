
import 'package:flutter/material.dart';
import 'package:kittkatflutterlibrary/kittkatflutterlibrary.dart';
import 'package:quizflip/models/fileio.dart';
import 'package:quizflip/widgets/confirm_popup.dart';
import '../models/flashcard.dart';
import '/pages/review_page.dart';
import '/widgets/card_widget.dart';

import '../models/cardlist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late CardList list;

  @override
  void initState() {
    list = CardList.getMaster();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    List<String> tags = list.getFilteredNextTags();
    List<Widget> tagButtons = [
      IconButton(
        onPressed: () => setState(() => list.popFilter() ),
        icon: Icon(Icons.arrow_upward_rounded))
    ];
    if (list.filter.isNotEmpty) {
      tagButtons.add(Padding(
        padding: EdgeInsetsGeometry.all(1),
        child: TextButton(child: Text('[${list.filter}]'),
        onPressed: () => setState(() {
          // list = list.filterList(t);
          // tags = list.getFilteredTags();
        }),)
      ));
    }
    for (String t in tags) {
      if (t == list.filter) continue;
      tagButtons.add(Padding(
        padding: EdgeInsetsGeometry.all(1),
        child: TextButton(child: Text(t),
        onPressed: () => setState(() {
          list.pushFilter(t);
          tags = list.getFilteredNextTags();
        }),)
      ));
    }

    List<Flashcard> cards = list.getFilteredCards();
    List<Widget> cardWidgets = [];
    for (Flashcard c in cards) {
      cardWidgets.add(CardWidget(card: c));
    }

    // Create button variables
    var deleteFilteredButton = Expanded(child: ElevatedButton(
      onPressed: () => 
        showConfirmPopup(
          context,
          getLang('msgTitleConfirmDeleteAllFilter'),
          getLang('msgConfirmDeleteAllFilter'),
          () => setState(() =>
            CardList.getMaster().removeFilteredCards()),
        ),
      child: Text(getLang('btnDeleteAll'))));
    var importButton = Expanded(child: ElevatedButton(
      onPressed: () {
        importFromCSV().then(
          (v) => setState((){}));
      }, // TODO
      child: Text(getLang('btnImport'))));
    var exportButton = Expanded(child: ElevatedButton(
      onPressed: (){
        exportToCSV();
      }, // TODO
      child: Text(getLang('btnExport'))));
    var addCardButton = Expanded(child: ElevatedButton(
      onPressed: (){},
      child: Text(getLang('btnAddCard'))));
    var weiverButton = Expanded(child: ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        genRoute(ReviewPage(list: list, weiver: true,))),
      child: Text(getLang('btnWeiver'))));
    var reviewButton = Expanded(child: ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        genRoute(ReviewPage(list: list))),
      child: Text(getLang('btnReview'))));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(getLang('titleApp')),
      ),
      body: Aspect(
        child: SingleChildScrollView(child: Column(
          children: [
            // Row 1
            Row(children: [
              reviewButton,
              weiverButton,
              addCardButton
            ]),
            // Row 2
            Row(children: [
              importButton,
              exportButton,
              deleteFilteredButton
            ]),
            // Tag row
            SizedBox(
              width: double.infinity, 
              child: Wrap(alignment: .start, children: tagButtons,),
            ),
            // Flashcards
            Column(
              mainAxisSize: .min,
              children: cardWidgets,
            )
          ],
        ),
      ))
    );
  }
}
