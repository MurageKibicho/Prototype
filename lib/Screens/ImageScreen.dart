// ignore_for_file: file_names, prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace, non_constant_identifier_names

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:cosines_for_everyone/CLibs/ffi_bridge.dart';
import 'package:cosines_for_everyone/Providers/Data.dart';
import 'package:cosines_for_everyone/Providers/Settings.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'HomeScreen.dart';

class ImageScreen extends StatefulWidget {
  final String jwt;

  const ImageScreen({Key? key, required this.jwt}) : super(key: key);
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  double value = 0;

  /*New */
  ImageValueNotifier imageValueNotifier = ImageValueNotifier();
  final storage = FlutterSecureStorage();
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
    imageValueNotifier.LoadFileFromNetwork(widget.jwt);
    imageValueNotifier.NetworkFileToImage();
    //imageValueNotifier.saveInitialFile(questions);
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
    }
    return Scaffold(
      body: Material(
        child: Container(
          height: screenHeight,
          width: screenWidth,
          child: Column(
            children:<Widget>[
              SizedBox(height: 60,),
              ExitButtonResetButton(50, screenWidth,context),
              ValueListenableBuilder<String?>(
                valueListenable: imageValueNotifier,
                  builder: (BuildContext context, String ? result, Widget? child) {
                    return Container(
                      width: screenWidth,
                      height: screenHeight/2,
                      child: (result == null) ?
                      CircularProgressIndicator()
                          :
                      Container(
                        decoration: BoxDecoration(
                          color:Colors.black,
                          image: DecorationImage(
                            image: FileImage(File(result)),

                          ),
                        ),
                      ),
                    );
                  },
              ),
              SizedBox(height: 30,),
              SizedBox(height: 30,),
              Slider(
                thumbColor: Color(0xffe46b10),
                  activeColor: Color(0xfffbb448),
                  inactiveColor: Colors.grey,
                  value: dataClass.quantizationLevel.toDouble(),
                  min: 1,
                  max: 10,
                  divisions:10,
                  onChanged: (value)
                  {
                    dataClass.setQuantization(value);
                    ChangeImage(questions, dataClass.quantizationLevel);
                  }
              ),
              SizedBox(height: 30,),
              SubmitButton(screenWidth),
            ],
          ),
        ),
      ),
    );
  }
}

Widget SubmitButton(double screenWidth)
{
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      minimumSize: Size(screenWidth/2,50),
      primary: Color(0xffe46b10),
      side: BorderSide(width: 3, color:Color(0xffe46b10)),
    ),
    onPressed: (){},
    child: Text("Submit"),
  );
}

Widget ExitButtonResetButton(double arrowHeight, double screenWidth, BuildContext context)
{
  return Container(
    padding: EdgeInsets.only(left: 20,bottom: 20),
    height: arrowHeight,
    width: screenWidth,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: ()
          {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          },
          child: Row(
            children:<Widget>[
              Icon(
                Icons.arrow_back_ios,
                color: Color(0xffe46b10),
              ),
              Text("Exit",style: TextStyle(color: Color(0xffe46b10),fontSize: 20),),
            ],
          ),
        ),
        Row(
          children:<Widget>[
            Icon(
              Icons.refresh,
              color: Color(0xffe46b10),
            ),
            Text("Reset",style: TextStyle(color: Color(0xffe46b10),fontSize: 20),),
            SizedBox(width: 15,),
          ],
        ),
      ],
    ),
  );
}

Widget ImageContainer(double height, double screenWidth)
{
  return Container(
    height: height,
    width: screenWidth,
    color: Colors.black,
  );
}



Widget SliderTwo(double arrowHeight, double screenWidth)
{
  return Container(
    height: arrowHeight,
    width: screenWidth,
    color: Colors.green,
  );
}

class ImageValueNotifier extends ValueNotifier<String?> {
  ImageValueNotifier() : super(null);

  late String initial;

  void LoadFileFromNetwork(String jwt)async
  {
    var response = await GetWork(jwt);
    String filePath = await getNetworkPath();
    File file = File(filePath);
    await file.writeAsBytes(response);
    print("Dowloaded!");
  }

  void NetworkFileToImage()async
  {
    String filePath = await getNetworkPath();
    final FFIBridge _ffiBridge = FFIBridge();
    String bitmapPath = await getInitialPath(0,1);
    String pgmPath = await getInitialPath(1,1);
    File file = File(filePath);
    if(file.existsSync())
    {
      int result = _ffiBridge.decompressFile(bitmapPath, pgmPath, filePath);
      value = bitmapPath;
    }

  }

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
    print(bitmapPath);
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

Future<String> getNetworkPath() async
{
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String documentsPath = documentsDirectory.path;
  late String filePath = " ";
  filePath = "${documentsPath}/bicho.bae";
  return filePath;
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

Future<Uint8List> GetWork(String jwt) async
{
  var url = Uri.parse("https://shaggy-ladybug-41.loca.lt/api/getwork");

  var result = await http.get(
    url,
    headers: <String,String>{"Content-type":"application/json", "auth-token" : jwt},
  );
  if(result.statusCode == 200)
  {
    return result.bodyBytes;
  }
  else
  {
    List <int> nullList = [1,0,0];
    return Uint8List.fromList(nullList);
  }
}


