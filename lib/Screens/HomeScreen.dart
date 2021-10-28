// ignore_for_file: file_names, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cosines_for_everyone/Providers/Settings.dart';
import 'package:cosines_for_everyone/Screens/ImageScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          child: Column(
            children:<Widget>[
              SizedBox(height: 90,),
              TitleSection(screenHeight*0.05, screenWidth),
              AccountSection(screenHeight/4,screenWidth),
              SizedBox(height: 10,),
              GetWorkButton(context, settingsClass.jwt),
              SizedBox(height: 10,),
              SettingsButton(),
              SizedBox(height: 10,),
              SignOutButton(),
              //SettingsSection(screenHeight/3,screenWidth)
            ],
          ),
        ),
      ),
    );
  }
}

Widget GetWorkButton(BuildContext context, String jwt)
{
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      minimumSize: Size(280,80),
      primary: Color(0xffe46b10),
      side: BorderSide(width: 3, color:Color(0xffe46b10)),
    ),
      onPressed: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ImageScreen(jwt: jwt)));
      },
      child: Text("Start work"),
  );
}

Widget SignOutButton()
{
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      minimumSize: Size(200,80),
      primary: Color(0xffe46b10),
      side: BorderSide(width: 3, color:Color(0xffe46b10)),
    ),
    onPressed: (){},
    child: Text("Sign Out"),
  );
}

Widget SettingsButton()
{
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      minimumSize: Size(200,80),
      primary: Color(0xffe46b10),
      side: BorderSide(width: 3, color:Color(0xffe46b10)),
    ),
    onPressed: (){},
    child: Text("Settings"),
  );
}

Widget TitleSection(double height,double screenWidth)
{
  return Container(
    height: height,
    width: screenWidth,
    color: Colors.white70,
    child: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: "Cosines",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xffe46b10),
        ),
        children:
        [
          TextSpan(
            text: " for ",
            style: TextStyle(color: Colors.black,fontSize: 15),
          ),
          TextSpan(
            text: "Everyone",
            style: TextStyle(color: Color(0xffe46b10),fontSize: 15),
          ),
        ],
      ),
    ),
  );
}
Widget AccountSection(double height, double screenWidth)
{
  return Container(
    height: height,
    width: screenWidth,
    padding: EdgeInsets.only(left: 20.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children:<Widget>[
        Center(child: Text("Account details")),
        SizedBox(height: 1,),
        Center(
          child: Text("\u00242500.00",style: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.bold, fontSize: 60)),
        ),
        SizedBox(height: 3,),
        Center(child: Text("Cash Balance",style: TextStyle(color: Color(0xffe46b10),),),),
        SizedBox(height: 10,),
        Center(child: Text("cdshbcyeyr8723t7tr2")),
        Center(child: Text("Account number",style: TextStyle(color: Color(0xffe46b10),),),),
      ],
    ),
  );
}

Widget SettingsSection(double height, double screenWidth)
{
  return Container(
    height: height,
    width: screenWidth,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xfffbb448),Color(0xffe46b10)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
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

