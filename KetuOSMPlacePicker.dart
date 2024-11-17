//geolocator: 10.0.1, http: ^0.13.0, flutter_map: ^4.0.0, latlong2: ^0.8.0
// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!
import 'index.dart'; // Imports other custom widgets
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as ll;

class OpenMap extends StatefulWidget {
  const OpenMap({
    super.key,
    this.width,
    this.height,
    required this.initialLocation,
    required this.initialCityRus,
    required this.initialCityEng,
    required this.currentLocation,
    required this.isSource,
  });

  final double? width;
  final double? height;
  final LatLng initialLocation;
  final String initialCityRus;
  final String initialCityEng;
  final LatLng currentLocation;
  final bool isSource;

  @override
  State<OpenMap> createState() => _OpenMapState();
}

class _OpenMapState extends State<OpenMap> {
  ll.LatLng convertLatLng(LatLng? latLng) {
    if (latLng == null) {
      return ll.LatLng(51.169392, 71.449074);
    } else {
      return ll.LatLng(latLng.latitude, latLng.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Выбрать точку на карте"),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
        body: OpenStreetMapSearchAndPick(
          initialLocation: convertLatLng(widget.initialLocation),
          currentLocation: convertLatLng(widget.currentLocation),
          locationPinIconColor: FlutterFlowTheme.of(context).primary,
          initialCityRus: widget.initialCityRus,
          isSource: widget.isSource,
          buttonTextStyle:
              const TextStyle(fontSize: 18, fontStyle: FontStyle.normal),
          buttonColor: FlutterFlowTheme.of(context).primary,
          buttonText: 'Выбрать точку',
          onPicked: (pickedData) async {
            final latLong = pickedData.latLong;
            String cityFromMapFull = pickedData.address['city'] ??
                pickedData.address['town'] ??
                pickedData.address['village'] ??
                pickedData.address['county'] ??
                '';
            String cityFromMap = cityFromMapFull.split(' ').first;
            print('city or village from map: $cityFromMap');
            if (!mounted) {
              print('mounted before query');
              return;
            }
            final regionsCollection =
                FirebaseFirestore.instance.collection('regions');
            final querySnapshot = await regionsCollection
                .where('city_rus', isEqualTo: cityFromMap)
                .limit(1)
                .get();
            if (!mounted) {
              print('mounted after query');
              return;
            }
            final documents = querySnapshot.docs;
            if (documents.isNotEmpty) {
              final document = documents.first.data();
              final String cityEng = document['city_eng'] as String;
              final GeoPoint geoPoint = document['latlng'] as GeoPoint;
              final LatLng cityLatLng =
                  LatLng(geoPoint.latitude, geoPoint.longitude);
              if (!mounted) {
                print('mounted');
                return;
              }
              if (widget.isSource) {
                setState(() {
                  FFAppState().source =
                      LatLng(latLong.latitude, latLong.longitude);
                  FFAppState().sourceAddress = pickedData.addressName;
                });
                if (cityFromMap != FFAppState().sourceCityRus) {
                  setState(() {
                    FFAppState().sourceCityRus = cityFromMap;
                    FFAppState().sourceCity = cityEng;
                    FFAppState().sourceCityLatLng = cityLatLng;
                  });
                }
              } else {
                setState(() {
                  FFAppState().dest =
                      LatLng(latLong.latitude, latLong.longitude);
                  FFAppState().destAddress = pickedData.addressName;
                });
                if (cityFromMap != FFAppState().destCityRus) {
                  setState(() {
                    FFAppState().destCityRus = cityFromMap;
                    FFAppState().destCity = cityEng;
                    FFAppState().destCityLatLng = cityLatLng;
                  });
                }
              }
            } else {
              print(
                  'No matching document found in the regions collection for the city: $cityFromMap');
            }
            print('sourceCity = ${FFAppState().sourceCity}');
            print('sourceCityRus = ${FFAppState().sourceCityRus}');
            print('sourceAddress = ${FFAppState().sourceAddress}');
            print('destCity = ${FFAppState().destCity}');
            print('destCityRus = ${FFAppState().destCityRus}');
            print('destAddress = ${FFAppState().destAddress}');
            context.pushNamed('home');
          },
        ));
  }
}

class OpenStreetMapSearchAndPick extends StatefulWidget {
  final void Function(PickedData pickedData) onPicked;
  final ll.LatLng initialLocation;
  final ll.LatLng currentLocation;
  final String initialCityRus;
  final bool isSource;
  final IconData zoomInIcon;
  final IconData zoomOutIcon;
  final IconData currentLocationIcon;
  final IconData locationPinIcon;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color locationPinIconColor;
  final String buttonText;
  final String hintText;
  final double buttonHeight;
  final double buttonWidth;
  final TextStyle buttonTextStyle;
  final String baseUri;

