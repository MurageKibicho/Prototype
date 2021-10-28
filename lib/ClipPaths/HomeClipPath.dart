// ignore_for_file: file_names, prefer_const_constructors
import 'package:flutter/cupertino.dart';

class HomeClipPath extends CustomClipper<Path>
{
  @override
  Path getClip(Size size) {
    var height = size.height;
    var width = size.width;
    var path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, height);
    path.lineTo(size.width, 0);

    var controlPoint2 = Offset(0, 0);
    var endPoint2 = Offset(width * 0.2, height * 0.3);
    path.quadraticBezierTo(controlPoint2.dx, controlPoint2.dy, endPoint2.dx, endPoint2.dy);

    var controlPoint5 = Offset(width * 0.3, height * 0.5);
    var endPoint5 = Offset(width * 0.23, height * 0.6);
    path.quadraticBezierTo(controlPoint5.dx, controlPoint5.dy, endPoint5.dx, endPoint5.dy);

    var controlPoint3 = Offset(0,height);
    var endPoint3 = Offset(width, height);
    path.quadraticBezierTo(controlPoint3.dx, controlPoint3.dy, endPoint3.dx, endPoint3.dy);

    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }

}