import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';

class GtaButton extends StatefulWidget {
  final String label;
  final String icon;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final bool isLoading;
  final Color? glowColor;
  final String? description;

  const GtaButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.onLongPress,
    this.isLoading = false,
    this.glowColor,
    this.description,
  });

  @override
  State<GtaButton> createState() => _GtaButtonState();
}

class _GtaButtonState extends State<GtaButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isLongPress = false;
  Color? _feedbackColor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
      _isLongPress = false;
      _feedbackColor = Colors.green.withOpacity(0.3);
    });
    _controller.forward();
    HapticFeedback.mediumImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();

    // Show tap feedback briefly
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _feedbackColor = null);
      }
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
      _feedbackColor = null;
    });
    _controller.reverse();
  }

  void _handleLongPressStart() {
    if (widget.onLongPress != null) {
      setState(() {
        _isLongPress = true;
        _feedbackColor = Colors.blue.withOpacity(0.3);
      });
      HapticFeedback.heavyImpact();
    }
  }

  void _handleLongPressEnd() {
    // Show hold feedback briefly
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isLongPress = false;
          _feedbackColor = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.glowColor ?? AppColors.gtaGreen;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return GestureDetector(
      onTapDown: widget.isLoading ? null : _handleTapDown,
      onTapUp: widget.isLoading ? null : _handleTapUp,
      onTapCancel: widget.isLoading ? null : _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      onLongPressStart: widget.isLoading ? null : (_) => _handleLongPressStart(),
      onLongPressEnd: widget.isLoading ? null : (_) {
        _handleLongPressEnd();
        if (widget.onLongPress != null) {
          widget.onLongPress!();
        }
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: _feedbackColor ?? AppColors.cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isPressed ? glowColor : glowColor.withOpacity(0.5),
              width: _isPressed ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(_isPressed ? 0.6 : 0.3),
                blurRadius: _isPressed ? 20 : 12,
                spreadRadius: _isPressed ? 2 : 0,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isLandscape ? 10 : 12,
              horizontal: 10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(glowColor),
                    ),
                  )
                else
                  Text(
                    widget.icon,
                    style: const TextStyle(fontSize: 36),
                  ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _isPressed ? glowColor : AppColors.textPrimary,
                        fontSize: 15,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
