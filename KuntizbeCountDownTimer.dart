//circular_countdown_timer: ^0.2.3
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

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:kuntizbe/flutter_flow/flutter_flow_timer.dart';

class KuntizbeCountDownTimer extends StatefulWidget {
  const KuntizbeCountDownTimer({
    super.key,
    required this.width,
    required this.height,
    required this.tan,
    required this.kun,
    required this.besin,
    required this.ekindi,
    required this.aqsham,
    required this.quptan,
    required this.imsak,
    // required this.ishrak,
    // required this.kerehat,
    // required this.isfirar,
    // required this.ishtibaq,
    // this.asriauual,
    // this.ishaisani,
  });

  final double width;
  final double height;
  final String tan;
  final String kun;
  final String besin;
  final String ekindi;
  final String aqsham;
  final String quptan;
  // final String ishrak;
  // final String kerehat;
  // final String isfirar;
  // final String ishtibaq;
  final String imsak;
  // final String? asriauual;
  // final String? ishaisani;

  @override
  State<KuntizbeCountDownTimer> createState() => _KuntizbeCountDownTimerState();
}

class _KuntizbeCountDownTimerState extends State<KuntizbeCountDownTimer> {
  final CountDownController _controller = CountDownController();
  FlutterFlowTimerController timerController = FlutterFlowTimerController(
    StopWatchTimer(
      mode: StopWatchMode.countDown,
    ),
  );

  final ValueNotifier<int> _updateNotifier =
      ValueNotifier<int>(0); // New notifier

  Key _timerKey = UniqueKey();

  late List<String> timeIntervals;
  late List<String> appStateValues;
  //late List<String> timesForInnerRadius;
  //late List<String> timesForInnerRadiusText;
  late int currentIndex;
  late String currentAppState;
  late int timeUntilNextInterval;
  late int totalInterval;
  late int _duration;
  late int _leftDuration;
  late int _skippedDuration;
  late int _forNextInterval;
  late int newInterval;
  String nextAppState = '';
  String afterNextAppState = '';
  int current_time = 0;
  //String? selectedTime;

  @override
  void initState() {
    super.initState();
    _initializeCountdown();
    _controller.start();
    timerController.onStartTimer();
  }

