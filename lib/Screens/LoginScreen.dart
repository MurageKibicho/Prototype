// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:cosines_for_everyone/ClipPaths/HomeClipContainer.dart';
import 'package:cosines_for_everyone/Providers/Settings.dart';
import 'package:cosines_for_everyone/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String emailAddress = "";
  String password = "";
  final storage = FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final settingsClass = Provider.of<Settings>(context);
    return Scaffold(
      body: Material(
        child: Container(
          height: screenHeight,
          width: screenWidth,
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: -50,
                  left: -50,
                  child: HomeClipContainer(height: 200.0,width: 200.0,),
              ),
              Positioned(
                top: 200,
                left: 0,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:<Widget>
                  [
                    TitleWidget(),
                    SizedBox(height: 50,),
                    EmailAndPasswordInput(emailController, passwordController),
                    SizedBox(height: 50,),
                    GestureDetector(
                        onTap: () async
                        {
                          setState(() {
                            emailAddress = emailController.text;
                            password = passwordController.text;
                          });
                          var res = await AttemptLogin(emailAddress,password);
                          if(res == "400")
                            {
                              print("Error");
                            }
                          else
                            {
                              storage.write(key: "jwt", value: res);
                              settingsClass.setJWT(res);
                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeScreen()),(Route<dynamic> route) => false);
                              var res2 = await GetWork(res);
                              print(res2);
                            }
                        },
                        child: SubmitButton(screenWidth,50)),
                  ],
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }
}

Widget TitleWidget()
{
  return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: "Cosines",
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Color(0xffe46b10),
        ),
        children:
        [
          TextSpan(
            text: " for ",
            style: TextStyle(color: Colors.black,fontSize: 30),
          ),
          TextSpan(
            text: "Everyone",
            style: TextStyle(color: Color(0xffe46b10),fontSize: 30),
          ),
        ],
      ),
  );
}

Widget CustomTextEntry(String title,String hintText, bool passwordEntry, TextEditingController controller)
{
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          obscureText: passwordEntry,
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            fillColor: Color(0xfff3f3f4),
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 12,
            )
          ),
        ),
      ],
    ),
  );
}

Widget EmailAndPasswordInput(TextEditingController emailController, TextEditingController passwordController)
{
  return Column(
    children:<Widget>[
      CustomTextEntry("Email Address","obo@example.com",false,emailController),
      SizedBox(height: 10,),
      CustomTextEntry("Password","Testers have special passwords",true,passwordController),
    ],
  );
}

Widget SubmitButton(double width, double height)
{
  return Container(
    height: height,
    width: width*0.8,
    padding: EdgeInsets.all(15),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade200,
          offset: Offset(2,4),
          blurRadius: 5,
          spreadRadius: 2,
        ),
      ],
      gradient: LinearGradient(
        colors: [Color(0xfffbb448),Color(0xffe46b10)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Text(
      "Log In",
      style: TextStyle(fontSize: 15, color: Colors.white),
    ),
  );
}

Future<String> AttemptLogin(String email, String password) async
{
  var url = Uri.parse("https://shaggy-ladybug-41.loca.lt/api/user/login");
  Map data =
      {
        "email": email,
        "password":password
      };
  var body = jsonEncode(data);
  var result = await http.post(
    url,
    headers: <String,String>{"Content-type":"application/json"},
    body: body
  );
  if(result.statusCode == 200)
    {
      return result.body;
    }
  else
    {
      return "400";
    }
}

Future<String> GetWork(String jwt) async
{
  var url = Uri.parse("https://shaggy-ladybug-41.loca.lt/api/getwork");

  var result = await http.get(
      url,
      headers: <String,String>{"Content-type":"application/json", "auth-token" : jwt},
  );
  if(result.statusCode == 200)
  {
    return result.body;
  }
  else
  {
    return "400";
  }
}

