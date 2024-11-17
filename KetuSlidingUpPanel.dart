//sliding_up_panel: ^2.0.0+1
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

import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:ketu_kz/components/content_home_page_widget_widget.dart';

class CustomSlidingUpPanel extends StatefulWidget {
  const CustomSlidingUpPanel({
    Key? key,
    this.width,
    this.height,
    this.sourceAddress,
    this.destAddress,
    required this.mapInteraction,
    required this.maxHeight,
    required this.tripType,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String? sourceAddress;
  final String? destAddress;
  final bool mapInteraction;
  final double maxHeight;
  final int tripType;

  @override
  _CustomSlidingUpPanelState createState() => _CustomSlidingUpPanelState();
}

class _CustomSlidingUpPanelState extends State<CustomSlidingUpPanel> {
  final PanelController _controller = PanelController();
  String? updatedSource;
  String? updatedDest;
  double minHeight = 130;
  late double midHeight;
  late double maxHeight;

  @override
  void initState() {
    super.initState();
    maxHeight = widget.maxHeight;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _controller.open();
      _controller.animatePanelToPosition(
        400 / (MediaQuery.of(context).size.height - 100),
        duration: Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    });
  }

  @override
  void didUpdateWidget(CustomSlidingUpPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tripType != widget.tripType) {
      if (widget.tripType == 1) {
        _controller.animatePanelToPosition(
          400 /
              widget
                  .maxHeight, // Use 0.0 to go to the minimum (closed) position
          duration:
              Duration(milliseconds: 250), // Set the speed of the animation
          curve: Curves.easeOut, // Define the animation curve
        );
      } else if (widget.tripType == 2) {
        _controller.animatePanelToPosition(
          400 /
              widget
                  .maxHeight, // Use 0.0 to go to the minimum (closed) position
          duration:
              Duration(milliseconds: 250), // Set the speed of the animation
          curve: Curves.easeOut, // Define the animation curve
        );
      }
    }
    if (oldWidget.mapInteraction != widget.mapInteraction) {
      if (widget.mapInteraction == true) {
        print('mapinteraction: true');
        setState(() {
          // minHeight = 130;
        });
        _controller.animatePanelToPosition(
          0.0, // Use 0.0 to go to the minimum (closed) position
          duration:
              Duration(milliseconds: 250), // Set the speed of the animation
          curve: Curves.easeOut, // Define the animation curve
        );
      } else {
        print('mapinteraction: false');
        setState(() {
          // minHeight = 400;
        });
        // _controller.show();
        // _controller.animatePanelToPosition(
        //   400 /
        //       widget
        //           .maxHeight, //0.0, // Use 0.0 to go to the minimum (closed) position
        //   duration:
        //       Duration(milliseconds: 250), // Set the speed of the animation
        //   curve: Curves.easeOut, // Define the animation curve
        // );
        // Keep the panel closed when map interaction ends
        _controller.animatePanelToPosition(
          0.0,
          duration: Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }

    if (oldWidget.sourceAddress != widget.sourceAddress ||
        oldWidget.destAddress != widget.destAddress) {
      if (widget.sourceAddress != null) {
        setState(() {
          updatedSource = widget.sourceAddress;
        });
        // } else {
        //   if (FFAppState().tripType == 1) {
        //     setState(() {
        //       midHeight = 560;
        //     });
        //     _controller.animatePanelToPosition(midHeight / maxHeight,
        //         duration: Duration(milliseconds: 150), curve: Curves.easeInOut);
        //   } else if (FFAppState().tripType == 2) {
        //     setState(() {
        //       midHeight = maxHeight;
        //     });
        //     _controller.animatePanelToPosition(midHeight / maxHeight,
        //         duration: Duration(milliseconds: 150), curve: Curves.easeInOut);
        //   }
      }
      if (widget.destAddress != null) {
        setState(() {
          updatedDest = widget.destAddress;
        });
        // } else {
        //   if (FFAppState().tripType == 1) {
        //     setState(() {
        //       midHeight = 560;
        //     });
        //     _controller.animatePanelToPosition(midHeight / maxHeight,
        //         duration: Duration(milliseconds: 150), curve: Curves.easeInOut);
        //   } else if (FFAppState().tripType == 2) {
        //     setState(() {
        //       midHeight = maxHeight;
        //     });
        //     _controller.animatePanelToPosition(midHeight / maxHeight,
        //         duration: Duration(milliseconds: 150), curve: Curves.easeInOut);
        //   }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // maxHeight = MediaQuery.of(context).size.height - 100;
    midHeight = 560;
    return SlidingUpPanel(
      controller: _controller,
      // minHeight: MediaQuery.of(context).size.height * .05,
      // maxHeight: MediaQuery.of(context).size.height * .60,
      minHeight: minHeight,
      maxHeight: maxHeight,
      defaultPanelState: PanelState.CLOSED,
      panelBuilder: (ScrollController sc) => _panelBody(sc),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(18.0),
        topRight: Radius.circular(18.0),
      ),
      color: FlutterFlowTheme.of(context).secondaryBackground,
      snapPoint: 400 / (MediaQuery.of(context).size.height - 100),
      // isDraggable: false,
      onPanelSlide: (double position) => closeKeyboard(position),
      // onPanelSlide: (double position) => _handlePanelSlide(position),
    );
  }

  void closeKeyboard(position) {
    if (position < 0.1) {
      FocusScope.of(context).unfocus();
    }
  }

  void _handlePanelSlide(double position) {
    double currentHeight = position * maxHeight;
    if (FFAppState().tripType == 1) {
      setState(() {
        midHeight = 560;
      });
      _controller.animatePanelToPosition(midHeight / maxHeight,
          duration: Duration(milliseconds: 150), curve: Curves.easeInOut);
    } else if (FFAppState().tripType == 2) {
      setState(() {
        midHeight = maxHeight;
      });
      _controller.animatePanelToPosition(midHeight / maxHeight,
          duration: Duration(milliseconds: 150), curve: Curves.easeInOut);
    }
    // if (currentHeight < midHeight - 50 && currentHeight > minHeight + 250) {
    //   FocusScope.of(context).unfocus();
    //   _controller.animatePanelToPosition(midHeight / maxHeight,
    //       duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
    // }
  }

  Widget _panelBody(ScrollController sc) {
    // This is the draggable area
    Widget dragHandle = GestureDetector(
      onVerticalDragUpdate: (details) {
        double newPosition =
            _controller.panelPosition + details.primaryDelta! / maxHeight;
        _controller.animatePanelToPosition(
          newPosition.clamp(0.0, 1.0),
          duration: Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      },
      child: Center(
        child: Container(
          width: 64,
          height: 5,
          margin: const EdgeInsets.only(top: 12.0, bottom: 12.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).tertiary,
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );

    return Column(
      children: [
        dragHandle,
        Expanded(
          child: ListView.builder(
            controller: sc,
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return ContentHomePageWidgetWidget(
                  sourceAddress: updatedSource, destAddress: updatedDest);
            },
          ),
        ),
      ],
    );
  }
}
