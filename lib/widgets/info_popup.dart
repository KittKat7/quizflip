
import 'package:flutter/material.dart';
import 'package:kittkatflutterlibrary/lang/kkfl_lang.dart';

void showInfoPopup(
  BuildContext context,
  String title,
  String message,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
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