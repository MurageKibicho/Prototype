// ignore_for_file: file_names

import 'dart:typed_data';

import 'package:bitmap/bitmap.dart';
import 'package:flutter/material.dart';

class BitmapDCT implements BitmapOperation
{
    final double quantizationLevel;
    BitmapDCT(double quantizationLevel) :
          quantizationLevel = quantizationLevel.clamp(-1.0, 1.0);
  @override
  Bitmap applyTo(Bitmap bitmap) {
    final Bitmap copy = bitmap.cloneHeadless();
    _dctCore(copy.content, quantizationLevel);
    return copy;
  }
  void _dctCore(Uint8List sourceBmp, double quantizationLevel)
  {
    if(quantizationLevel == 0.0)
      {
        return;
      }

  }

}