  const OpenStreetMapSearchAndPick({
    super.key,
    required this.onPicked,
    required this.initialLocation,
    required this.currentLocation,
    required this.initialCityRus,
    required this.isSource,
    this.zoomOutIcon = Icons.zoom_out_map,
    this.zoomInIcon = Icons.zoom_in_map,
    this.currentLocationIcon = Icons.my_location,
    this.buttonColor = const Color(0xffe43d35),
    required this.locationPinIconColor,
    this.hintText = 'Искать...',
    this.buttonTextStyle = const TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    this.buttonTextColor = Colors.white,
    this.buttonText = 'Выбрать точку',
    this.buttonHeight = 50,
    this.buttonWidth = 200,
    this.baseUri = 'https://nominatim.openstreetmap.org',
    this.locationPinIcon = Icons.location_on,
  });

  @override
  State<OpenStreetMapSearchAndPick> createState() =>
      _OpenStreetMapSearchAndPickState();
}

class _OpenStreetMapSearchAndPickState
    extends State<OpenStreetMapSearchAndPick> {
  MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<OSMdata> _options = <OSMdata>[];
  Timer? _debounce;
  var client = http.Client();
  late Future<Position?> latlongFuture;

  Future<Position?> getCurrentPosLatLong() async {
    LocationPermission locationPermission = await Geolocator.checkPermission();

    /// do not have location permission
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      return await getPosition(locationPermission);
    }

    /// have location permission
    Position position = await Geolocator.getCurrentPosition();
    // setNameCurrentPosAtInit(position.latitude, position.longitude);
    return position;
  }

