//latlong2: ^0.8.0
//flutter_map: ^4.0.0
// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_map/flutter_map.dart' as fmap;
import 'package:latlong2/latlong.dart' as ll;

class OpenStreetMap extends StatefulWidget {
  const OpenStreetMap({
    super.key,
    this.width,
    this.height,
    this.bikeList,
    required this.userLocation,
    this.initCenter,
  });

  final double? width;
  final double? height;
  final List<MotorbikeRecord>? bikeList;
  final LatLng userLocation;
  final LatLng? initCenter;

  @override
  State<OpenStreetMap> createState() => _OpenStreetMapState();
}

class _OpenStreetMapState extends State<OpenStreetMap>
    with TickerProviderStateMixin {
  late final fmap.MapController _mapController;
  late AnimationController _animationController;
  MotorbikeRecord? selectedBike;
  List<bool> isMarkerHovered = [];
  Duration mapAnimationDuration = const Duration(milliseconds: 1000);
  late List<MotorbikeRecord> filteredBikes;

  @override
  void initState() {
    _mapController = fmap.MapController();
    _animationController =
        AnimationController(duration: mapAnimationDuration, vsync: this);

    super.initState();

    _filterBikeList();
    isMarkerHovered = List.filled(filteredBikes.length, false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialMapCenter();
    });
  }

  void _setInitialMapCenter() {
    if (widget.initCenter != null) {
      _mapController.move(
        ll.LatLng(widget.initCenter!.latitude, widget.initCenter!.longitude),
        12,
      );
    } else {
      _mapController.move(
        ll.LatLng(43.585525, 39.723062),
        12,
      );
    }
  }

  @override
  void didUpdateWidget(covariant OpenStreetMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initCenter != oldWidget.initCenter) {
      if (widget.initCenter != null) {
        _mapController.move(
          ll.LatLng(widget.initCenter!.latitude, widget.initCenter!.longitude),
          _mapController.zoom,
        );
      } else {
        _mapController.move(
          ll.LatLng(43.585525, 39.723062),
          _mapController.zoom,
        );
      }
    }

    if (widget.bikeList != oldWidget.bikeList) {
      _filterBikeList();
      isMarkerHovered = List.filled(filteredBikes.length, false);
    }
  }

  void _filterBikeList() async {
    if (widget.bikeList != null) {
      filteredBikes = widget.bikeList!;
    } else {
      filteredBikes = [];
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<fmap.Marker> _getMarkersFromBikeList() {
    return filteredBikes
        .where((bike) => bike.placeCoordination != null)
        .map((bike) {
      final point = ll.LatLng(
          bike.placeCoordination!.latitude, bike.placeCoordination!.longitude);
      bool isCardVisible = selectedBike == bike;

      return fmap.Marker(
        width: isCardVisible ? 180 : 40,
        height: isCardVisible ? 300 : 20,
        point: point,
        builder: (ctx) => InkWell(
          onTap: () => _onMarkerTapped(bike),
          onHover: (isHovered) {
            setState(() {
              isMarkerHovered[filteredBikes.indexOf(bike)] = isHovered;
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isCardVisible)
                GestureDetector(
                  onTap: () async {
                    await context.pushNamed(
                      'pageMotorbikeRenter',
                      queryParameters: {
                        'motoRef': serializeParam(
                          bike.reference,
                          ParamType.DocumentReference,
                        ),
                      }.withoutNulls,
                    );
                  },
                  child: BikeDetailCard(
                    bike: bike,
                    onClose: () {
                      setState(() {
                        selectedBike = null;
                      });
                    },
                  ),
                ),
              Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isMarkerHovered[filteredBikes.indexOf(bike)]
                        ? Colors.green
                        : Colors.black,
                    width: isMarkerHovered[filteredBikes.indexOf(bike)] ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: FittedBox(
                  child: Text(
                    '${bike.price.toString()} ₽',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _onMarkerTapped(MotorbikeRecord bike) {
    setState(() {
      if (selectedBike == bike) {
        selectedBike = null;
      } else {
        selectedBike = bike;
        _animatedMapMove(
            ll.LatLng(bike.placeCoordination!.latitude,
                bike.placeCoordination!.longitude),
            12);
      }
    });
  }

  void _animatedMapMove(ll.LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
        begin: _mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.zoom, end: destZoom);
    if (mounted) {
      _animationController =
          AnimationController(vsync: this, duration: mapAnimationDuration);
    }
    final Animation<double> animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear);

    _animationController.addListener(() {
      _mapController.move(
          ll.LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    if (mounted) {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          fmap.FlutterMap(
            mapController: _mapController,
            options: fmap.MapOptions(
              center: widget.initCenter != null
                  ? ll.LatLng(
                      widget.initCenter!.latitude, widget.initCenter!.longitude)
                  : ll.LatLng(43.585525, 39.723062),
              zoom: 12,
              minZoom: 3,
              maxZoom: 17,
              interactiveFlags:
                  fmap.InteractiveFlag.all & ~fmap.InteractiveFlag.rotate,
            ),
            children: [
              fmap.TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              fmap.MarkerLayer(
                markers: _getMarkersFromBikeList(),
              ),
            ],
          ),
          _buildControllerButtons(),
        ],
      ),
    );
  }

  Widget _buildControllerButtons() {
    return PositionedDirectional(
      bottom: 25,
      end: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            shape: const CircleBorder(),
            backgroundColor: FlutterFlowTheme.of(context).info,
            onPressed: () {
              final newZoom = _mapController.zoom + 1;
              _animatedMapMove(_mapController.center, newZoom);
            },
            child: Icon(
              Icons.zoom_in,
              color: FlutterFlowTheme.of(context).primary,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "btn2",
            shape: const CircleBorder(),
            backgroundColor: FlutterFlowTheme.of(context).info,
            onPressed: () {
              final newZoom = _mapController.zoom - 1;
              _animatedMapMove(_mapController.center, newZoom);
            },
            child: Icon(
              Icons.zoom_out,
              color: FlutterFlowTheme.of(context).primary,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "btn3",
            backgroundColor: FlutterFlowTheme.of(context).info,
            onPressed: () {
              _animatedMapMove(
                  ll.LatLng(widget.userLocation.latitude,
                      widget.userLocation.longitude),
                  _mapController.zoom);
            },
            child: Icon(Icons.my_location,
                color: FlutterFlowTheme.of(context).primary),
          ),
        ],
      ),
    );
  }
}

class BikeDetailCard extends StatelessWidget {
  final MotorbikeRecord bike;
  final VoidCallback onClose;

  const BikeDetailCard({
    super.key,
    required this.bike,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 180,
        constraints: BoxConstraints(
          maxWidth: 180,
          maxHeight: 135,
        ),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Container(
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height * 0.70,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        bike.photos[0],
                        width: double.infinity,
                        // height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(1, -1),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: onClose,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          bike.brand,
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            bike.fullAddress,
                            overflow: TextOverflow.ellipsis,
                            style: FlutterFlowTheme.of(context).bodySmall,
                          ),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${bike.price} ₽',
                            textAlign: TextAlign.right,
                            style: FlutterFlowTheme.of(context).bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
