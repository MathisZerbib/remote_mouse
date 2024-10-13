import 'package:flutter/material.dart';
import '../main.dart';

class VolumeControl extends StatelessWidget {
  final double currentVolume;
  final ValueChanged<double> onVolumeChanged;

  const VolumeControl({
    super.key,
    required this.currentVolume,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(Icons.volume_down, color: Colors.grey[600]),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 8,
                  thumbShape: CustomSliderThumbShape(),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 20),
                  activeTrackColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: const Color(0xFFf2f2f2),
                  overlayColor: Colors.grey.withValues(alpha: 0.3),
                ),
                child: Slider(
                  value: currentVolume,
                  onChanged: onVolumeChanged,
                  min: 0,
                  max: 1,
                ),
              ),
            ),
            Icon(Icons.volume_up, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