  @override
  void didUpdateWidget(KuntizbeCountDownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tan != oldWidget.tan || widget.quptan != oldWidget.quptan) {
      setState(() {
        _initializeCountdown();
        _controller.reset();
        _controller.start();

        timerController.timer
            .setPresetTime(mSec: timeUntilNextInterval, add: false);
        timerController.onResetTimer();
        timerController.onStartTimer();
        _timerKey = UniqueKey();
      });
      _updateNotifier.value++;
    }
  }

  @override
  void dispose() {
    timerController.dispose();
    super.dispose();
  }

  void _initializeCountdown() {
    timeIntervals = [
      'Имсак',
      'Таң',
      'Күн',
      'Бесін',
      'Екінді',
      'Ақшам',
      'Құптан'
    ];
    appStateValues = [
      widget.imsak,
      widget.tan,
      widget.kun,
      widget.besin,
      widget.ekindi,
      widget.aqsham,
      widget.quptan,
    ];
    // timesForInnerRadiusText = [
    //   'Таң',
    //   'Күн',
    //   'Бесін',
    //   'Екінді',
    //   'Ақшам',
    //   'Құптан',
    //   'Ишрак',
    //   'Керахат',
    //   'Исфирар',
    //   'Иштибак'
    // ];

    // timesForInnerRadius = [
    //   widget.tan,
    //   widget.kun,
    //   widget.besin,
    //   widget.ekindi,
    //   widget.aqsham,
    //   widget.quptan,
    //   widget.ishrak,
    //   widget.kerehat,
    //   widget.isfirar,
    //   widget.ishtibaq,
    // ];

    // Conditionally add optional times if they are provided
    // if (widget.imsak != "empty") {
    //   timesForInnerRadius.add(widget.imsak!);
    //   timesForInnerRadiusText.add('Имсак');
    // }
    // if (widget.asriauual != "empty") {
    //   timesForInnerRadius.add(widget.asriauual!);
    //   timesForInnerRadiusText.add('Асри Әууәл');
    // }
    // if (widget.ishaisani != "empty") {
    //   timesForInnerRadius.add(widget.ishaisani!);
    //   timesForInnerRadiusText.add('Ишаи Сани');
    // }

    currentAppState = _findCurrentAppState();

    timeUntilNextInterval = _calculateTimeUntilNextInterval();

    totalInterval =
        _calculateTotalInterval(timeIntervals.indexOf(currentAppState) + 1);

    _duration = (totalInterval / 1000).toInt();
    _leftDuration = (timeUntilNextInterval / 1000).toInt();
    _skippedDuration = _duration - _leftDuration;
    _forNextInterval = (newInterval / 1000).toInt();
  }

  String extractValidTime(String input) {
    // Regular expression to match hh:mm format
    final regex = RegExp(r'(\d{1,2}:\d{2})');
    // Find the first match in the input string
    final match = regex.firstMatch(input);

    if (match != null) {
      // If a match is found, return the matched string
      return match.group(0) ?? '';
    } else {
      // If no valid time is found, throw a FormatException
      throw FormatException('Invalid time format: $input');
    }
  }

  List<String> _validateAndParseTime(String time) {
    String validTime = extractValidTime(time);
    return validTime.split(':');
  }

  String _findCurrentAppState() {
    DateTime currentTime = DateTime.now();
    String currentAppState = 'Құптан'; // Default to the last interval
    int currentIndex = 6; // Default to the last interval index

    for (int i = 0; i < timeIntervals.length; i++) {
      try {
        List<String> timeParts = _validateAndParseTime(appStateValues[i]);
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        DateTime intervalTime = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          hour,
          minute,
        );

        if (currentTime.isBefore(intervalTime)) {
          // This is the first interval that is after the current time
          currentAppState = timeIntervals[
              (i - 1 + timeIntervals.length) % timeIntervals.length];
          currentIndex = (i - 1 + timeIntervals.length) % timeIntervals.length;
          break;
        }
      } catch (e) {
        print('Error parsing time: ${appStateValues[i]} - $e');
        // Handle the error, maybe set a default value or skip the iteration
      }
    }

    // Handle case where currentTime is after all intervals
    if (currentTime.isAfter(DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      int.parse(_validateAndParseTime(appStateValues.last)[0]),
      int.parse(_validateAndParseTime(appStateValues.last)[1]),
    ))) {
      currentAppState = timeIntervals.last;
      currentIndex = timeIntervals.length - 1;
    }

    setState(() {
      FFAppState().currentNamaz = currentAppState;
    });

    return currentAppState;
  }

  int _calculateTimeUntilNextInterval() {
    DateTime currentTime = DateTime.now();
    String tempNextAppState = '';
    String tempNextNextAppState = '';

    for (int i = 0; i < timeIntervals.length; i++) {
      try {
        List<String> timeParts = _validateAndParseTime(appStateValues[i]);
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        DateTime intervalTime = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          hour,
          minute,
        );
        if (currentTime.isBefore(intervalTime)) {
          tempNextAppState = timeIntervals[i];
          if (i < timeIntervals.length - 1) {
            tempNextNextAppState = timeIntervals[i + 1];
          } else {
            tempNextNextAppState = timeIntervals[0];
          }
          break;
        }
      } catch (e) {
        print('Error parsing time: ${appStateValues[i]} - $e');
        // Handle the error, maybe set a default value or skip the iteration
      }
    }

    // Handle case where currentTime is after all intervals
    if (tempNextAppState.isEmpty) {
      tempNextAppState = timeIntervals.first;
      tempNextNextAppState = timeIntervals[1];
    }

    setState(() {
      nextAppState = tempNextAppState;
      afterNextAppState = tempNextNextAppState;
    });

    // Calculate time until next interval
    try {
      List<String> nextTimeParts = _validateAndParseTime(
          appStateValues[timeIntervals.indexOf(tempNextAppState)]);
      int nextHour = int.parse(nextTimeParts[0]);
      int nextMinute = int.parse(nextTimeParts[1]);
      DateTime nextIntervalTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        nextHour,
        nextMinute,
      );

      if (nextIntervalTime.isBefore(currentTime)) {
        nextIntervalTime = nextIntervalTime.add(Duration(days: 1));
      }

      int timeUntilNextInterval =
          nextIntervalTime.difference(currentTime).inSeconds * 1000;

      List<String> nextNextTimeParts = _validateAndParseTime(
          appStateValues[timeIntervals.indexOf(tempNextNextAppState)]);
      int nextNextHour = int.parse(nextNextTimeParts[0]);
      int nextNextMinute = int.parse(nextNextTimeParts[1]);
      DateTime nextNextIntervalTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        nextNextHour,
        nextNextMinute,
      );

      if (nextNextIntervalTime.isBefore(currentTime)) {
        nextNextIntervalTime = nextNextIntervalTime.add(Duration(days: 1));
      }

      int timeUntilNextNextInterval =
          nextNextIntervalTime.difference(currentTime).inSeconds * 1000;
      setState(() {
        newInterval = timeUntilNextNextInterval - timeUntilNextInterval;
      });

      return timeUntilNextInterval;
    } catch (e) {
      print('Error calculating intervals: $e');
      return 0; // Return a default value or handle the error appropriately
    }
  }

  int _calculateTotalInterval(int currentIndex) {
    if (currentIndex == 7) {
      currentIndex = 0;
    }
    DateTime currentTime = DateTime.now();
    List<String> nextTimeParts =
        _validateAndParseTime(appStateValues[currentIndex]);
    int nextHour = int.parse(nextTimeParts[0]);
    int nextMinute = int.parse(nextTimeParts[1]);
    DateTime nextIntervalTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      nextHour,
      nextMinute,
    );

    // If the next interval time is before the current time, it means the interval is for the next day
    if (nextIntervalTime.isBefore(currentTime)) {
      nextIntervalTime = nextIntervalTime.add(Duration(days: 1));
    }

    // Calculate the duration of the current interval
    int currentIndexPrevious = (currentIndex - 1) % timeIntervals.length;
    List<String> currentPreviousTimeParts =
        _validateAndParseTime(appStateValues[currentIndexPrevious]);
    int currentPreviousHour = int.parse(currentPreviousTimeParts[0]);
    int currentPreviousMinute = int.parse(currentPreviousTimeParts[1]);
    DateTime currentPreviousIntervalTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      currentPreviousHour,
      currentPreviousMinute,
    );

    // If the current previous interval time is after the next interval time, it means the previous interval is for the previous day
    if (currentPreviousIntervalTime.isAfter(nextIntervalTime)) {
      currentPreviousIntervalTime =
          currentPreviousIntervalTime.subtract(Duration(days: 1));
    }

    int totalInterval =
        nextIntervalTime.difference(currentPreviousIntervalTime).inSeconds *
            1000;

    return totalInterval;
  }

  // double _timeToAngle(String time) {
  //   List<String> parts = time.split(':');
  //   int hour = int.parse(parts[0]) % 12; // Convert 24-hour format to 12-hour
  //   int minute = int.parse(parts[1]);
  //   double angle = (hour * 60 + minute) * 2 * pi / (12 * 60);
  //   return angle - (90 * pi / 180); // Subtract 90 degrees in radians
  // }

  String _getIconForCurrentTime(String currentAppState) {
    switch (currentAppState) {
      case 'Имсак':
        return 'assets/images/tanIcon.png';
      case 'Таң':
        return 'assets/images/tanIcon.png';
      case 'Күн':
        return 'assets/images/kunIcon.png';
      case 'Бесін':
        return 'assets/images/besinIcon.png';
      case 'Екінді':
        return 'assets/images/ekintiIcon.png';
      case 'Ақшам':
        return 'assets/images/aqshamIcon.png';
      case 'Құптан':
        return 'assets/images/quptanIcon.png';
      default:
        // Return a default image path if currentAppState is not recognized
        return 'assets/images/tanIcon.png';
    }
  }

  // IconData _getIconForInnerRing(String time) {
  //   // List of prayer times that should show FFIcons.k07
  //   const morningAndAfternoonTimes = ['Екінді', 'Бесін', 'Таң'];
  //   if (morningAndAfternoonTimes.contains(time)) {
  //     return FFIcons.k07;
  //   } else {
  //     return FFIcons.k08;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // int totalInterval =
    //     _calculateTotalInterval(timeIntervals.indexOf(currentAppState) + 1);

    //double percent = (timeUntilNextInterval.toDouble()) / totalInterval;
    //percent = percent.clamp(0.0, 1.0);
    // int _duration = (totalInterval / 1000).toInt();
    // int _leftDuration = (timeUntilNextInterval / 1000).toInt();
    // int _skippedDuration = _duration - _leftDuration;
    // int _forNextInterval = (newInterval / 1000).toInt();
    double biggerRaduis = 135;
    double innerRadius = biggerRaduis - 10;

    // Calculate start and end angles for the inner arc
    // double startAngle =
    //     _timeToAngle(appStateValues[timeIntervals.indexOf(currentAppState)]);
    //DateTime now = DateTime.now();
    //double currentAngle = _timeToAngle("${now.hour}:${now.minute}");
    //double sweepAngle = currentAngle - startAngle;

    // If the sweepAngle is negative, it means the current time is on the next day, so adjust it
    // if (sweepAngle < 0) {
    //   sweepAngle += 2 * pi;
    // }
    return ValueListenableBuilder<int>(
      valueListenable: _updateNotifier, // Listen to changes here
      builder: (context, value, child) {
        return Container(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: CustomPaint(
                  painter: RingPainter(
                      ringColor: FlutterFlowTheme.of(context).primary,
                      adjustedRadius: biggerRaduis,
                      strWidth: 5.0),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: CircularCountDownTimer(
                  key: _timerKey,
                  duration: _duration,
                  initialDuration: _skippedDuration,
                  controller: _controller,
                  width: 270,
                  height: 270,
                  ringColor: Colors.transparent,
                  ringGradient: null,
                  fillColor: FlutterFlowTheme.of(context).tertiary,
                  // fillGradient: LinearGradient(
                  //   colors: [
                  //     FlutterFlowTheme.of(context).accent3,
                  //     FlutterFlowTheme.of(context).accent4
                  //   ],
                  //   stops: const [0.0, 1.0],
                  //   begin: const AlignmentDirectional(0.0, -1.0),
                  //   end: const AlignmentDirectional(0.0, 1.0),
                  // ),
                  fillGradient: null,
                  backgroundColor: Colors.transparent,
                  backgroundGradient: null,
                  strokeWidth: 10.0,
                  strokeCap: StrokeCap.butt,
                  isReverse: true,
                  isReverseAnimation: false,
                  isTimerTextShown: false,
                  autoStart: true,
                  onStart: () {
                    debugPrint('Countdown Started');
                  },
                  onComplete: () {
                    setState(() {
                      currentAppState = _findCurrentAppState();
                      timeUntilNextInterval = _calculateTimeUntilNextInterval();
                      totalInterval = _calculateTotalInterval(
                          timeIntervals.indexOf(currentAppState) + 1);
                      // startAngle = _timeToAngle(
                      //     appStateValues[timeIntervals.indexOf(currentAppState)]);
                      //DateTime now = DateTime.now();
                      //currentAngle = _timeToAngle("${now.hour}:${now.minute}");
                      //sweepAngle = currentAngle - startAngle;

                      // if (sweepAngle < 0) {
                      //   sweepAngle += 2 * pi;
                      // }
                      _controller.reset();
                      _controller.restart(duration: _forNextInterval);
                    });
                  },
                  onChange: (String timeStamp) {
                    debugPrint('Countdown Changed $timeStamp');
                  },
                ),
              ),
              Align(
                alignment: Alignment.center,
                // child: Container(
                //   width: (innerRadius * 2),
                //   height: (innerRadius * 2),
                child: CustomPaint(
                  painter: RingPainter(
                      ringColor: FlutterFlowTheme.of(context).primary,
                      adjustedRadius: innerRadius,
                      strWidth: 1.0
                      //startAngle: startAngle,
                      //sweepAngle: sweepAngle
                      ),
                  // child: Stack(
                  //   children: List.generate(timesForInnerRadius.length, (index) {
                  //     double angle = _timeToAngle(timesForInnerRadius[index]);
                  //     bool isStartingNamaz =
                  //         index == timeIntervals.indexOf(currentAppState);
                  //     // Calculate the position based on the angle
                  //     double offset = isStartingNamaz ? 7.5 : 3.5;
                  //     double x = innerRadius + innerRadius * cos(angle) - offset;
                  //     double y = innerRadius + innerRadius * sin(angle) - offset;

                  //     bool isAboveCenter = y + 15 < (innerRadius + 15);

                  //     // return Positioned(
                  //     //   left: x + 10,
                  //     //   top: y + 10,
                  //     //   child: isStartingNamaz
                  //     //       ? FaIcon(
                  //     //           FontAwesomeIcons.dotCircle,
                  //     //           color: FlutterFlowTheme.of(context).primary,
                  //     //           size: 16,
                  //     //         )
                  //     //       : Icon(
                  //     //           Icons.brightness_1,
                  //     //           size: 7,
                  //     //           color: FlutterFlowTheme.of(context).primary,
                  //     //         ),
                  //     // );
                  //     return Stack(
                  //       children: [
                  //         Positioned(
                  //           left: x + 15,
                  //           top: y + 15,
                  //           child: GestureDetector(
                  //             onTap: () {
                  //               setState(() {
                  //                 if (selectedTime ==
                  //                     timesForInnerRadiusText[index]) {
                  //                   // If the same icon is tapped again, close the container
                  //                   selectedTime = null;
                  //                 } else {
                  //                   // Show the container with the new selected time
                  //                   selectedTime = timesForInnerRadiusText[index];
                  //                 }
                  //               });
                  //             },
                  //             child: isStartingNamaz
                  //                 ? FaIcon(
                  //                     FontAwesomeIcons.dotCircle,
                  //                     color: FlutterFlowTheme.of(context).primary,
                  //                     size: 15,
                  //                   )
                  //                 : Icon(
                  //                     Icons.brightness_1,
                  //                     size: 7,
                  //                     color: FlutterFlowTheme.of(context).primary,
                  //                   ),
                  //           ),
                  //         ),
                  //         if (selectedTime == timesForInnerRadiusText[index])
                  //           Positioned(
                  //             left:
                  //                 x, // Align the text with the icon horizontally
                  //             top: isAboveCenter
                  //                 ? (y + 25)
                  //                 : (y -
                  //                     5), // Adjust position based on icon's location
                  //             child: Container(
                  //               padding: const EdgeInsets.symmetric(
                  //                   horizontal: 4.0,
                  //                   vertical:
                  //                       2.0), // Add padding inside the container
                  //               decoration: BoxDecoration(
                  //                 color: FlutterFlowTheme.of(context).tertiary,
                  //                 borderRadius: BorderRadius.circular(5.0),
                  //               ), // Set the background color
                  //               child: Text(
                  //                 timesForInnerRadiusText[index],
                  //                 style: TextStyle(
                  //                   fontSize:
                  //                       13, // Adjust the text size as needed
                  //                   fontWeight: FontWeight.w500,
                  //                   color: FlutterFlowTheme.of(context).primary,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //       ],
                  //     );
                  //   }),
                  // ),
                ),
                //),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    Image.asset(
                      _getIconForCurrentTime(currentAppState),
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      currentAppState.toUpperCase(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                    Divider(
                      thickness: 0.5,
                      indent: 50,
                      endIndent: 50,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                    Text(
                      "$nextAppState уақытына дейін",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                    SizedBox(height: 5),
                    FlutterFlowTimer(
                      initialTime: timeUntilNextInterval,
                      getDisplayTime: (value) => StopWatchTimer.getDisplayTime(
                          value,
                          milliSecond: false),
                      controller: timerController,
                      updateStateInterval: Duration(milliseconds: 1000),
                      onChanged: (value, displayTime, shouldUpdate) {
                        if (shouldUpdate) {
                          setState(() {
                            current_time = value;
                          });
                        }
                      },
                      onEnded: () {
                        setState(() {
                          currentAppState = _findCurrentAppState();
                          timeUntilNextInterval =
                              _calculateTimeUntilNextInterval();
                          totalInterval = _calculateTotalInterval(
                              timeIntervals.indexOf(currentAppState) + 1);
                          // percent =
                          //     (totalInterval - timeUntilNextInterval.toDouble()) /
                          //         totalInterval;
                          // percent = percent.clamp(0.0, 1.0);
                          timerController.timer.setPresetTime(
                              mSec: timeUntilNextInterval, add: false);
                          timerController.onResetTimer();
                          timerController.onStartTimer();
                        });
                      },
                      textAlign: TextAlign.center,
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: 'Outfit',
                                letterSpacing: 0,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                    ),
                    SizedBox(height: 2),
                    Divider(
                      thickness: 0.5,
                      indent: 50,
                      endIndent: 50,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                    Text(
                      '$nextAppState ${appStateValues[timeIntervals.indexOf(nextAppState)]}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RingPainter extends CustomPainter {
  final Color ringColor;
  final double adjustedRadius;
  final double strWidth;
  //final double? startAngle;
  //final double? sweepAngle;

  RingPainter({
    required this.ringColor,
    required this.adjustedRadius,
    required this.strWidth,
    //this.startAngle,
    //this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = ringColor // Use the passed color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strWidth; // Adjust the width of the ring

    // Draw the circle (ring)
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      adjustedRadius,
      paint,
    );

    // if (startAngle != null && sweepAngle != null) {
    //   paint.color = ringColor;
    //   paint.strokeWidth = 3.0;

    //   canvas.drawArc(
    //     Rect.fromCircle(
    //       center: Offset(size.width / 2, size.height / 2),
    //       radius: adjustedRadius,
    //     ),
    //     startAngle!,
    //     sweepAngle!,
    //     false,
    //     paint,
    //   );
    // }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
