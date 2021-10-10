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
  }
  @override
  void initState() {
    super.initState();
    imageValueNotifier.loadFile();
    _setup();
  }

  void ChangeImage(List<String> questions) {
    if (imageValueNotifier.value != null) {
      imageValueNotifier.saveFile(questions);
      print("Here");
    }
    else
      {
        print("NUll");
      }
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final dataClass = Provider.of<Data>(context);

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          imageValueNotifier.reset();
        },
        child: Center(
          child: ValueListenableBuilder<String?>(
            valueListenable: imageValueNotifier,
            builder: (BuildContext context, String ? result, Widget? child) {
              if (result == null) {
                return const CircularProgressIndicator();
              }
              return Column(
                children: <Widget>[
                  SafeArea(
                    top: true,
                    child: Container(
                      color: CupertinoColors.black,
                      height: screenHeight / 2,
                      width: screenWidth,
                      child: Image.file(
                          File(result),
                      ),
                    ),
                  ),
                  const Text("Tap image to reset"),
                  Text("ImageSize "),
                  TextButton(
                    child: Text("Click Here : "),
                    onPressed: (){print("NO ${int.parse(questions.elementAt(2073536))}");},//rotateClockwiseImage,
                  ),
              TextButton(
              onPressed: ()
              {
                ChangeImage(questions);
              },
              child: const Text(
              "Press Here",
              style: TextStyle(fontSize: 10),
              ),
              )
                  //CustomButton(opereshon: ChangeImage),

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

  void loadFile() async
  {
    String filePath = await getFilePath();
    File file = File(filePath);
    if(file.existsSync())
    {
      value = filePath;
      initial = value!;
    }
  }

  void saveFile(List<String> questions) async
  {
    String path = await getFilePath();
    final FFIBridge _ffiBridge2 = FFIBridge();
    int quantizationLevel = 1;
    Pointer<Int32> coefficients = calloc<Int32>(1080*1920);
    for(int i = 0; i < 1080*1920; i++)
    {
      coefficients[i] = int.parse(questions.elementAt(i));
    }
    Pointer<Int32> XY = calloc<Int32>(2);
    XY[0] = 1080;
    XY[1] = 1920;
    int result = _ffiBridge2.decodeFile(coefficients,path,XY,quantizationLevel);
    print("Result : ${int.parse(questions.elementAt(2073536))}");
    value = path;
  }


}

Future<String> getFilePath() async
{
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String documentsPath = documentsDirectory.path;
  String filePath = "${documentsPath}/sample.bmp";
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

