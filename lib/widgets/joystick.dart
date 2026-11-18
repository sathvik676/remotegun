import 'package:cloud_car/models/movement_command.dart';
import 'package:cloud_car/utils/app_theme.dart';
import 'package:flutter/material.dart';

class Joystick extends StatefulWidget {
  const Joystick({
    super.key,
    required this.size,
    required this.onChanged,
    required this.onRelease,
    this.enabled = true,
  });

  final double size;
  final void Function(JoystickVector vector) onChanged;
  final VoidCallback onRelease;
  final bool enabled;

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> with SingleTickerProviderStateMixin {
  static const double _deadZonePixels = 8;

  late final AnimationController _controller;
  Tween<Offset> _returnTween = Tween<Offset>(
    begin: Offset.zero,
    end: Offset.zero,
  );
  Offset _knob = Offset.zero;
  bool _hasActiveInput = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _controller.addListener(() {
      if (!mounted) return;
      setState(() => _knob = _returnTween.evaluate(_controller));
    });
  }

  @override
  void didUpdateWidget(covariant Joystick oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _hasActiveInput) _release();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update(Offset localPosition) {
    if (!widget.enabled) return;

    final center = Offset(widget.size / 2, widget.size / 2);
    final radius = _radius;
    var offset = localPosition - center;
    final distance = offset.distance;

    if (distance > radius) {
      offset = offset / distance * radius;
    }
    if (offset.distance < _deadZonePixels) {
      offset = Offset.zero;
    }

    _controller.reset();
    setState(() => _knob = offset);

    final magnitude = (offset.distance / radius).clamp(0.0, 1.0).toDouble();
    _hasActiveInput = magnitude > 0;

    widget.onChanged(
      JoystickVector(
        x: offset.dx / radius,
        y: offset.dy / radius,
        magnitude: magnitude,
      ),
    );
  }

  void _release() {
    if (!_hasActiveInput) {
      _knob = Offset.zero;
      if (mounted) setState(() {});
      return;
    }

    _hasActiveInput = false;
    _returnTween = Tween<Offset>(begin: _knob, end: Offset.zero);
    _controller.forward(from: 0);
    widget.onRelease();
  }

  double get _radius => widget.size * 0.34;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _update(details.localPosition),
      onPanUpdate: (details) => _update(details.localPosition),
      onPanEnd: (_) => _release(),
      onPanCancel: _release,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _JoystickPainter(
            knob: _knob,
            radius: _radius,
            enabled: widget.enabled,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 6,
                child: _label('FWD', AppTheme.green),
              ),
              Positioned(
                bottom: 6,
                child: _label('REV', AppTheme.textMuted),
              ),
              Positioned(
                left: 6,
                child: _label('L', AppTheme.textMuted),
              ),
              Positioned(
                right: 6,
                child: _label('R', AppTheme.textMuted),
              ),
              const Icon(
                Icons.add_rounded,
                color: Color(0x334A5F80),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color.withOpacity(widget.enabled ? 0.85 : 0.35),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  const _JoystickPainter({
    required this.knob,
    required this.radius,
    required this.enabled,
  });

  final Offset knob;
  final double radius;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final knobCenter = center + knob;

    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = (enabled ? AppTheme.cyan : AppTheme.textMuted).withOpacity(0.35);
    canvas.drawCircle(center, radius + 22, outer);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = (enabled ? AppTheme.cyan : AppTheme.textMuted).withOpacity(0.18);
    canvas.drawCircle(center, radius, ring);
    canvas.drawCircle(center, radius * 0.62, ring..strokeWidth = 1);

    final cross = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppTheme.border.withOpacity(0.55);
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      cross,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      cross,
    );

    final glow = Paint()
      ..color = AppTheme.cyan.withOpacity(enabled ? 0.20 : 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(knobCenter, 32, glow);

    final knobPaint = Paint()
      ..shader = LinearGradient(
        colors: enabled
            ? [AppTheme.cyan, AppTheme.violet]
            : [AppTheme.textMuted, AppTheme.border],
      ).createShader(
        Rect.fromCircle(center: knobCenter, radius: 28),
      );
    canvas.drawCircle(knobCenter, 28, knobPaint);

    final knobHighlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.55);
    canvas.drawCircle(knobCenter, 28, knobHighlight);
  }

  @override
  bool shouldRepaint(covariant _JoystickPainter oldDelegate) {
    return oldDelegate.knob != knob ||
        oldDelegate.radius != radius ||
        oldDelegate.enabled != enabled;
  }
}
