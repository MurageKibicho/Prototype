// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Data extends ChangeNotifier
{
  int _quantizationLevel = 1;

  List<int> _availableImages = List.filled(11, 0);

  get quantizationLevel => _quantizationLevel;
  set quantizationLevel(value){
    _quantizationLevel = value;
    notifyListeners();
  }

  void setQuantization(double result)
  {
    quantizationLevel = result.ceil();
    notifyListeners();
  }

  get availableImages => _availableImages;
  set availableImages(value){
    _availableImages = value;
    notifyListeners();
  }

  void setAvailable(int index)
  {
    availableImages[index] = 1;
    notifyListeners();
  }

}