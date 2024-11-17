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

import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';

class Qubyla extends StatefulWidget {
  const Qubyla({
    super.key,
    this.width,
    this.height,
    required this.isLightMode,
  });

  final double? width;
  final double? height;
  final bool isLightMode;

  @override
  State<Qubyla> createState() => _QubylaState();
}

class _QubylaState extends State<Qubyla> {
  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).secondary,
        body: FutureBuilder(
          future: _deviceSupport,
          builder: (_, AsyncSnapshot<bool?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error.toString()}"),
              );
            }

            if (snapshot.data!) {
              return QiblahCompass(isLightMode: widget.isLightMode);
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator.adaptive(),
      );
}

class QiblahCompass extends StatefulWidget {
  const QiblahCompass({
    super.key,
    required this.isLightMode,
  });
  final bool isLightMode;

  @override
  _QiblahCompassState createState() => _QiblahCompassState();
}

class _QiblahCompassState extends State<QiblahCompass> {
  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();

  Stream<LocationStatus> get stream => _locationStreamController.stream;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  @override
  void dispose() {
    _locationStreamController.close();
    FlutterQiblah().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: Image.asset(
            widget.isLightMode == false
                ? 'assets/images/darkBackPhoto.jpg'
                : 'assets/images/lightBackPhoto.jpg',
          ).image,
        ),
      ),
      alignment: Alignment.center,
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 25.0, top: 0.0),
      child: StreamBuilder(
        stream: stream,
        builder: (context, AsyncSnapshot<LocationStatus> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (snapshot.data!.enabled == true) {
            switch (snapshot.data!.status) {
              case LocationPermission.always:
              case LocationPermission.whileInUse:
                return QiblahCompassWidget(isLightMode: widget.isLightMode);

              case LocationPermission.denied:
                return LocationErrorWidget(
                  error: "Location service permission denied",
                  callback: _checkLocationStatus,
                );
              case LocationPermission.deniedForever:
                return LocationErrorWidget(
                  error: "Location service Denied Forever !",
                  callback: _checkLocationStatus,
                );
              // case GeolocationStatus.unknown:
              //   return LocationErrorWidget(
              //     error: "Unknown Location service error",
              //     callback: _checkLocationStatus,
              //   );
              default:
                return const SizedBox();
            }
          } else {
            return LocationErrorWidget(
              error: "Please enable Location service",
              callback: _checkLocationStatus,
            );
          }
        },
      ),
    );
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled &&
        locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final s = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(s);
    } else {
      _locationStreamController.sink.add(locationStatus);
    }
  }
}

class LocationErrorWidget extends StatelessWidget {
  final String? error;
  final Function? callback;

  const LocationErrorWidget({super.key, this.error, this.callback});

  @override
  Widget build(BuildContext context) {
    const box = SizedBox(height: 32);
    const errorColor = Color(0xffb00020);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.location_off,
            size: 150,
            color: errorColor,
          ),
          box,
          Text(
            error!,
            style:
                const TextStyle(color: errorColor, fontWeight: FontWeight.bold),
          ),
          box,
          ElevatedButton(
            child: const Text("Retry"),
            onPressed: () {
              if (callback != null) callback!();
            },
          )
        ],
      ),
    );
  }
}

class QiblahCompassWidget extends StatelessWidget {
  QiblahCompassWidget({
    super.key,
    required this.isLightMode,
  });
  final bool isLightMode;

  @override
  Widget build(BuildContext context) {
    // Choose appropriate image based on the theme
    final compassImage =
        isLightMode ? 'assets/images/darkC1.png' : 'assets/images/lightC1.png';
    final dialImage =
        isLightMode ? 'assets/images/darkD1.png' : 'assets/images/lightD1.png';
    // final needleImage =
    //     isLightMode ? 'assets/images/darkN.png' : 'assets/images/lightN.png';
    final needleImage = 'assets/images/qublaN.png';
    // final dialImage = 'assets/images/qublaD.png';
    // final compassImage = 'assets/images/qublaC.png';
    final Color colorText = isLightMode ? Colors.black : Colors.white;
    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        final qiblahDirection = snapshot.data!;

        return LayoutBuilder(
          builder: (context, constraints) {
            double size = constraints.maxWidth * 1.0;

            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Transform.rotate(
                  angle: (qiblahDirection.qiblah * (pi / 180) * -1),
                  child: Image.asset(
                    compassImage,
                    fit: BoxFit.contain,
                    height: size,
                    alignment: Alignment.center,
                  ),
                ),
                Transform.rotate(
                  angle: (qiblahDirection.direction * (pi / 180) * -1),
                  child: Image.asset(
                    dialImage,
                    fit: BoxFit.contain,
                    height: size,
                    alignment: Alignment.center,
                  ),
                ),
                Transform.rotate(
                  angle: (qiblahDirection.qiblah * (pi / 180) * -1),
                  child: Image.asset(
                    needleImage,
                    fit: BoxFit.contain,
                    height: size,
                    alignment: Alignment.center,
                  ),
                ),
                // Display the offset at the bottom
                Positioned(
                  bottom: 5, // Adjusted to fit nicely at the bottom
                  child: Text(
                    "${qiblahDirection.offset.toStringAsFixed(3)}°",
                    style: TextStyle(
                      color: colorText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
