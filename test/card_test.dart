
import 'package:flutter_test/flutter_test.dart';
import 'package:quizflip/models/flashcard.dart';
import 'package:quizflip/models/flashcard_tag.dart';

void main() {
  test("Test the creating of cards", () {
    Flashcard c1 = Flashcard(
      term: "term a",
      definition: "definition a",
      tags: [FlashcardTag(tagStr: "testing1")]);
    expect(c1.term, "term a");
    expect(c1.definition, "definition a");
    expect(c1.tags[0].tagStr, "#testing1");
  });
}