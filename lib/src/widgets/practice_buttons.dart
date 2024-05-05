import 'package:flutter/material.dart';
import 'package:kittkatflutterlibrary/lang/kkfl_lang.dart';
import 'package:kittkatflutterlibrary/routing/kkfl_routing.dart';
import 'package:kittkatflutterlibrary/widgets/kkfl_widgets.dart';
import 'package:quizflip/src/widgets/practice_page.dart';
import 'package:quizflip/src/widgets/review_page.dart';

/// [PracticeButtons] class. A set of buttons used by the user to start the different practice modes.
class PracticeButtons extends StatelessWidget {
  const PracticeButtons({super.key});

  @override
  Widget build(BuildContext context) {
    /// [practiceButton] This button is used to switch the user into the practice mode.
    ElevatedButton practiceButton = ElevatedButton(
        onPressed: () =>
            Navigator.push(context, genRoute(const PracticePage())),
        child: Marked(getLang('btn_practice')));

    /// reviewButton This button is used to switch the user into the review mode.
    ElevatedButton reviewButton = ElevatedButton(
        onPressed: () => Navigator.push(context, genRoute(const ReviewPage())),
        child: Marked(getLang('btn_review')));

    return Wrap(children: [practiceButton, reviewButton]);
  } //build
}//PracticeButtons

// /// [_PracticeButton] class. This is a class used to create the practice buttons.
// class PracticeButton extends StatelessWidget {
  
//   @override
//   Widget build(BuildContext context) {
    
//   }//build
// }//PracticeButton