import 'package:flutter/material.dart';
import 'package:kittkatflutterlibrary/kittkatflutterlibrary.dart';

void showLoadingPopup(
  BuildContext context,
) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(getLang('hdrLoading')),
        content: Text(getLang('msgLoading')),
      );
    },
  );
}