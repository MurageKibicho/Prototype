// ignore_for_file: file_names

import 'package:flutter/material.dart';

class Settings extends ChangeNotifier
{
  // ignore: prefer_final_fields
  String _jwt = " ";

  get jwt => _jwt;
  set jwt(value){
    _jwt = value;
    notifyListeners();
  }

  void setJWT(String result)
  {
    jwt = result;
    notifyListeners();
  }

}