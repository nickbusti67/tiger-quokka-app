import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme.dart';
import '../widgets/glowing_sigil.dart';
import '../utils/responsive_layout.dart';

class LandingScreen extends StatefulWidget {
  final VoidCallback onEnter;

  const LandingScreen({
    super.key,
    required this.onEnter,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isMobile = ResponsiveLayout.isMobileLayout(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
          ),

          // Floating particles
          const Positioned.fill(
            child: FloatingParticles(
              particleCount: 30,
              color: AppTheme.goldPrimary,
              maxSize: 3,
            ),
          ),

          // Radial glow in center
          Positioned(
            top: screenSize.height * 0.2,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                return Container(
                  height: screenSize.height * 0.4,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.goldPrimary
                            .withValues(alpha: 0.08 + _breathingController.value * 0.05),
                        AppTheme.goldPrimary.withValues(alpha: 0.02),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: ResponsiveLayout.getPadding(context),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveLayout.getMaxContentWidth(context),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: isMobile ? 40 : 60),

                      // Main sigil
                      const GlowingSigil(
                        size: 140,
                        animate: true,
                      ),

                      const SizedBox(height: 40),

                      // Title
                      Text(
                        'Tiger & Quokka',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppTheme.goldLight,
                              shadows: [
                                Shadow(
                                  color: AppTheme.goldPrimary.withValues(alpha: 0.5),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 1000.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            delay: 400.ms,
                            duration: 800.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Il Rituale delle Anime Connesse',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.textSecondary,
                              letterSpacing: 2,
                            ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 700.ms, duration: 1000.ms),

                      const SizedBox(height: 48),

                      // Decorative divider
                      const MysticalDivider(width: 250)
                          .animate()
                          .fadeIn(delay: 900.ms, duration: 800.ms),

                      const SizedBox(height: 48),

                      // Poetic text
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Due anime. Un rituale.\nOgni giorno, insieme.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                                fontStyle: FontStyle.italic,
                                height: 1.8,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 1100.ms, duration: 1000.ms),

                      const SizedBox(height: 60),

                      // Animal icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAnimalBadge(
                            emoji: '🐯',
                            label: 'Tigre',
                            subtitle: 'Intensità',
                            colors: const [Color(0xFFFF8C00), Color(0xFFFF4500)],
                          )
                              .animate()
                              .fadeIn(delay: 1300.ms, duration: 800.ms)
                              .slideX(
                                begin: -0.3,
                                end: 0,
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(width: 24),
                          Text(
                            '&',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: AppTheme.goldPrimary,
                                ),
                          ).animate().fadeIn(delay: 1500.ms, duration: 800.ms),
                          const SizedBox(width: 24),
                          _buildAnimalBadge(
                            emoji: '🦘',
                            label: 'Quokka',
                            subtitle: 'Tenerezza',
                            colors: const [Color(0xFF8B4513), Color(0xFF654321)],
                          )
                              .animate()
                              .fadeIn(delay: 1300.ms, duration: 800.ms)
                              .slideX(
                                begin: 0.3,
                                end: 0,
                                curve: Curves.easeOutCubic,
                              ),
                        ],
                      ),

                      const SizedBox(height: 60),

                      // Enter button
                      _buildEnterButton(context)
                          .animate()
                          .fadeIn(delay: 1700.ms, duration: 800.ms)
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            delay: 1700.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 40),

                      // Footer text
                      Text(
                        '✧ Custodi del vostro amore ✧',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textMuted,
                              letterSpacing: 1.5,
                            ),
                      ).animate().fadeIn(delay: 2000.ms, duration: 800.ms),

                      SizedBox(height: isMobile ? 40 : 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalBadge({
    required String emoji,
    required String label,
    required String subtitle,
    required List<Color> colors,
  }) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.goldLight,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
              ),
        ),
      ],
    );
  }

  Widget _buildEnterButton(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onEnter,
        child: AnimatedBuilder(
          animation: _breathingController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              decoration: BoxDecoration(
                gradient: AppTheme.goldShimmer,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.goldPrimary
                        .withValues(alpha: 0.3 + _breathingController.value * 0.2),
                    blurRadius: 20 + _breathingController.value * 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ENTRA NEL RITUALE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppTheme.primaryDark,
                    size: 20,
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
