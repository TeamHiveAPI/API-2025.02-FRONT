import 'package:flutter/material.dart';
import 'package:sistema_almox/widgets/button.dart';

typedef OnLoginSelected = void Function(Map<String, String> credentials);

class DebugLoginModal extends StatelessWidget {
  final Map<String, Map<String, String>> logins;
  final OnLoginSelected onLoginSelected;

  const DebugLoginModal({
    super.key,
    required this.logins,
    required this.onLoginSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...logins.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: CustomButton(
              text: entry.key,
              onPressed: () {
                onLoginSelected(entry.value);
              },
              secondary: true,
            ),
          );
        }),
      ],
    );
  }
}