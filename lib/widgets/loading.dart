import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;

  const LoadingOverlay({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // This container will cover the entire screen
        if (isLoading)
          Container(
            color: Colors.black54, // Transparent black background
            child: Center(
              child: CircularProgressIndicator(), // Spinning circle indicator
            ),
          ),
      ],
    );
  }
}
