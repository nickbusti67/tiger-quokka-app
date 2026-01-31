import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../models/models.dart';
import '../services/ritual_service.dart';
import '../widgets/animated_veil.dart';
import '../widgets/glowing_sigil.dart';
import '../utils/responsive_layout.dart';

class RitualFlowScreen extends StatefulWidget {
  const RitualFlowScreen({super.key});

  @override
  State<RitualFlowScreen> createState() => _RitualFlowScreenState();
}

class _RitualFlowScreenState extends State<RitualFlowScreen>
    with TickerProviderStateMixin {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();

  late AnimationController _pulseController;
  
  RitualPhase _currentPhase = RitualPhase.ilVelo;
  bool _hasSubmittedAnswer = false;
  bool _partnerHasAnswered = false;
  bool _isRevealing = false;
  bool _isRevealed = false;
  
  String _userAnswer = '';
  String _partnerAnswer = '';
  
  late RitualQuestion _currentQuestion;
  late User _currentUser;
  late User _partner;

  @override
  void initState() {
    super.initState();
    final ritualService = Provider.of<RitualService>(context, listen: false);
    _currentQuestion = ritualService.getTodaysQuestion();
    _currentUser = ritualService.getCurrentUser();
    _partner = ritualService.getPartner();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Simulate partner answering after delay
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _hasSubmittedAnswer && !_partnerHasAnswered) {
        setState(() {
          _partnerHasAnswered = true;
          _partnerAnswer = 'Il momento in cui ci siamo guardati negli occhi per la prima volta, nel piccolo caffè vicino al parco.';
        });
      }
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _submitAnswer() {
    if (_answerController.text.trim().isEmpty) return;
    
    setState(() {
      _userAnswer = _answerController.text.trim();
      _hasSubmittedAnswer = true;
    });
    
    _answerFocusNode.unfocus();
  }

  void _revealAnswers() {
    setState(() {
      _isRevealing = true;
    });
    
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isRevealed = true;
        });
      }
    });
  }

  void _proceedToNextPhase() {
    if (_currentPhase == RitualPhase.ilSigillo) {
      Navigator.of(context).pop();
      return;
    }
    
    // For demo, show coming soon for other phases
    _showComingSoonDialog();
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          side: BorderSide(
            color: AppTheme.goldPrimary.withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GlowingSigil(size: 80),
              const SizedBox(height: 24),
              Text(
                'Prossimamente...',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.goldLight,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Le fasi successive del rituale\nsaranno presto disponibili.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ho capito'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
          ),

          // Particles
          const Positioned.fill(
            child: FloatingParticles(
              particleCount: 20,
              color: AppTheme.goldPrimary,
              maxSize: 2.5,
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _buildPhaseContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios),
            color: AppTheme.goldLight,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _getPhaseTitle(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.goldLight,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getPhaseSubtitle(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  String _getPhaseTitle() {
    switch (_currentPhase) {
      case RitualPhase.ilVelo:
        return 'Il Velo';
      case RitualPhase.ilPatto:
        return 'Il Patto';
      case RitualPhase.laProva:
        return 'La Prova';
      case RitualPhase.ilSigillo:
        return 'Il Sigillo';
      case RitualPhase.completed:
        return 'Rituale Completo';
    }
  }

  String _getPhaseSubtitle() {
    switch (_currentPhase) {
      case RitualPhase.ilVelo:
        return 'Risposte segrete e rivelazione simultanea';
      case RitualPhase.ilPatto:
        return 'Scelte di allineamento';
      case RitualPhase.laProva:
        return 'Una piccola sfida condivisa';
      case RitualPhase.ilSigillo:
        return 'Ricompensa narrativa';
      case RitualPhase.completed:
        return 'Il Codex ha registrato questo frammento';
    }
  }

  Widget _buildPhaseContent() {
    return SingleChildScrollView(
      padding: ResponsiveLayout.getPadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveLayout.getMaxContentWidth(context),
          ),
          child: _buildVeloPhase(),
        ),
      ),
    );
  }

  Widget _buildVeloPhase() {
    if (_isRevealing || _isRevealed) {
      return _buildRevealSection();
    }
    
    if (_hasSubmittedAnswer) {
      return _buildWaitingSection();
    }
    
    return _buildQuestionSection();
  }

  Widget _buildQuestionSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        
        // Phase icon
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceCard,
                border: Border.all(
                  color: AppTheme.goldPrimary.withValues(
                    alpha: 0.3 + _pulseController.value * 0.3,
                  ),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.goldPrimary.withValues(
                      alpha: 0.2 + _pulseController.value * 0.2,
                    ),
                    blurRadius: 20 + _pulseController.value * 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.visibility_outlined,
                color: AppTheme.goldPrimary,
                size: 36,
              ),
            );
          },
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        
        const SizedBox(height: 32),
        
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.roseDeep.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.roseDeep.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite,
                color: AppTheme.roseLight,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Domanda del Cuore',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.roseLight,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms),
        
        const SizedBox(height: 24),
        
        // Question card
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: AppTheme.primaryMedium.withValues(alpha: 0.3),
            ),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              Text(
                _currentQuestion.text,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
        
        const SizedBox(height: 32),
        
        // Answer input
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: AppTheme.primaryMedium.withValues(alpha: 0.3),
            ),
          ),
          child: TextField(
            controller: _answerController,
            focusNode: _answerFocusNode,
            maxLines: 4,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
            decoration: InputDecoration(
              hintText: 'Scrivi la tua risposta segreta...',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 600.ms, duration: 600.ms),
        
        const SizedBox(height: 12),
        
        // Privacy note
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              color: AppTheme.textMuted,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'La tua risposta resterà segreta fino alla rivelazione',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 700.ms, duration: 600.ms),
        
        const SizedBox(height: 32),
        
        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitAnswer,
            child: const Text('SIGILLA LA RISPOSTA'),
          ),
        )
            .animate()
            .fadeIn(delay: 800.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0),
        
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildWaitingSection() {
    return Column(
      children: [
        const SizedBox(height: 40),
        
        // Waiting animation
        Stack(
          alignment: Alignment.center,
          children: [
            const GlowingSigil(size: 120, animate: true),
            if (_partnerHasAnswered)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.5),
                    width: 3,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          ],
        ),
        
        const SizedBox(height: 40),
        
        Text(
          _partnerHasAnswered
              ? 'Entrambi avete risposto!'
              : 'In attesa del tuo partner...',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.goldLight,
              ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 600.ms),
        
        const SizedBox(height: 16),
        
        // Partner status
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: AppTheme.primaryMedium.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatusIndicator(
                    emoji: _currentUser.roleEmoji,
                    name: _currentUser.displayName,
                    hasAnswered: true,
                  ),
                  Text(
                    '&',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.goldPrimary,
                        ),
                  ),
                  _buildStatusIndicator(
                    emoji: _partner.roleEmoji,
                    name: _partner.displayName,
                    hasAnswered: _partnerHasAnswered,
                  ),
                ],
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms),
        
        const SizedBox(height: 32),
        
        if (!_partnerHasAnswered)
          Text(
            '${_partner.displayName} sta scrivendo...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
          )
              .animate(onPlay: (c) => c.repeat())
              .fadeIn(duration: 800.ms)
              .then()
              .fadeOut(duration: 800.ms),
        
        if (_partnerHasAnswered) ...[
          const MysticalDivider(width: 200),
          const SizedBox(height: 32),
          Text(
            '"Il Velo si apre..."',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.goldLight,
                  fontStyle: FontStyle.italic,
                ),
          )
              .animate()
              .fadeIn(duration: 800.ms),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _revealAnswers,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.visibility),
                const SizedBox(width: 12),
                const Text('SOLLEVA IL VELO'),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 600.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
        ],
        
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStatusIndicator({
    required String emoji,
    required String name,
    required bool hasAnswered,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceCard,
                border: Border.all(
                  color: hasAnswered
                      ? Colors.green.withValues(alpha: 0.5)
                      : AppTheme.primaryMedium.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            if (hasAnswered)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    border: Border.all(
                      color: AppTheme.surfaceCard,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
        ),
        Text(
          hasAnswered ? 'Risposto' : 'In attesa...',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: hasAnswered ? Colors.green : AppTheme.textMuted,
              ),
        ),
      ],
    );
  }

  Widget _buildRevealSection() {
    return AnimatedVeil(
      isRevealed: _isRevealing,
      duration: const Duration(milliseconds: 1800),
      onRevealComplete: () {},
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          if (_isRevealed) ...[
            // Revealed content
            Text(
              'Le vostre anime hanno parlato',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.goldLight,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 800.ms),
            
            const SizedBox(height: 32),
            
            // User's answer
            _buildRevealedAnswer(
              emoji: _currentUser.roleEmoji,
              name: _currentUser.displayName,
              answer: _userAnswer,
              delay: 400,
            ),
            
            const SizedBox(height: 20),
            
            // Divider with heart
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 1,
                  color: AppTheme.goldPrimary.withValues(alpha: 0.3),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    Icons.favorite,
                    color: AppTheme.roseDeep,
                    size: 20,
                  ),
                ),
                Container(
                  width: 60,
                  height: 1,
                  color: AppTheme.goldPrimary.withValues(alpha: 0.3),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 600.ms),
            
            const SizedBox(height: 20),
            
            // Partner's answer
            _buildRevealedAnswer(
              emoji: _partner.roleEmoji,
              name: _partner.displayName,
              answer: _partnerAnswer,
              delay: 900,
            ),
            
            const SizedBox(height: 40),
            
            // Continue button
            ElevatedButton(
              onPressed: _proceedToNextPhase,
              child: const Text('PROSEGUI AL PATTO'),
            )
                .animate()
                .fadeIn(delay: 1200.ms, duration: 600.ms),
            
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }

  Widget _buildRevealedAnswer({
    required String emoji,
    required String name,
    required String answer,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.goldPrimary.withValues(alpha: 0.3),
        ),
        boxShadow: AppTheme.subtleGlow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.goldLight,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"$answer"',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 800.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}
