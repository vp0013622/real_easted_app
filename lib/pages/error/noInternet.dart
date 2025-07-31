import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/controllers/permissions/internetConnection.dart';
import 'package:inhabit_realties/providers/error_page_provider.dart';
import 'package:lottie/lottie.dart';
import '../widgets/appSnackBar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({super.key});

  @override
  State<NoInternet> createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final InternetConnection _internetConnection = InternetConnection();
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Bounce animation for the button
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Fade and scale animations for content
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);
    _bounceController.forward().then((_) => _bounceController.reverse());

    try {
      bool hasConnection = await _internetConnection.hasStableConnection();

      if (!mounted) return;

      if (hasConnection) {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        setState(() => _isChecking = false);
        _showErrorSnackbar();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChecking = false);
        _showErrorSnackbar();
      }
    }
  }

  void _showErrorSnackbar() {
    AppSnackBar.showSnackBar(
      context,
      'No Internet Connection',
      ErrorPageProvider.noInternetMessage,
      ContentType.failure,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lottie Animation
                        Lottie.asset(
                          'assets/animations/no_internet.json',
                          height: size.height * 0.3,
                          repeat: true,
                        ),
                        const SizedBox(height: 40),

                        // Title with Gradient Background
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.brandPrimary.withOpacity(0.1),
                                AppColors.brandSecondary.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppColors.brandPrimary.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            ErrorPageProvider.noInternetTitle,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                                  color: isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lightPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Message
                        Text(
                          ErrorPageProvider.noInternetMessage,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black87,
                                height: 1.4,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Retry Button
                        ScaleTransition(
                          scale: Tween<double>(
                            begin: 1.0,
                            end: 0.95,
                          ).animate(_bounceController),
                          child: Container(
                            width: size.width * 0.7,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.brandGradient,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brandPrimary.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _isChecking ? null : _checkConnection,
                                borderRadius: BorderRadius.circular(28),
                                child: Center(
                                  child: _isChecking
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.refresh_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              ErrorPageProvider.retryButtonText,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    color: Colors.white,
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
                      ],
                    ),
                  ),
                ),

                // Bottom Decoration
                Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
