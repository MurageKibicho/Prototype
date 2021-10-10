// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Data extends ChangeNotifier
{
  int _display = 0;

  get display => _display;
  set display(value){
    _display = value;
    notifyListeners();
  }

  void setDisplay(int result) {
    display = result;
    notifyListeners();
  }

}