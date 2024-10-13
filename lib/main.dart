import 'package:clay_containers/constants.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:volume_controller/volume_controller.dart';
import 'dart:async';
import 'components/volume_control.dart';
import 'components/keyboard_input_field.dart';
import 'components/track_pad.dart';
import 'components/mouse_click_buttons.dart';

void main() => runApp(const MouseControlApp());

class MouseControlApp extends StatelessWidget {
  const MouseControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mouse & Keyboard Controller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MouseControlPage(),
    );
  }
}

class MouseControlPage extends StatefulWidget {
  const MouseControlPage({super.key});

  @override
  MouseControlPageState createState() => MouseControlPageState();
}

class MouseControlPageState extends State<MouseControlPage> {
  late IO.Socket socket;
  bool isConnected = false;
  String serverAddress = '192.168.218.1:8765'; // Change to your server address
  TextEditingController keyboardInputController = TextEditingController();
  late double _currentVolume;
  double _lastDeltaX = 0;
  double _lastDeltaY = 0;

  late Timer _throttleTimer;
  final int throttleInterval = 16; // ~60 FPS throttle interval
  Color baseColor = const Color(0xFFf2f2f2);

  @override
  void initState() {
    super.initState();
    connectSocket();
    VolumeController().getVolume().then((volume) {
      setState(() {
        _currentVolume = volume;
      });
    });

    // Timer to throttle mouse movement updates
    _throttleTimer =
        Timer.periodic(Duration(milliseconds: throttleInterval), (timer) {
      if (_lastDeltaX != 0 || _lastDeltaY != 0) {
        sendMouseMove(_lastDeltaX, _lastDeltaY);
        _lastDeltaX = 0;
        _lastDeltaY = 0;
      }
    });
  }

  void connectSocket() {
    socket = IO.io('http://$serverAddress', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      setState(() => isConnected = true);
    });

    socket.onDisconnect((_) {
      setState(() => isConnected = false);
    });

    socket.onConnectError((err) => print('Connect error: $err'));
    socket.onError((err) => print('Error: $err'));
  }

  // Throttled mouse movement to reduce latency
  void sendMouseMove(double deltaX, double deltaY) {
    if (isConnected) {
      socket.emit('accel_mouse_event', {'x': deltaX, 'y': deltaY});
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    _lastDeltaX += details.delta.dx;
    _lastDeltaY += details.delta.dy;
  }

  void onZoomUpdate(double scale) {
    if (isConnected) {
      socket.emit('zoom', {'scale': scale});
    }
  }

  void sendClick(String type) {
    socket.emit('mouse_click', {'type': type});
  }

  void sendKeyboardInput(String character) {
    socket.emit('keyboard_input', {'character': character});
    keyboardInputController.clear();
  }

  void increaseVolume() {
    VolumeController().setVolume(_currentVolume + 0.1);
    VolumeController().getVolume().then((volume) {
      setState(() {
        _currentVolume = volume;
      });
    });
    socket.emit('volume_up'); // Send 'volume_up' event without volume value
  }

  void decreaseVolume() {
    VolumeController().setVolume(_currentVolume - 0.1);
    VolumeController().getVolume().then((volume) {
      setState(() {
        _currentVolume = volume;
      });
    });
    socket.emit('volume_down'); // Send 'volume_down' event without volume value
  }

  @override
  void dispose() {
    socket.disconnect();
    _throttleTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: baseColor,
      appBar: AppBar(
        title: const Text('Mouse & Keyboard Controller'),
        backgroundColor: baseColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VolumeControl(
              currentVolume: _currentVolume,
              onVolumeChanged: (newValue) {
                setState(() {
                  _currentVolume = newValue;
                });
                VolumeController().setVolume(newValue);
                socket.emit('volume_change', {'volume': newValue});
              },
            ),
            const SizedBox(height: 20),
            KeyboardInputField(
              controller: keyboardInputController,
              onSend: (text) {
                sendKeyboardInput(text);
              },
            ),
            const SizedBox(height: 20),
            TrackPad(
              onPanUpdate: onPanUpdate,
              onZoomUpdate: onZoomUpdate, // Add this line
              onTap: () => sendClick('left'),
              onDoubleTap: () => socket.emit('mouse_double_click'),
              baseColor: baseColor,
            ),
            const SizedBox(height: 20),
            MouseClickButtons(
              onLeftClick: () => sendClick('left'),
              onRightClick: () => sendClick('right'),
              baseColor: baseColor,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class CustomSliderThumbShape extends SliderComponentShape {
  static const double enabledThumbRadius = 12;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.grey[300]!
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(center, enabledThumbRadius, shadowPaint);
    canvas.drawCircle(center, enabledThumbRadius, paint);
  }
}
