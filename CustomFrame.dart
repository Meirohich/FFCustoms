// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

class CustomFrame extends StatefulWidget {
  const CustomFrame({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<CustomFrame> createState() => _CustomFrameState();
}

class _CustomFrameState extends State<CustomFrame> {
  @override
  Widget build(BuildContext context) {
    // return ClipPath(
    //   clipper: _CustomRoundedClipper(),
    //   child: Container(
    //     decoration: BoxDecoration(
    //       border: Border.all(color: Colors.white, width: 1.0),
    //       color: FlutterFlowTheme.of(context).accent2,
    //     ),
    //   ),
    // );
    return CustomPaint(
      painter: PathPainter(
          strokeColor: FlutterFlowTheme.of(context).primaryBackground),
    );
  }
}

class PathPainter extends CustomPainter {
  final Color strokeColor;

  PathPainter({
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    double sideRadius = 11.0;

    path.moveTo(0, sideRadius);
    path.lineTo(0, size.height - sideRadius);
    path.quadraticBezierTo(
        sideRadius, size.height - sideRadius, sideRadius, size.height);

    path.lineTo(size.width - sideRadius, size.height);
    path.quadraticBezierTo(size.width - sideRadius, size.height - sideRadius,
        size.width, size.height - sideRadius);
    path.lineTo(size.width, sideRadius);
    path.quadraticBezierTo(
        size.width - sideRadius, sideRadius, size.width - sideRadius, 0);
    path.lineTo(sideRadius, 0);
    path.quadraticBezierTo(sideRadius, sideRadius, 0, sideRadius);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// class _CustomRoundedClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     double sideRadius = 15.0;

//     path.moveTo(0, sideRadius);
//     path.lineTo(0, size.height - sideRadius);
//     path.quadraticBezierTo(
//         sideRadius, size.height - sideRadius, sideRadius, size.height);

//     path.lineTo(size.width - sideRadius, size.height);
//     path.quadraticBezierTo(size.width - sideRadius, size.height - sideRadius,
//         size.width, size.height - sideRadius);
//     path.lineTo(size.width, sideRadius);
//     path.quadraticBezierTo(
//         size.width - sideRadius, sideRadius, size.width - sideRadius, 0);
//     path.lineTo(sideRadius, 0);
//     path.quadraticBezierTo(sideRadius, sideRadius, 0, sideRadius);

//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
// }
