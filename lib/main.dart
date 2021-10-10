import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'Data.dart';
import 'ffi_bridge.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bitmap/bitmap.dart';
import 'package:video_editor/BitmapDCT.dart';

void main ()
{
  runApp(
      MultiProvider(providers:[
        ChangeNotifierProvider(create: (context) => Data(),),
      ],
  child: MyApp(),
      ));
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(
        title: "Pans",
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ImageValueNotifier imageValueNotifier = ImageValueNotifier();
  final FFIBridge _ffiBridge = FFIBridge();
  int displayImage = 0;
  List<String> questions = [];
  Future<List<String>> LoadQuestions() async
  {
    await rootBundle.loadString("assets/data.txt").then((q)
    {
      for(String i in LineSplitter().convert(q))
      {
        questions.add(i);
      }
    });
    return questions;
  }
  _setup() async
  {
    List<String> _questions = await LoadQuestions();
    setState(() {
      questions = _questions;
    });
    imageValueNotifier.saveInitialFile(questions);
    print("Saved First file");
  }
  @override
  void initState() {
    super.initState();
    _setup();
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final dataClass = Provider.of<Data>(context);
    void ChangeImage(List<String> questions, int quantizationLevel) {
      if(dataClass.availableImages[quantizationLevel] == 0)
        {
          imageValueNotifier.saveFile(questions,quantizationLevel);
          print("Here");
          dataClass.setAvailable(quantizationLevel);
        }
      else
        {
          imageValueNotifier.loadFile(quantizationLevel);
          print("Avaliable");
        }
      /*if (imageValueNotifier.value != null) {
        imageValueNotifier.saveFile(questions,quantizationLevel);
        print("Here");
      }
      else
      {
        imageValueNotifier.saveFile(questions,quantizationLevel);
      }*/
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          imageValueNotifier.reset();
        },
        child: Center(
          child: ValueListenableBuilder<String?>(
            valueListenable: imageValueNotifier,
            builder: (BuildContext context, String ? result, Widget? child) {
              return Column(
                children: <Widget>[
                  SafeArea(
                    top: true,
                    child: Container(
                      color: CupertinoColors.black,
                      height: screenHeight / 2,
                      width: screenWidth,
                      child: (result == null) ?
                      CircularProgressIndicator()
                          :
                          Image.file(
                            File(result),
                            ),

                    ),
                  ),
                  const Text("Tap image to reset"),
                  Text("Quantization Level: ${dataClass.quantizationLevel}"),
              TextButton(
              onPressed: ()
              {
                //ChangeImage(questions, int.parse(dataClass.quantizationLevel));
              },
              child: const Text(
              "Press Here:",
              style: TextStyle(fontSize: 10),
              ),
              ),
              Slider(
                  value: dataClass.quantizationLevel.toDouble(),
                  min: 0,
                  max: 10,
                  divisions:10,
                  onChanged: (value)
                  {
                    dataClass.setQuantization(value);
                    ChangeImage(questions, dataClass.quantizationLevel);
                  }
              ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback opereshon;

  const CustomButton({Key? key, required this.opereshon}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: opereshon,
      child: const Text(
        "Press Here",
        style: TextStyle(fontSize: 10),
      ),
    );
  }
}



// stores headless contents
class ImageValueNotifier extends ValueNotifier<String?> {
  ImageValueNotifier() : super(null);

  late String initial;
  void reset()
  {
    value = initial;
  }

  void loadFile(int quantization) async
  {
    String filePath = await getFilePath(quantization);
    File file = File(filePath);
    if(file.existsSync())
    {
      value = filePath;
      initial = value!;
    }
  }

  void saveInitialFile(List<String> questions) async
  {
    int quantization = 1;
    String bitmapPath = await getInitialPath(0,quantization);
    String pgmPath = await getInitialPath(1,quantization);
    final FFIBridge _ffiBridge2 = FFIBridge();
    int quantizationLevel = quantization;
    Pointer<Int32> coefficients = calloc<Int32>(1080*1920);
    for(int i = 0; i < 1080*1920; i++)
    {
      coefficients[i] = int.parse(questions.elementAt(i));
    }
    Pointer<Int32> XY = calloc<Int32>(2);
    XY[0] = 1080;
    XY[1] = 1920;
    int result = _ffiBridge2.decodeFile(coefficients,bitmapPath,pgmPath,XY,quantizationLevel);
    value = bitmapPath;
  }


  void saveFile(List<String> questions,int quantization) async
  {
    String bitmapPath = await getInitialPath(0,quantization);
    String pgmPath = await getInitialPath(1,1);
    final FFIBridge _ffiBridge2 = FFIBridge();
    int quantizationLevel = quantization;
    Pointer<Int32> XY = calloc<Int32>(2);
    XY[0] = 1080;
    XY[1] = 1920;
    int result = _ffiBridge2.quantizeFile(pgmPath,bitmapPath, XY,quantizationLevel);
    value = bitmapPath;
  }
}

Future<String> getInitialPath(int type, int quantizationLevel) async
{
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String documentsPath = documentsDirectory.path;
  late String filePath = " ";
  if(type == 0)
  {
    filePath = "${documentsPath}/sample-${quantizationLevel}.bmp";
  }
  else
    {
      filePath = "${documentsPath}/sample-${quantizationLevel}.pgm";
    }
  return filePath;
}

Future<String> getFilePath(int quantizationLevel) async
{
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String documentsPath = documentsDirectory.path;
  String filePath = "${documentsPath}/sample-${quantizationLevel}.bmp";
  return filePath;
}


Future<Uint8List> rotateClockwiseImageIsolate(List imageData) async {
  final Uint8List byteData = imageData[0];
  final int width = imageData[1];
  final int height = imageData[2];

  final Bitmap bigBitmap = Bitmap.fromHeadless(width, height, byteData);

  final Bitmap returnBitmap = bigBitmap.apply(BitmapRotate.rotateClockwise());

  return returnBitmap.content;
}


Future<Uint8List> makeEverythingBlack(List imageData) async
{
  final Uint8List bytes = imageData[0];
  final int width = imageData[1];
  final int height = imageData[2];
  final Bitmap bigBitmap = Bitmap.fromHeadless(width, height, bytes);
  final Bitmap returnBitmap = bigBitmap.apply(BitmapBrightness(0.1));
  return returnBitmap.content;
}

