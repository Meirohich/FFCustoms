
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '/flutter_flow/flutter_flow_timer.dart';

class TaqvimCountDownTimer extends StatefulWidget {
  const TaqvimCountDownTimer({
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
  });

  final double width;
  final double height;
  final String tan;
  final String kun;
  final String besin;
  final String ekindi;
  final String aqsham;
  final String quptan;
  final String imsak;

  @override
  State<TaqvimCountDownTimer> createState() => _TaqvimCountDownTimerState();
}

class _TaqvimCountDownTimerState extends State<TaqvimCountDownTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
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
  double _progressValue = 0.0;
  double _initialProgressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeCountdown();
    _calculateInitialProgressValue();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: timeUntilNextInterval),
      value: _initialProgressValue,
    );

    _animationController.addListener(() {
      setState(() {
        _progressValue = _animationController.value;
      });
    });

    _animationController.forward();
    timerController.onStartTimer();
  }

  @override
  void didUpdateWidget(TaqvimCountDownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tan != oldWidget.tan || widget.quptan != oldWidget.quptan) {
      setState(() {
        _initializeCountdown();
        _calculateInitialProgressValue(); // Recalculate initial progress
        _animationController.reset();
        _animationController.value = _initialProgressValue;
        _animationController.duration =
            Duration(milliseconds: timeUntilNextInterval);
        _animationController.forward();

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
    _animationController.dispose();
    timerController.dispose();
    super.dispose();
  }

  void _calculateInitialProgressValue() {
    // Find the previous interval time
    int currentIntervalIndex = timeIntervals.indexOf(currentAppState);
    int previousIntervalIndex =
        (currentIntervalIndex - 1 + timeIntervals.length) %
            timeIntervals.length;

    String currentIntervalTime = appStateValues[currentIntervalIndex];
    String nextIntervalTime =
        appStateValues[(currentIntervalIndex + 1) % timeIntervals.length];

    // Get the percentage that has ELAPSED (not left) for progress
    _initialProgressValue = 1.0 -
        (percentageLeftForProgress(currentIntervalTime, nextIntervalTime) ??
            1.0);
    // print("_initialProgressValue: $_initialProgressValue");
  }

  double? percentageLeftForProgress(
    String? timeBefore,
    String? timeAfter,
  ) {
    if (timeBefore == null || timeAfter == null) return 1.0;

    try {
      // Convert time strings to DateTime objects (assuming same day)
      List<String> beforeParts = _validateAndParseTime(timeBefore);
      List<String> afterParts = _validateAndParseTime(timeAfter);
      // print("beforeParts: $beforeParts");
      // print("afterParts: $afterParts");

      int beforeHour = int.parse(beforeParts[0]);
      int beforeMinute = int.parse(beforeParts[1]);

      int afterHour = int.parse(afterParts[0]);
      int afterMinute = int.parse(afterParts[1]);

      DateTime now = DateTime.now();
      DateTime before;
      if (now.hour < beforeHour ||
          (now.hour == beforeHour && now.minute < beforeMinute)) {
        // If before time is in the future, assume it's on the previous day
        before = DateTime(
            now.year, now.month, now.day - 1, beforeHour, beforeMinute);
      } else {
        before =
            DateTime(now.year, now.month, now.day, beforeHour, beforeMinute);
      }

      DateTime after =
          DateTime(now.year, now.month, now.day, afterHour, afterMinute);

      if (after.isBefore(before)) {
        // If after time is before before time, assume it's on the next day
        after = after.add(Duration(days: 1));
      }

      Duration totalDuration = after.difference(before);
      Duration elapsedDuration = now.difference(before);

      if (elapsedDuration.isNegative) {
        //print("elapsedDuration.isNegative: $elapsedDuration");
        return 1.0; // If before time is in the future
      }

      if (elapsedDuration >= totalDuration) {
        //print("elapsedDuration >= totalDuration: $elapsedDuration");
        return 0.0; // If after time has passed
      }

      double percentageLeft =
          1 - (elapsedDuration.inSeconds / totalDuration.inSeconds);
      //print("percentageLeft: $percentageLeft");
      return percentageLeft.clamp(0.0, 1.0);
    } catch (e) {
      //print('Error calculating percentage: $e');
      return 1.0; // Default to 100% if there's an error
    }
  }

  void _initializeCountdown() {
    timeIntervals = [
      'Имсок',
      'Бомдод',
      'Қуёш',
      'Пешин',
      'Асри Соний',
      'Шом',
      'Хуфтони Аввал'
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
    String currentAppState = 'Хуфтони Аввал'; // Default to the last interval
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

  String _getIconForCurrentTime(String currentAppState) {
    switch (currentAppState) {
      case 'Имсок':
        return 'assets/images/tanIcon.png';
      case 'Бомдод':
        return 'assets/images/tanIcon.png';
      case 'Қуёш':
        return 'assets/images/kunIcon.png';
      case 'Пешин':
        return 'assets/images/besinIcon.png';
      case 'Асри Соний':
        return 'assets/images/ekintiIcon.png';
      case 'Шом':
        return 'assets/images/aqshamIcon.png';
      case 'Хуфтони Аввал':
        return 'assets/images/quptanIcon.png';
      default:
        // Return a default image path if currentAppState is not recognized
        return 'assets/images/tanIcon.png';
    }
  }

  void _resetTimer() {
    setState(() {
      currentAppState = _findCurrentAppState();
      timeUntilNextInterval = _calculateTimeUntilNextInterval();
      totalInterval =
          _calculateTotalInterval(timeIntervals.indexOf(currentAppState) + 1);

      _calculateInitialProgressValue(); // Recalculate initial progress when resetting

      _animationController.reset();
      _animationController.value = _initialProgressValue;
      _animationController.duration =
          Duration(milliseconds: timeUntilNextInterval);
      _animationController.forward();

      timerController.timer
          .setPresetTime(mSec: timeUntilNextInterval, add: false);
      timerController.onResetTimer();
      timerController.onStartTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _updateNotifier, // Listen to changes here
      builder: (context, value, child) {
        return Container(
          width: widget.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current prayer time display
              Image.asset(
                _getIconForCurrentTime(currentAppState),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 5),
              Text(
                currentAppState.toUpperCase(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              const SizedBox(height: 10),

              // Progress bar
              Container(
                height: 15,
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            double width =
                                constraints.maxWidth * _progressValue;
                            // print('width: $width');
                            // print("progressValue: $_progressValue");

                            return Container(
                              width: width,
                              height: 15,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).tertiary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Countdown text
              Text(
                "$nextAppState намозига",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              const SizedBox(height: 5),

              // Countdown timer
              FlutterFlowTimer(
                key: _timerKey,
                initialTime: timeUntilNextInterval,
                getDisplayTime: (value) =>
                    StopWatchTimer.getDisplayTime(value, milliSecond: false),
                controller: timerController,
                updateStateInterval: Duration(milliseconds: 1000),
                onChanged: (value, displayTime, shouldUpdate) {
                  if (shouldUpdate) {
                    setState(() {
                      current_time = value;
                    });
                  }
                },
                onEnded: _resetTimer,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      fontFamily: 'Outfit',
                      letterSpacing: 0.5,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
              ),
              const SizedBox(height: 5),

              // Next prayer time
              Text(
                '$nextAppState ${appStateValues[timeIntervals.indexOf(nextAppState)]}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
