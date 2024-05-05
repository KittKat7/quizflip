import 'package:flutter/material.dart';
import 'package:kittkatflutterlibrary/lang/kkfl_lang.dart';
import 'package:kittkatflutterlibrary/widgets/kkfl_widgets.dart';
import 'package:quizflip/src/flashcard.dart';

class FlashcardPage extends StatefulWidget {
  final Flashcard? card;
  final String cardKey;
  final String cardDeck;
  final List<String> cardValues;
  final String cardTags;
  final int cardCnfdnc;

  FlashcardPage({
    super.key,
    this.card,
  })  : cardKey = card?.key ?? '',
        cardDeck = card?.deck.toString() ?? '',
        cardValues = card?.values ?? [''],
        cardTags = card?.tags ?? '',
        cardCnfdnc = card?.confidence ?? -1;

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
} //FlashcardPage

class _FlashcardPageState extends State<FlashcardPage> {
  bool isEditing = false;
  bool get isEdited =>
      isKeyEdited || isDeckEdited || isValueEdited || isTagsEdited;

  bool isKeyEdited = false;
  bool isDeckEdited = false;
  bool isValueEdited = false;
  bool isTagsEdited = false;

  String key = '';
  String deck = '';
  List<String> values = [''];
  String tags = '';
  //
  late Widget keyField;
  late Widget deckField;
  late Widget valueField;
  late List<Widget> valuesFakeField;
  late Widget tagsField;

  @override
  void initState() {
    super.initState();
    if (widget.card == null) isEditing = true;

    key = widget.cardKey;
    deck = widget.cardDeck;
    values = List<String>.from(widget.cardValues);
    tags = widget.cardTags;

    toggleEditingWidgets();
  } //initState

  /// Changes the stored value for the key, when the user modifies it.
  void _updateKey(String nKey) {
    key = nKey;
    isKeyEdited = widget.cardKey != key;
  } //_updateKey

  /// Changes the stored value for the deck, when the user modifies it.
  void _updateDeck(String nDeck) {
    deck = nDeck;
    isDeckEdited = widget.cardDeck != deck;
  } //_updateKey

  /// Changes the stored value for the values, when the user modifies them.
  void _updateValue(String nValue, int i) {
    values[i] = nValue;
    isValueEdited = widget.cardValues.length != values.length ||
        widget.cardValues[i] != values[i];
    if (i == values.length - 1) {
      values.add('');
      valuesFakeField.add(TextField(
        controller: TextEditingController(text: values[i + 1]),
        onChanged: (v) => _updateValue(v, i + 1),
      ));
      setState(() {});
    } //if
  } //_updateValue

  /// Changes the stored value for the tags, when the user modifies it.
  void _updateTags(String nTags) {
    tags = nTags;
    isTagsEdited = widget.cardTags != tags;
  } //_updateKey

  /// Sets the widgets displayed on screen to either be Marked widgets if !isEditing, and TextField
  /// widgets if isEditing.
  void toggleEditingWidgets() {
    valuesFakeField = [];
    if (!isEditing) {
      keyField = Marked(key);
      deckField = Marked(deck);
      valueField = Marked(values[0]);
      for (String v in values.sublist(1)) {
        valuesFakeField.add(Marked(v));
      } //for
      tagsField = Marked(widget.cardTags);
    } else {
      keyField = TextField(
        controller: TextEditingController(text: key),
        onChanged: _updateKey,
        keyboardType: TextInputType.multiline,
        maxLines: null,
      );

      deckField = TextField(
        controller: TextEditingController(text: deck),
        onChanged: _updateDeck,
        keyboardType: TextInputType.multiline,
        maxLines: null,
      );

      valueField = TextField(
        controller: TextEditingController(text: values[0]),
        onChanged: (v) => _updateValue(v, 0),
        keyboardType: TextInputType.multiline,
        maxLines: null,
      );

      for (int i = 1; i < values.length; i++) {
        valuesFakeField.add(TextField(
          controller: TextEditingController(text: values[i]),
          onChanged: (v) => _updateValue(v, i),
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ));
      } //for

      tagsField = TextField(
        controller: TextEditingController(text: tags),
        onChanged: _updateTags,
        keyboardType: TextInputType.multiline,
        maxLines: null,
      );
    } //if/elif
  } //toggleEditingWidgets

  /// Togles whether the card is being edited or not. After updating [isEditing], update the widgets
  /// to reflect the new state, and then set state.
  void _toggleEditing() {
    isEditing = !isEditing;
    toggleEditingWidgets();
    setState(() {});
  } //_toggleEditing

  /// Checks if any changes have been made, if so, promps the user whether to discard the changes,
  /// or continue editing. If changes have not been made, or the user discards the changes, pop
  /// the [FlashcardPage] widget.
  void _actionClose() {
    if (isEdited) {
      confirmPopup(context, getLang('hdr_confirm_discard_changes'),
          getLang('msg_confirm_discard_changes'), () => Navigator.pop(context));
    } else {
      Navigator.pop(context);
    }
  } //_actionClose

