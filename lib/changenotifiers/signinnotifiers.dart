import 'package:flutter/material.dart';

class SignInNotifiers extends ChangeNotifier {
  String errorText = '';
  void setErrorText(String text) {
    errorText = text;
    notifyListeners();
  }
}

