import 'package:flutter/material.dart';

class FocusIndicator extends StatefulWidget {
  final Offset position;

  const FocusIndicator({super.key, required this.position});

  @override
  State<FocusIndicator> createState() => _FocusIndicatorState();
}

class _FocusIndicatorState extends State<FocusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 40,
      top: widget.position.dy - 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_controller.value * 0.2),
            child: Opacity(
              opacity: 1.0 - _controller.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.yellow,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
