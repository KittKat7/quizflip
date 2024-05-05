import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kittkatflutterlibrary/lang/kkfl_lang.dart';
import 'package:quizflip/src/app_data.dart';
import 'package:quizflip/src/flashcard.dart';
import 'package:quizflip/src/system_io.dart';
import 'package:quizflip/src/widgets/filter_buttons.dart';
import 'package:quizflip/src/widgets/flashcard_page.dart';
import 'package:quizflip/src/widgets/overview_flashcard_buttons.dart';
import 'package:quizflip/src/widgets/practice_buttons.dart';
import 'package:kittkatflutterlibrary/routing/kkfl_routing.dart';
import 'package:kittkatflutterlibrary/widgets/kkfl_widgets.dart';

/// The main page for the app. Overview with all the flashcards visible. Allows for sorting through
/// the cards, and has options to start different practice modes.
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    /// This column holds the actual contents of the display. There are three main parts that the
    /// column contains. The practice buttons. These buttons allow the user to start practice modes.
    /// The deck buttons. These buttons allow the user to sort through the cards by deck. And the
    /// card buttons. These represent the cards inside the current filter.
    Column column = const Column(children: [
      Padding(padding: EdgeInsets.only(bottom: 5), child: PracticeButtons()),
      Padding(padding: EdgeInsets.only(bottom: 5), child: DeckButtons()),
      // deckBtns(Flashcard.filteredDecks, () => setState(() {})),
      // CardButtonColumn(cards: Flashcard.filteredCards, updateState: () => setState(() {})),
      // cardBtns(Flashcard.filteredCards, context, () => setState(() {})),
      OverviewFlashcardButtons(),
    ]); //column

    /// [aspect] holds the content of the app, making sure it is in the correct aspect ratio.
    Aspect aspect = Aspect(
        child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SingleChildScrollView(child: column))); //aspect

    /// The [ListView] to be displayed [drawer].
    ListView drawerList = ListView(
      children: [
        Text(getLang('hdr_settings_drawer', [appVersion])),
        ElevatedButton(
            onPressed: () => cycleThemeColor(),
            child: Text(getLang('btn_theme_color_menu'))),
        ElevatedButton(
            onPressed: () => cycleThemeMode(),
            child: Text(getLang('btn_theme_mode_menu'))),
        ElevatedButton(
          onPressed: () => importCardsJson(context, () {}),
          child: Text(getLang('btn_import_json')),
        ),
        ElevatedButton(
            onPressed: () => exportCardsJson(),
            child: Text(getLang('btn_export_json'))),
      ],
    );

    /// This drawer displays on the the left side of the screen. This is where you can access app
    /// settings, as well as the options to import and export flashcards.
    Drawer drawer = Drawer(
      child: drawerList,
    );

    /// The app bar to be displayed at the top of the page. Has a centered title.
    AppBar appBar = AppBar(
      title: SimpleText(
        getLang('title'),
        isBold: true,
      ),
      centerTitle: true,
      leading: Builder(builder: (context) {
        return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Navigator.of(context).pushNamed(getRoute('settings'));
              Scaffold.of(context).openDrawer();
            });
      }),
    );

    FloatingActionButton actionButton = FloatingActionButton(
      tooltip: getLang('tooltip_create_card'),
      onPressed: () => Navigator.push(context, genRoute(FlashcardPage())),
      child: const Icon(Icons.add),
    );

    /// The scaffold for the overview page.
    Scaffold scaffold = Scaffold(
      appBar: appBar,
      drawer: drawer,
      body: aspect,
      floatingActionButton: actionButton,
    ); //scaffold

    /// popScope wraps the scaffold, to handle custom pop behavior. When trying to pop, a filter
    /// should be popped instead. If there are no filters to pop, then the app should confirm, then
    /// quit.
    PopScope popScope = PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          if (CardList.filter.length > 0) {
            CardList.popFilter();
            return;
          } //if
          // If no filter to pop, exit app.
          confirmPopup(
              context,
              getLang('hdr_exit_app'),
              getLang('msg_confirm_app_exit'),
              () =>
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop'));
        },
        child: scaffold);

    return popScope;
  } //build
}//OverviewPage