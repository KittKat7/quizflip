
import 'package:flutter/material.dart';
import 'package:kittkatflutterlibrary/kittkatflutterlibrary.dart';

import '../models/flashcard.dart';

void showEditCardPopup(
  BuildContext context,
  Flashcard? flashcard,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(flashcard == null? "New" : "Edit"),
        content: Text("TEMP"),
        actions: [
          MaterialButton(
            child: Text(getLang('btnCancel')),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          MaterialButton(
            child: Text(getLang('btnConfirm')),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}