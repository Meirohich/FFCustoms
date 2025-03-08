// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mihr_app/flutter_flow/flutter_flow_timer.dart';
import 'dart:math';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class MihrAppCountDownTimer extends StatefulWidget {
  const MihrAppCountDownTimer({
    super.key,
    required this.width,
    required this.height,
    required this.tan,
    required this.kun,
    required this.besin,
    required this.ekindi,
    required this.aqsham,
    required this.quptan,
    //required this.imsak,
  });

  final double width;
  final double height;
  final String tan;
  final String kun;
  final String besin;
  final String ekindi;
  final String aqsham;
  final String quptan;
  //final String imsak;

  @override
  State<MihrAppCountDownTimer> createState() => _MihrAppCountDownTimerState();
}

class _MihrAppCountDownTimerState extends State<MihrAppCountDownTimer> {
  final CountDownController _controller = CountDownController();
  FlutterFlowTimerController timerController = FlutterFlowTimerController(
    StopWatchTimer(
      mode: StopWatchMode.countDown,
    ),
  );

  final ValueNotifier<int> _updateNotifier = ValueNotifier<int>(0);

  Key _timerKey = UniqueKey();

  late List<String> timeIntervals;
  late List<String> appStateValues;
  late List<String> timesForInnerRadius;
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

  @override
  void initState() {
    super.initState();
    _initializeCountdown();
    _controller.start();
    timerController.onStartTimer();
  }

  @override
  void didUpdateWidget(MihrAppCountDownTimer oldWidget) {
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
      //'Имсак',
      'Таң',
      'Күн',
      'Бесін',
      'Екінді',
      'Ақшам',
      'Құптан'
    ];
    appStateValues = [
      //widget.imsak,
      widget.tan,
      widget.kun,
      widget.besin,
      widget.ekindi,
      widget.aqsham,
      widget.quptan,
    ];

    timesForInnerRadius = [
      //widget.imsak,
      widget.tan,
      widget.kun,
      widget.besin,
      widget.ekindi,
      widget.aqsham,
      widget.quptan,
    ];

    currentAppState = _findCurrentAppState();

    timeUntilNextInterval = _calculateTimeUntilNextInterval();

    totalInterval =
        _calculateTotalInterval(timeIntervals.indexOf(currentAppState) + 1);

