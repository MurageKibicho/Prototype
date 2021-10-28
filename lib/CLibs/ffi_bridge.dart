import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';

typedef DecodeFunction = Int32 Function(Pointer<Int32> coefficients,Pointer<Utf8> fileName,Pointer<Utf8> fileNameNew,Pointer<Int32> XY, Int32 quantizationLevel);
typedef DecodeFunctionDart = int Function(Pointer<Int32> coefficients,Pointer<Utf8> fileName,Pointer<Utf8> fileNameNew,Pointer<Int32> XY, int quantizationLevel);

typedef QuantizeFunction = Int32 Function(Pointer<Utf8> fileName, Pointer<Utf8> name,Pointer<Int32> XY, Int32 quantizationLevel);
typedef QuantizeFunctionDart = int Function(Pointer<Utf8> fileName, Pointer<Utf8> name,Pointer<Int32> XY, int quantizationLevel);

//int UnpackageAndReceiveFrame(char *fileName, char *pgmName, char *receivedFileLocation)
typedef DecompressFunction = Int32 Function(Pointer<Utf8> bitMapName,Pointer<Utf8> pgmName,Pointer<Utf8> receivedFileLocation);
typedef DecompressFunctionDart = int Function(Pointer<Utf8> bitMapName,Pointer<Utf8> pgmName,Pointer<Utf8> receivedFileLocation);
class FFIBridge
{

  late DecodeFunctionDart _decodeFunction;
  late QuantizeFunctionDart _quantizeFunction;
  late DecompressFunctionDart _decompressFunction;

  FFIBridge()
  {
    final dl = Platform.isAndroid ? DynamicLibrary.open('libweather.so') : DynamicLibrary.process();
    _decodeFunction = dl.lookupFunction<DecodeFunction, DecodeFunctionDart>("ReceiveMCUs");
    _quantizeFunction = dl.lookupFunction<QuantizeFunction, QuantizeFunctionDart>("SingleFrameQuantizeDequantize");
    _decompressFunction = dl.lookupFunction<DecompressFunction, DecompressFunctionDart>("UnpackageAndReceiveFrame");
  }

  //int *coefficients, char *fileName, int *XY, int quantizationLevel
  int decodeFile(Pointer<Int32>coefficients,String fileName,String fileNameNew,Pointer<Int32> XY, int quantizationLevel)
  {

    return _decodeFunction(coefficients,fileName.toNativeUtf8(),fileNameNew.toNativeUtf8(), XY, quantizationLevel);
  }

  int quantizeFile(String fileName, String name, Pointer<Int32> XY, int quantizationLevel)
  {

    return _quantizeFunction(fileName.toNativeUtf8(),name.toNativeUtf8(), XY, quantizationLevel);
  }

  int decompressFile(String bitMapName, String pgmName, String receivedFileLocation)
  {
    return _decompressFunction(bitMapName.toNativeUtf8(),pgmName.toNativeUtf8(),receivedFileLocation.toNativeUtf8());
  }


}
