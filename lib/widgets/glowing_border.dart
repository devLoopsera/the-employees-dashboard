import 'dart:math' as math;
import 'package:flutter/material.dart';

class GlowingBorder extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final double glowSpread;
  final bool disabled;

  const GlowingBorder({
    super.key,
    required this.child,
    this.borderRadius = 12,
    this.borderWidth = 2,
    this.glowSpread = 40,
    this.disabled = false,
  });

  @override
  State<GlowingBorder> createState() => _GlowingBorderState();
}

class _GlowingBorderState extends State<GlowingBorder> with SingleTickerProviderStateMixin {
  Offset _mousePos = Offset.zero;
  bool _isHovering = false;
  late AnimationController _controller;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disabled) return widget.child;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      onHover: (event) {
        setState(() {
          _mousePos = event.localPosition;
        });
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Smoothly animate opacity based on hover state
          _opacity = _isHovering ? 1.0 : 0.0;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // The Glowing Effect Layer
              Positioned.fill(
                child: CustomPaint(
                  painter: _GlowPainter(
                    mousePos: _mousePos,
                    isHovering: _isHovering,
                    opacity: _opacity,
                    borderRadius: widget.borderRadius,
                    borderWidth: widget.borderWidth,
                    glowSpread: widget.glowSpread,
                    angle: _controller.value * 2 * math.pi,
                  ),
                ),
              ),
              // The Actual Card Content
              widget.child,
            ],
          );
        },
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  final Offset mousePos;
  final bool isHovering;
  final double opacity;
  final double borderRadius;
  final double borderWidth;
  final double glowSpread;
  final double angle;

  _GlowPainter({
    required this.mousePos,
    required this.isHovering,
    required this.opacity,
    required this.borderRadius,
    required this.borderWidth,
    required this.glowSpread,
    required this.angle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final rect = Offset.zero & size;
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    
    // Create the "mask" for the border only
    final borderPath = Path()
      ..addRRect(rRect);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    // We use a combination of gradients to simulate the React effect
    // 1. A SweepGradient that rotates
    // 2. A RadialGradient focused on the mouse position (if hovering)
    
    final center = Offset(size.width / 2, size.height / 2);

    final List<Color> colors = [
      const Color(0xFFDD7BBB), // Pinkish
      const Color(0xFFD79F1E), // Gold
      const Color(0xFF5A922C), // Green
      const Color(0xFF4C7894), // Blue
      const Color(0xFFDD7BBB), // Back to Pink
    ];

    // Sweep gradient for the "conic" effect in the React code
    final sweepGradient = SweepGradient(
      center: Alignment.center,
      startAngle: angle,
      endAngle: angle + 2 * math.pi,
      colors: colors,
    );

    // Radial gradient for proximity effect
    final radialGradient = RadialGradient(
      center: Alignment(
        (mousePos.dx / size.width) * 2 - 1,
        (mousePos.dy / size.height) * 2 - 1,
      ),
      radius: glowSpread / math.min(size.width, size.height),
      colors: [
        Colors.white.withOpacity(0.8 * opacity),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 1.0],
    );

    // Combine or choose - the React code uses a conic gradient masked by proximity
    // In Flutter, we can blend them or just use the SweepGradient with a mask
    
    paint.shader = sweepGradient.createShader(rect);
    
    // Draw the main glowing border
    // To make it look like a "glow", we can draw it multiple times with different blurs
    // or use a MaskFilter.
    canvas.save();
    
    // Subtle outer glow
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth + 2
      ..shader = sweepGradient.createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, 4 * opacity);
      
    canvas.drawRRect(rRect, glowPaint);
    
    // Solid animated border
    canvas.drawRRect(rRect, paint);

    // Proximity Highlight (Light following the mouse)
    if (isHovering) {
      final highlightPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth + 1
        ..shader = radialGradient.createShader(rect);
      canvas.drawRRect(rRect, highlightPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) {
    return oldDelegate.mousePos != mousePos ||
        oldDelegate.isHovering != isHovering ||
        oldDelegate.opacity != opacity ||
        oldDelegate.angle != angle;
  }
}
