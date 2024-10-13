import 'package:flutter/material.dart';

class TrackPad extends StatefulWidget {
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(double) onZoomUpdate;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final Color baseColor;

  const TrackPad({
    super.key,
    required this.onPanUpdate,
    required this.onZoomUpdate,
    required this.onTap,
    required this.onDoubleTap,
    required this.baseColor,
  });

  @override
  TrackPadState createState() => TrackPadState();
}

class TrackPadState extends State<TrackPad> {
  double _mouseX = 200; // Initial center position
  double _mouseY = 200; // Initial center position
  bool _isDragging = false;
  bool _isTapped = false;

  void _handleTap() {
    setState(() {
      _isTapped = true;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isTapped = false;
      });
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        setState(() {
          _isDragging = true;
          _mouseX = details.localFocalPoint.dx;
          _mouseY = details.localFocalPoint.dy;
        });
      },
      onScaleUpdate: (details) {
        setState(() {
          _mouseX = (_mouseX + details.focalPointDelta.dx).clamp(40.0, 360.0);
          _mouseY = (_mouseY + details.focalPointDelta.dy).clamp(40.0, 360.0);
        });
        widget.onPanUpdate(DragUpdateDetails(
          delta: details.focalPointDelta,
          localPosition: details.localFocalPoint,
          globalPosition: details.focalPoint,
        ));
        if (details.pointerCount > 1) {
          // Check if more than one finger is used
          widget.onZoomUpdate(details.scale);
        }
      },
      onScaleEnd: (details) {
        setState(() {
          _isDragging = false;
          _mouseX = _mouseX.clamp(40.0, 360.0);
          _mouseY = _mouseY.clamp(40.0, 360.0);
        });
      },
      onTap: _handleTap,
      onDoubleTap: widget.onDoubleTap,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          color: widget.baseColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-5, -5),
              blurRadius: 10,
            ),
            BoxShadow(
              color: Colors.grey[300]!,
              offset: const Offset(5, 5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: _mouseX - 50,
              top: _mouseY - 50,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.baseColor,
                  boxShadow: _isDragging || _isTapped
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(5, 5),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                          const BoxShadow(
                            color: Colors.white,
                            offset: Offset(-5, -5),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : [
                          const BoxShadow(
                            color: Colors.white,
                            offset: Offset(-2, -2),
                            blurRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.grey[300]!,
                            offset: const Offset(2, 2),
                            blurRadius: 5,
                          ),
                        ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
