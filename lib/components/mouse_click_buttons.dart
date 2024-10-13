import 'package:clay_containers/constants.dart';
import 'package:flutter/material.dart';
import 'package:clay_containers/widgets/clay_container.dart';

class MouseClickButtons extends StatelessWidget {
  final VoidCallback onLeftClick;
  final VoidCallback onRightClick;
  final Color baseColor;

  const MouseClickButtons({
    super.key,
    required this.onLeftClick,
    required this.onRightClick,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildClickButton('Left Click', onLeftClick),
        _buildClickButton('Right Click', onRightClick),
      ],
    );
  }

  Widget _buildClickButton(String label, VoidCallback onPressed) {
    return ClayContainer(
      color: baseColor,
      height: 50,
      width: 150,
      depth: 20,
      spread: 5,
      borderRadius: 25,
      curveType: CurveType.convex,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(color: Colors.grey[800]),
        ),
      ),
    );
  }
}
