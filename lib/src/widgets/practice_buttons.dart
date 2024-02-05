import 'package:flutter/material.dart';
import 'package:kkfl_lang/kkfl_lang.dart';
import 'package:kkfl_routing/kkfl_routing.dart';
import 'package:kkfl_widgets/kkfl_widgets.dart';
import 'package:quizflip/src/widgets/practice_page.dart';

/// [PracticeButtons] class. A set of buttons used by the user to start the different practice modes.
class PracticeButtons extends StatelessWidget {
  const PracticeButtons({super.key});

  @override
  Widget build(BuildContext context) {

    /// [practiceButton] This button is used to switch the user into the practice mode.
    ElevatedButton practiceButton = ElevatedButton(
      onPressed: () => Navigator.push(context, genRoute(const PracticePage())),
      child: Marked(getLang('btn_practice')));
    return practiceButton; // TODO
  }//build
  
}//PracticeButtons

// /// [_PracticeButton] class. This is a class used to create the practice buttons.
// class PracticeButton extends StatelessWidget {
  
//   @override
//   Widget build(BuildContext context) {
    
//   }//build
// }//PracticeButton