    _duration = totalInterval ~/ 1000;
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
    int currentIndex = 5; // Default to the last interval index

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
    if (currentIndex == 6) {
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

  double _timeToAngle(String time) {
    List<String> parts = time.split(':');
    int hour = int.parse(parts[0]) % 12; // Convert 24-hour format to 12-hour
    int minute = int.parse(parts[1]);
    double totalMinutes = (hour * 60 + minute).toDouble();

    double angle = (2 * pi * (totalMinutes / (12 * 60))) - pi / 2;

    return angle;
  }

  IconData _getIconForCurrentTime(String currentAppState) {
    switch (currentAppState) {
      case 'Таң':
        return FFIcons.ktan;
      case 'Күн':
        return FFIcons.kkunNew;
      case 'Бесін':
        return FFIcons.kbesin;
      case 'Екінді':
        return FFIcons.kcenterekinti;
      case 'Ақшам':
        return FFIcons.kcentreaqsham;
      case 'Құптан':
        return FFIcons.kcenterquptan;
      default:
        return FFIcons.ktan;
    }
  }

  String _getRingIconForPrayerTime(String prayerTime) {
    switch (prayerTime) {
      case 'Имсак':
        return 'assets/images/RingTan.png';
      case 'Таң':
        return 'assets/images/RingTan.png';
      case 'Күн':
        return 'assets/images/RingKun.png';
      case 'Бесін':
        return 'assets/images/RingBesin.png';
      case 'Екінді':
        return 'assets/images/RingEkinti.png';
      case 'Ақшам':
        return 'assets/images/RingAqsham.png';
      case 'Құптан':
        return 'assets/images/RingQuptan.png';
      default:
        return 'assets/images/RingTan.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    double biggerRaduis = 135;
    double innerRadius = biggerRaduis - 40;

    //Calculate start and end angles for the inner arc
    double startAngle =
        _timeToAngle(appStateValues[timeIntervals.indexOf(currentAppState)]);
    DateTime now = DateTime.now();
    double currentAngle = _timeToAngle("${now.hour}:${now.minute}");
    double sweepAngle = currentAngle - startAngle;

    //If the sweepAngle is negative, it means the current time is on the next day, so adjust it
    if (sweepAngle < 0) {
      sweepAngle += 2 * pi;
    }
    return ValueListenableBuilder<int>(
      valueListenable: _updateNotifier, // Listen to changes here
      builder: (context, value, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          child: Stack(
            children: [
              // Inner ring
              Align(
                alignment: Alignment.center,
                child: CustomPaint(
                  painter: UniformTickRingPainter(
                      radius: innerRadius + 3.5, tickNum: 65, tickWidth: 0.7),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: CircularCountDownTimer(
                  key: _timerKey,
                  duration: _duration,
                  initialDuration: _skippedDuration,
                  controller: _controller,
                  width: innerRadius * 2,
                  height: innerRadius * 2,
                  ringColor: Colors.transparent,
                  ringGradient: null,
                  fillColor: FlutterFlowTheme.of(context).primary,
                  fillGradient: null,
                  backgroundColor: Colors.transparent,
                  backgroundGradient: null,
                  strokeWidth: 10.0,
                  strokeCap: StrokeCap.round,
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
                      startAngle = _timeToAngle(appStateValues[
                          timeIntervals.indexOf(currentAppState)]);
                      DateTime now = DateTime.now();
                      currentAngle = _timeToAngle("${now.hour}:${now.minute}");
                      sweepAngle = currentAngle - startAngle;

                      if (sweepAngle < 0) {
                        sweepAngle += 2 * pi;
                      }
                      _controller.reset();
                      _controller.restart(duration: _forNextInterval);
                    });
                  },
                  onChange: (String timeStamp) {
                    debugPrint('Countdown Changed $timeStamp');
                  },
                ),
              ),
              // Bold Middle ring
              Align(
                alignment: Alignment.center,
                child: CustomPaint(
                  painter: UniformTickRingPainter(
                      radius: biggerRaduis - 16,
                      tickNum: 25,
                      tickWidth: 2,
                      tickLength: 5),
                ),
              ),
              // Outer ring with icons
              Align(
                alignment: Alignment.center,
                child: CustomPaint(
                  painter: UniformTickRingPainter(
                    radius: biggerRaduis + 9,
                    tickNum: 80,
                    tickWidth: 0.7,
                    startAngle: startAngle,
                    sweepAngle: sweepAngle,
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: List.generate(timesForInnerRadius.length, (index) {
                  // Calculate angle
                  double angle = _timeToAngle(timesForInnerRadius[index]);
                  // Determine if this is the starting Namaz
                  bool isStartingNamaz =
                      index == timeIntervals.indexOf(currentAppState);
                  double offset = 7;

                  // Calculate position along the circle
                  double iconRadius =
                      biggerRaduis + 7; // Adjust for perfect alignment
                  double iconSize = 24;
                  double x = widget.width / 2 +
                      iconRadius * cos(angle) -
                      (iconSize / 2);
                  double y = widget.height / 2 +
                      iconRadius * sin(angle) -
                      (iconSize / 2);
                  // double x = widget.width / 2 +
                  //     (biggerRaduis + offset) * cos(angle) -
                  //     offset; // Offset for icon size
                  // double y = widget.height / 2 +
                  //     (biggerRaduis + offset) * sin(angle) -
                  //     offset; // Offset for icon size

                  return Positioned(
                    left: x,
                    top: y,
                    child: Image.asset(
                      _getRingIconForPrayerTime(timeIntervals[index]),
                      width: iconSize,
                      height: iconSize,
                    ),
                  );
                }),
              ),
              // Inside Text and Timer
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconForCurrentTime(currentAppState),
                      color: Colors.white,
                      size: 24.0,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      currentAppState,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                    SizedBox(height: 6),
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
                                letterSpacing: 1,
                                fontSize: 32,
                                fontWeight: FontWeight.normal,
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$nextAppState ${appStateValues[timeIntervals.indexOf(nextAppState)]}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                    SizedBox(height: 20),
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

class UniformTickRingPainter extends CustomPainter {
  final double radius;
  final double tickLength;
  final double tickWidth;
  final double tickNum;
  final double? startAngle;
  final double? sweepAngle;

  UniformTickRingPainter({
    required this.radius,
    this.tickLength = 7.0,
    this.tickWidth = 1.0,
    required this.tickNum,
    this.startAngle,
    this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final tickPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = tickWidth;

    // Draw the ticks
    for (int i = 0; i < tickNum; i++) {
      // Calculate the angle for each tick
      final angle = i * 2 * pi / tickNum;

      // Calculate start and end points for each tick
      final startX = center.dx + (radius - tickLength) * cos(angle);
      final startY = center.dy + (radius - tickLength) * sin(angle);
      final endX = center.dx + radius * cos(angle);
      final endY = center.dy + radius * sin(angle);

      // Draw the tick
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }

    if (startAngle != null && sweepAngle != null) {
      final arcPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = tickLength;

      double newRadius = radius - tickLength / 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: newRadius),
        startAngle!,
        sweepAngle!,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
