import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/controllers/favoriteProperty/favoritePropertyController.dart';
import '../../widgets/appSnackBar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:provider/provider.dart';

class FavoriteHeartButton extends StatefulWidget {
  final String propertyId;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const FavoriteHeartButton({
    Key? key,
    required this.propertyId,
    this.size = 40.0,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  State<FavoriteHeartButton> createState() => _FavoriteHeartButtonState();
}

class _FavoriteHeartButtonState extends State<FavoriteHeartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFavorited = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Check initial favorite status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFavoriteStatus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    final controller = context.read<FavoritePropertyController>();
    final isFavorited = controller.isPropertyFavorited(widget.propertyId);

    if (mounted) {
      setState(() {
        _isFavorited = isFavorited;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = context.read<FavoritePropertyController>();
      final success =
          await controller.toggleFavorite(widget.propertyId, context);

      if (success && mounted) {
        setState(() {
          _isFavorited = !_isFavorited;
        });

        // Trigger animation
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      }
    } catch (e) {
      // Handle error silently or show snackbar
      if (mounted) {
        AppSnackBar.showSnackBar(
          context,
          'Error',
          'Failed to update favorite status: $e',
          ContentType.failure,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = widget.backgroundColor ??
        (isDark
            ? Colors.black.withOpacity(0.7)
            : Colors.white.withOpacity(0.9));
    final iconColor = widget.iconColor ??
        (_isFavorited ? Colors.red : (isDark ? Colors.white : Colors.grey));

    return Consumer<FavoritePropertyController>(
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: _toggleFavorite,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          ),
                        )
                      : Icon(
                          _isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: iconColor,
                          size: widget.size * 0.5,
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
