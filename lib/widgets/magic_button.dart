import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class MagicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final IconData? icon;
  final double? width;
  final double? height;

  const MagicButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
    this.width,
    this.height,
  });

  @override
  State<MagicButton> createState() => _MagicButtonState();
}

class _MagicButtonState extends State<MagicButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: AppTheme.magicAnimationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: AppTheme.magicCurve),
    );

    if (widget.isPrimary) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: isEnabled ? (_) => _animationController.forward() : null,
            onTapUp: isEnabled ? (_) => _animationController.reverse() : null,
            onTapCancel:
                isEnabled ? () => _animationController.reverse() : null,
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height ?? 56,
              decoration: BoxDecoration(
                gradient:
                    widget.isPrimary
                        ? (isEnabled ? AppTheme.spellGradient : null)
                        : null,
                color:
                    widget.isPrimary
                        ? (isEnabled ? null : Colors.grey.withOpacity(0.3))
                        : (isEnabled
                            ? AppTheme.arcanePurple.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      widget.isPrimary
                          ? (isEnabled
                              ? AppTheme.shimmeringGold.withOpacity(
                                0.5 + _glowAnimation.value * 0.3,
                              )
                              : Colors.grey.withOpacity(0.3))
                          : (isEnabled
                              ? AppTheme.arcanePurple.withOpacity(0.5)
                              : Colors.grey.withOpacity(0.3)),
                  width: 1,
                ),
                boxShadow:
                    isEnabled && widget.isPrimary
                        ? [
                          BoxShadow(
                            color: AppTheme.shimmeringGold.withOpacity(
                              0.3 + _glowAnimation.value * 0.4,
                            ),
                            blurRadius: 12 + _glowAnimation.value * 8,
                            spreadRadius: _glowAnimation.value * 2,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? widget.onPressed : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.isPrimary
                                    ? AppTheme.midnightBlue
                                    : AppTheme.shimmeringGold,
                              ),
                            ),
                          )
                        else if (widget.icon != null)
                          Icon(
                            widget.icon,
                            color:
                                widget.isPrimary
                                    ? (isEnabled
                                        ? AppTheme.midnightBlue
                                        : Colors.grey)
                                    : (isEnabled
                                        ? AppTheme.shimmeringGold
                                        : Colors.grey),
                            size: 20,
                          ),
                        if ((widget.isLoading || widget.icon != null) &&
                            widget.text.isNotEmpty)
                          const SizedBox(width: 12),
                        if (widget.text.isNotEmpty)
                          Text(
                            widget.text,
                            style: TextStyle(
                              color:
                                  widget.isPrimary
                                      ? (isEnabled
                                          ? AppTheme.midnightBlue
                                          : Colors.grey)
                                      : (isEnabled
                                          ? AppTheme.shimmeringGold
                                          : Colors.grey),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
