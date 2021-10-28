// ignore_for_file: file_names, prefer_const_constructors
import 'package:google_fonts/google_fonts.dart';

import 'dart:math';
import 'package:cosines_for_everyone/ClipPaths/HomeClipPath.dart';
import 'package:flutter/material.dart';

class HomeClipContainer extends StatefulWidget {
  final double height;
  final double width;

  const HomeClipContainer({Key? key, required this.height, required this.width}) : super(key: key);

  @override
  _HomeClipContainerState createState() => _HomeClipContainerState();
}

class _HomeClipContainerState extends State<HomeClipContainer> {
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 4,
      child: ClipPath(
        clipper: HomeClipPath(),
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xfffbb448),Color(0xffe46b10)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }
}