  Future<Position?> getPosition(LocationPermission locationPermission) async {
    if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      return null;
    }
    Position position = await Geolocator.getCurrentPosition();
    // setNameCurrentPosAtInit(position.latitude, position.longitude);
    return position;
  }

  void setNameCurrentPos() async {
    double latitude = _mapController.center.latitude;
    double longitude = _mapController.center.longitude;
    if (kDebugMode) {
      print(latitude);
    }
    if (kDebugMode) {
      print(longitude);
    }
    String url =
        '${widget.baseUri}/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1&accept-language=ru';

    var response = await client.get(Uri.parse(url));
    var decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    Map<String, dynamic> address = decodedResponse['address'];
    String addressString = "Адрес точки";
    String houseNumber = address['house_number'] ?? '';
    String neighbourhood = address['neighbourhood'] ?? '';
    String road = address['road'] ?? '';
    String district = address['city_district'] ?? '';
    if (houseNumber.isNotEmpty && road.isNotEmpty) {
      addressString = '$road, $houseNumber';
    } else if (houseNumber.isNotEmpty && neighbourhood.isNotEmpty) {
      addressString = '$neighbourhood, $houseNumber';
    } else if (road.isNotEmpty) {
      addressString = road;
    } else if (neighbourhood.isNotEmpty) {
      addressString = neighbourhood;
    } else if (district.isNotEmpty) {
      addressString = district;
    } else {
      addressString = 'Адрес не найден';
    }

    _searchController.text = addressString;
    setState(() {});
  }

  // void setNameCurrentPosAtInit(double latitude, double longitude) async {
  //   if (kDebugMode) {
  //     print(latitude);
  //   }
  //   if (kDebugMode) {
  //     print(longitude);
  //   }

  //   String url =
  //       '${widget.baseUri}/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1';

  //   var response = await client.get(Uri.parse(url));
  //   // var response = await client.post(Uri.parse(url));
  //   var decodedResponse =
  //       jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;

  //   _searchController.text =
  //       decodedResponse['display_name'] ?? "MOVE TO CURRENT POSITION";
  // }

  @override
  void initState() {
    _mapController = MapController();

    _mapController.mapEventStream.listen(
      (event) async {
        if (event is MapEventMoveEnd) {
          var client = http.Client();
          String url =
              '${widget.baseUri}/reverse?format=json&lat=${event.center.latitude}&lon=${event.center.longitude}&zoom=18&addressdetails=1&accept-language=ru';

          var response = await client.get(Uri.parse(url));
          var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes))
              as Map<String, dynamic>;

          Map<String, dynamic> address = decodedResponse['address'];
          String addressString = "Адрес точки";
          String neighbourhood = address['neighbourhood'] ?? '';
          String houseNumber = address['house_number'] ?? '';
          String road = address['road'] ?? '';
          String district = address['city_district'] ?? '';
          if (houseNumber.isNotEmpty && road.isNotEmpty) {
            addressString = '$road, $houseNumber';
          } else if (houseNumber.isNotEmpty && neighbourhood.isNotEmpty) {
            addressString = '$neighbourhood, $houseNumber';
          } else if (road.isNotEmpty) {
            addressString = road;
          } else if (neighbourhood.isNotEmpty) {
            addressString = neighbourhood;
          } else if (district.isNotEmpty) {
            addressString = district;
          } else {
            addressString = 'Адрес не найден';
          }

          _searchController.text = addressString;
          setState(() {});
        }
      },
    );

    latlongFuture = getCurrentPosLatLong();

    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder inputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: widget.buttonColor),
    );
    OutlineInputBorder inputFocusBorder = OutlineInputBorder(
      borderSide: BorderSide(color: widget.buttonColor, width: 3.0),
    );
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: ll.LatLng(widget.initialLocation.latitude,
                    widget.initialLocation.longitude),
                zoom: 11.0,
                interactiveFlags: InteractiveFlag.all - InteractiveFlag.rotate,
                maxZoom: 18.0,
                minZoom: 3.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: Icon(
                        widget.locationPinIcon,
                        size: 50,
                        color: widget.locationPinIconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 180,
            right: 5,
            child: FloatingActionButton(
              heroTag: 'btn1',
              backgroundColor: widget.buttonColor,
              onPressed: () {
                _mapController.move(
                    _mapController.center, _mapController.zoom + 1);
              },
              child: Icon(
                widget.zoomInIcon,
                color: widget.buttonTextColor,
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: 5,
            child: FloatingActionButton(
              heroTag: 'btn2',
              backgroundColor: widget.buttonColor,
              onPressed: () {
                _mapController.move(
                    _mapController.center, _mapController.zoom - 1);
              },
              child: Icon(
                widget.zoomOutIcon,
                color: widget.buttonTextColor,
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: 5,
            child: FloatingActionButton(
              heroTag: 'btn3',
              backgroundColor: widget.buttonColor,
              onPressed: () async {
                _mapController.move(
                    ll.LatLng(widget.currentLocation.latitude,
                        widget.currentLocation.longitude),
                    _mapController.zoom);
                setNameCurrentPos();
              },
              child: Icon(
                widget.currentLocationIcon,
                color: widget.buttonTextColor,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  TextFormField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        border: inputBorder,
                        focusedBorder: inputFocusBorder,
                      ),
                      style: const TextStyle(
                          color: Color.fromARGB(255, 236, 8, 8)),
                      onChanged: (String value) {
                        if (_debounce?.isActive ?? false) {
                          _debounce?.cancel();
                        }

                        _debounce =
                            Timer(const Duration(milliseconds: 1000), () async {
                          if (kDebugMode) {
                            print(value);
                          }
                          var client = http.Client();
                          try {
                            String cityName = widget.initialCityRus;
                            String url =
                                '${widget.baseUri}/search?q=$cityName, $value&format=json&polygon_geojson=1&addressdetails=1&accept-language=ru&countrycodes=KZ';
                            if (kDebugMode) {
                              print(url);
                            }
                            var response = await client.get(Uri.parse(url));
                            var decodedResponse =
                                jsonDecode(utf8.decode(response.bodyBytes))
                                    as List<dynamic>;

                            if (kDebugMode) {
                              print(decodedResponse);
                            }
                            _options = decodedResponse
                                .where((e) {
                                  var address = e['address'];
                                  return address != null &&
                                      (address['road'] != null ||
                                          address['house_number'] != null);
                                })
                                .map((e) {
                                  Map<String, dynamic> address = e['address'];
                                  String addressString = "Адрес точки";
                                  String houseNumber =
                                      address['house_number'] ?? '';
                                  String road = address['road'] ?? '';
                                  String neighbourhood =
                                      address['neighbourhood'] ?? '';
                                  String district =
                                      address['city_district'] ?? '';
                                  if (houseNumber.isNotEmpty &&
                                      road.isNotEmpty) {
                                    addressString = '$road, $houseNumber';
                                  } else if (houseNumber.isNotEmpty &&
                                      neighbourhood.isNotEmpty) {
                                    addressString =
                                        '$neighbourhood, $houseNumber';
                                  } else if (road.isNotEmpty) {
                                    addressString = road;
                                  } else if (neighbourhood.isNotEmpty) {
                                    addressString = neighbourhood;
                                  } else if (district.isNotEmpty) {
                                    addressString = district;
                                  } else {
                                    addressString = 'Адрес не найден';
                                  }
                                  return OSMdata(
                                    displayname: addressString,
                                    lat: double.parse(e['lat']),
                                    lon: double.parse(e['lon']),
                                  );
                                })
                                .toList()
                                .cast<OSMdata>();

                            setState(() {});
                          } finally {
                            client.close();
                          }

                          setState(() {});
                        });
                      }),
                  StatefulBuilder(
                    builder: ((context, setState) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _options.length > 5 ? 5 : _options.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_options[index].displayname),
                            // subtitle: Text(
                            //     '${_options[index].lat},${_options[index].lon}'),
                            onTap: () {
                              _mapController.move(
                                  ll.LatLng(
                                      _options[index].lat, _options[index].lon),
                                  15.0);
                              _searchController.text =
                                  _options[index].displayname;
                              _focusNode.unfocus();
                              _options.clear();
                              setState(() {});
                            },
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: WideButton(
                  widget.buttonText,
                  textStyle: widget.buttonTextStyle,
                  height: widget.buttonHeight,
                  width: widget.buttonWidth,
                  onPressed: () async {
                    final value = await pickData();
                    widget.onPicked(value);
                  },
                  backgroundColor: widget.buttonColor,
                  foregroundColor: widget.buttonTextColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<PickedData> pickData() async {
    LatLong center = LatLong(
        _mapController.center.latitude, _mapController.center.longitude);
    var client = http.Client();
    String url =
        '${widget.baseUri}/reverse?format=json&lat=${_mapController.center.latitude}&lon=${_mapController.center.longitude}&zoom=18&addressdetails=1&accept-language=ru';

    var response = await client.get(Uri.parse(url));
    var decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    Map<String, dynamic> address = decodedResponse['address'];
    String addressString = "Адрес точки";
    String houseNumber = address['house_number'] ?? '';
    String neighbourhood = address['neighbourhood'] ?? '';
    String road = address['road'] ?? '';
    String district = address['city_district'] ?? '';
    if (houseNumber.isNotEmpty && road.isNotEmpty) {
      addressString = '$road, $houseNumber';
    } else if (houseNumber.isNotEmpty && neighbourhood.isNotEmpty) {
      addressString = '$neighbourhood, $houseNumber';
    } else if (road.isNotEmpty) {
      addressString = road;
    } else if (neighbourhood.isNotEmpty) {
      addressString = neighbourhood;
    } else if (district.isNotEmpty) {
      addressString = district;
    } else {
      addressString = 'Адрес не найден';
    }

    String displayName = addressString;
    return PickedData(center, displayName, address);
  }
}

class WideButton extends StatelessWidget {
  const WideButton(
    this.text, {
    super.key,
    required,
    this.padding = 0.0,
    this.height = 45,
    required this.onPressed,
    this.backgroundColor = const Color(0xffe43d35),
    this.foregroundColor = Colors.white,
    this.width = double.infinity,
    this.textStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  });

  final String text;
  final double padding;
  final double height;
  final double width;
  final Color backgroundColor;
  final TextStyle textStyle;
  final Color foregroundColor;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: MediaQuery.of(context).size.width <= 500
          ? MediaQuery.of(context).size.width
          : width,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ),
          onPressed: onPressed,
          child: Text(text, style: textStyle),
        ),
      ),
    );
  }
}

class OSMdata {
  final String displayname;
  final double lat;
  final double lon;
  OSMdata({required this.displayname, required this.lat, required this.lon});
  @override
  String toString() {
    return '$displayname, $lat, $lon';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is OSMdata && other.displayname == displayname;
  }

  @override
  int get hashCode => Object.hash(displayname, lat, lon);
}

class LatLong {
  final double latitude;
  final double longitude;
  const LatLong(this.latitude, this.longitude);
}

class PickedData {
  final LatLong latLong;
  final String addressName;
  final Map<String, dynamic> address;

  PickedData(this.latLong, this.addressName, this.address);
}
