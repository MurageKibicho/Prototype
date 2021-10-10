import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';

typedef TemperatureFunction = Double Function();
typedef TemperatureFunctionDart = double Function();

typedef SaveToFileFunction = Int32 Function(Pointer<Utf8> string);
typedef SaveToFileFunctionDart = int Function(Pointer<Utf8> string);


typedef ForecastFunction = Pointer<Utf8> Function();
typedef ForecastFunctionDart = Pointer<Utf8> Function();


typedef DecodeFunction = Int32 Function(Pointer<Int32> coefficients,Pointer<Utf8> fileName,Pointer<Int32> XY, Int32 quantizationLevel);
typedef DecodeFunctionDart = int Function(Pointer<Int32> coefficients,Pointer<Utf8> fileName,Pointer<Int32> XY, int quantizationLevel);

class FFIBridge {
  late TemperatureFunctionDart _getTemperature;
  late ForecastFunctionDart _getForecast;
  late SaveToFileFunctionDart _saveToFile;
  late DecodeFunctionDart _decodeFunction;


  FFIBridge() {
    final dl = Platform.isAndroid
        ? DynamicLibrary.open('libweather.so')
        : DynamicLibrary.process();

    _decodeFunction = dl.lookupFunction<DecodeFunction, DecodeFunctionDart>("ReceiveMCUs");

  }

  double getTemperature() => _getTemperature();
  int saveToFile(String filePath)
  {
    return _saveToFile(filePath.toNativeUtf8());
  }
  //int *coefficients, char *fileName, int *XY, int quantizationLevel
  int decodeFile(Pointer<Int32>coefficients,String fileName,Pointer<Int32> XY, int quantizationLevel)
  {

    return _decodeFunction(coefficients,fileName.toNativeUtf8(), XY, quantizationLevel);
  }

  String getForecast()
  {
    final pointer = _getForecast();
    final forecast = pointer.toDartString();
    calloc.free(pointer);
    return forecast;
  }
}
