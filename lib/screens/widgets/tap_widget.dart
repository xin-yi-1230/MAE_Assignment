import 'package:flutter/material.dart';

class TapWidget extends StatefulWidget {
  final Widget Function(bool pressed) builder;
  final VoidCallback onTap;
  const TapWidget({super.key, required this.builder, required this.onTap});

  @override
  State<TapWidget> createState() => _TapWidgetState();
}

class _TapWidgetState extends State<TapWidget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: widget.builder(_pressed),
    );
  }
}
