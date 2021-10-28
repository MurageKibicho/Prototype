// ignore_for_file: prefer_const_constructors

import 'package:cosines_for_everyone/Providers/Settings.dart';
import 'package:cosines_for_everyone/Screens/HomeScreen.dart';
import 'package:cosines_for_everyone/Screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'Providers/Data.dart';
import 'Screens/ImageScreen.dart';

Future<void> main ()
async {
  runApp(
      MultiProvider(providers:[
        ChangeNotifierProvider(create: (context) => Settings(),),
        ChangeNotifierProvider(create: (context) => Data(),),
      ],
        child: MyApp(),
      ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.orange,
        textTheme: GoogleFonts.creteRoundTextTheme().copyWith(
          bodyText1: GoogleFonts.montserrat(),
        )
      ),
      home: LoginScreen(),
    );
  }
}



