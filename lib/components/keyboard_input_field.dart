import 'package:clay_containers/constants.dart';
import 'package:flutter/material.dart';
import 'package:clay_containers/widgets/clay_container.dart';

class KeyboardInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;

  const KeyboardInputField({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      color: const Color(0xFFf2f2f2),
      height: 50,
      width: 150,
      depth: 20,
      spread: 5,
      borderRadius: 25,
      curveType: CurveType.convex,
      child: TextButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Enter text',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        onSend(controller.text);
                        Navigator.pop(context);
                      },
                      child: const Text('Send'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Text('Keyboard Input'),
      ),
    );
  }
}