  /// Sends a confirm prompt to the user asking for confirmation to delete the card. If the user
  /// confirms, then the card is deleted, and the [FlashcardPage] is popped.
  void _actionDelete() {
    if (widget.card == null) {
      Navigator.pop(context);
      return;
    } //if
    confirmPopup(context, getLang('hdr_delete_card'),
        getLang('msg_confirm_delete_card', [widget.card!.id]), () {
      CardList.removeCard(widget.card!);
      Navigator.pop(context);
    });
  } //_actionDelete

  /// If there are changes made to the card, or the card is a new card, save the card. If this
  /// card's ID has changed, check to see if a card with the same ID already exists. If it does,
  /// ask the user to confirm overwrite. If the user confirms, overwrite that card, otherwise, do
  /// nothing.
  void _actionSave() {
    Flashcard card = Flashcard(
        key: key,
        deck: deck,
        values: values,
        tags: tags,
        confidence: widget.cardCnfdnc);

    // Validation for fields.
    // If the key is empty, alert the user, and return.
    if (card.key.isEmpty) {
      confirmPopup(context, getLang('hdr_create_card_error'),
          getLang('msg_create_card_error_key_empty'), () {});
      return;
    }

    // If the deck is empty, alert the user, and return.
    if (card.deck.toString().replaceAll('/', '').isEmpty) {
      confirmPopup(context, getLang('hdr_create_card_error'),
          getLang('msg_create_card_error_deck_empty'), () {});
      return;
    }

    // If the value is empty, alert the user, and return.
    if (card.value.isEmpty) {
      confirmPopup(context, getLang('hdr_create_card_error'),
          getLang('msg_create_card_error_value_empty'), () {});
      return;
    }

    // If the original card is null (this is a new card), or the key or the deck has been modified,
    // check if a card with the same key and deck already exists. If a card does exist, then prompt
    // the user to overwrite, if they confirm, run `_saveCard()`. If the card does not already
    // exist, pop the page, and continue on the save the card.
    if (widget.card == null ||
        widget.cardKey != key ||
        widget.cardDeck != deck) {
      if (CardList.containsCard(card)) {
        confirmPopup(context, getLang('hdr_confirm_overwrite'),
            getLang('msg_confirm_overwrite'), () {
          _saveCard(card);
          Navigator.pop(context);
        });
        return;
      } //if
    } //if
    Navigator.pop(context);
    // Save the cards.
    _saveCard(card);
  } //_actionSave

  /// Saves the given card, and removes the original card. If a card with the same ID as [card]
  /// exists, it will be overwritten.
  void _saveCard(Flashcard card) {
    widget.card == null ? null : CardList.removeCard(widget.card!);
    CardList.addCard(card, true);
  } //_saveCard

  @override
  Widget build(BuildContext context) {
    SimpleText hdrKey =
        SimpleText(getLang('hint_create_new_card_key'), isBold: true);
    SimpleText hdrDeck =
        SimpleText(getLang('hint_create_new_card_deck'), isBold: true);
    SimpleText hdrValue =
        SimpleText(getLang('hint_create_new_card_values'), isBold: true);
    SimpleText hdrValuesFake =
        SimpleText(getLang('hint_create_new_card_values_fake'), isBold: true);
    SimpleText hdrTags =
        SimpleText(getLang('hint_create_new_card_tags'), isBold: true);

    List<Widget> children = [
      hdrKey,
      const Divider(),
      keyField,
      const SizedBox(height: 20),
      hdrValue,
      const Divider(),
      valueField,
      const SizedBox(height: 20),
    ];

    if (valuesFakeField.isNotEmpty) {
      children.addAll([hdrValuesFake, const Divider()]);
      for (int i = 0; i < valuesFakeField.length; i++) {
        children.add(valuesFakeField[i]);
        if (i != valuesFakeField.length)
          children.add(const SizedBox(height: 20));
      } //for
    } //if

    children.addAll([
      hdrDeck,
      const Divider(),
      deckField,
      const SizedBox(height: 20),
      hdrTags,
      const Divider(),
      tagsField
    ]);

    ElevatedButton closeButton =
        ElevatedButton(onPressed: _actionClose, child: Text(getLang('close')));

    ElevatedButton editButton = ElevatedButton(
        onPressed: _toggleEditing,
        child: Text(isEditing ? getLang('preview') : getLang('edit')));

    ElevatedButton deleteButton = ElevatedButton(
        onPressed: _actionDelete, child: Text(getLang('delete')));

    ElevatedButton saveButton =
        ElevatedButton(onPressed: _actionSave, child: Text(getLang('save')));

    children.add(Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Wrap(
            children: [closeButton, deleteButton, editButton, saveButton])));

    Column column = Column(children: children);

    Aspect aspect = Aspect(
        child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(child: column)));

    AppBar appBar = AppBar(
      title: SimpleText(
        getLang('flashcard'),
        isBold: true,
      ),
      centerTitle: true,
    );

    Scaffold scaffold = Scaffold(
      appBar: appBar,
      body: aspect,
    );

    PopScope popScope = PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          _actionClose();
        },
        child: scaffold);
    return popScope;
  } //build
}//_FlashcardPageState
