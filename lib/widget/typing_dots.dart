import 'package:flutter/material.dart';

class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  _TypingDotsState createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)
          ..repeat();

    _animations = List.generate(3, (i) {
      return Tween<double>(begin: 0, end: -4).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            i * 0.2,
            0.6 + i * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, _animations[index].value),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2,vertical: 2),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, _buildDot),
    );
  }
}
