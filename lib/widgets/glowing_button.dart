import 'package:flutter/material.dart';

class GlowingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color glowColor;
  final double borderRadius;

  const GlowingButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.glowColor = const Color(0xFFA3E635),
    this.borderRadius = 8,
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton> with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _glowAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.glowColor;
    final viaColor = glowColor.withOpacity(0.075);
    final toColor = glowColor.withOpacity(0.2);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 1),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Gradient Overlay (After element in React)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            viaColor.withOpacity(viaColor.opacity * _glowAnimation.value),
                            toColor.withOpacity(toColor.opacity * _glowAnimation.value),
                          ],
                          stops: const [0.4, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  DefaultTextStyle(
                    style: TextStyle(
                      color: _isHovering ? Colors.grey.shade600 : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    child: widget.child,
                  ),
                  // Side Glow Bar (Before element in React)
                  Positioned(
                    right: -1,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 5,
                        height: _isHovering ? 24 : 0,
                        decoration: BoxDecoration(
                          color: glowColor,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(2)),
                          boxShadow: [
                            BoxShadow(
                              color: glowColor.withOpacity(0.8),
                              blurRadius: 10,
                              offset: const Offset(-2, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
