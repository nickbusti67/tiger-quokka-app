import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../models/models.dart';
import '../services/ritual_service.dart';
import '../services/auth_service.dart';
import '../widgets/glowing_sigil.dart';
import '../widgets/ritual_card.dart';
import '../widgets/instant_message_popup.dart';
import '../utils/responsive_layout.dart';
import 'ritual_flow_screen.dart';
import 'codex_screen.dart';
import 'settings_screen.dart';

class RitualDashboardScreen extends StatefulWidget {
  const RitualDashboardScreen({super.key});

  @override
  State<RitualDashboardScreen> createState() => _RitualDashboardScreenState();
}

class _RitualDashboardScreenState extends State<RitualDashboardScreen>
    with SingleTickerProviderStateMixin {
  DailyRitual? _currentRitual;
  Room? _currentRoom;
  Map<String, dynamic>? _statistics;
  int _selectedNavIndex = 0;
  String? _currentRoomId;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupRealtimeSubscription();
  }

  Future<void> _loadData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final ritualService = Provider.of<RitualService>(context, listen: false);
    
    final currentUser = authService.currentUser;
    _currentRitual = ritualService.getCurrentRitual();
    _currentRoom = await ritualService.getCurrentRoom(userId: currentUser?.id);
    _currentRoomId = _currentRoom?.id;
    _statistics = await ritualService.getStatistics(roomId: _currentRoomId);
    
    if (mounted) {
      setState(() {});
    }
  }
  
  Future<void> _setupRealtimeSubscription() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final ritualService = Provider.of<RitualService>(context, listen: false);
    
    final currentUser = authService.currentUser;
    try {
      final room = await ritualService.getCurrentRoom(userId: currentUser?.id);
      await ritualService.subscribeToRoom(room.id, () {
        _loadData();
      });
    } catch (e) {
      // Gestisce errori di connessione
      if (kDebugMode) {
        debugPrint('Errore setup subscription: $e');
      }
    }
  }

  void _navigateToRitualFlow() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RitualFlowScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
    // Ricarica i dati dopo il completamento del rituale
    await _loadData();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buongiorno';
    if (hour < 18) return 'Buon pomeriggio';
    return 'Buonasera';
  }

  String _getDateString() {
    final now = DateTime.now();
    final weekdays = [
      'Lunedì',
      'Martedì',
      'Mercoledì',
      'Giovedì',
      'Venerdì',
      'Sabato',
      'Domenica'
    ];
    final months = [
      'Gennaio',
      'Febbraio',
      'Marzo',
      'Aprile',
      'Maggio',
      'Giugno',
      'Luglio',
      'Agosto',
      'Settembre',
      'Ottobre',
      'Novembre',
      'Dicembre'
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
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

          // Subtle particles
          const Positioned.fill(
            child: FloatingParticles(
              particleCount: 15,
              color: AppTheme.goldPrimary,
              maxSize: 2,
            ),
          ),

          // Main content based on navigation
          SafeArea(
            child: IndexedStack(
              index: _selectedNavIndex,
              children: [
                _buildDashboardContent(),
                const CodexScreen(),
                const SettingsScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDashboardContent() {
    final isMobile = ResponsiveLayout.isMobileLayout(context);
    final spacing = ResponsiveLayout.getSpacing(context);

    return SingleChildScrollView(
      padding: ResponsiveLayout.getPadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveLayout.getMaxContentWidth(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),

              SizedBox(height: spacing * 1.5),

              // Partner status cards
              _buildPartnerSection()
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms),

              SizedBox(height: spacing * 1.5),

              // Today's ritual card
              _buildTodayRitualCard()
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

              SizedBox(height: spacing * 1.5),

              // Ritual phases
              _buildPhasesSection()
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms),

              SizedBox(height: spacing * 1.5),

              // Statistics
              _buildStatisticsSection()
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 600.ms),

              SizedBox(height: isMobile ? 80 : 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final currentUser = authService.currentUser;
        if (currentUser == null) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          currentUser.roleEmoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currentUser.displayName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.goldLight,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: AppTheme.primaryMedium.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_currentRoom?.currentStreak ?? 0} ${(_currentRoom?.currentStreak ?? 0) == 1 ? 'giorno' : 'giorni'}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getDateString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    letterSpacing: 1,
                  ),
            ),
          ],
        );
      },
    );
  }

  void _openInstantMessage() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final roomId = authService.currentUser?.roomId;
    
    if (roomId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InstantMessagePopup(
        roomId: roomId,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildPartnerSection() {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final currentUser = authService.currentUser;
        final partner = authService.partner;
        final bool isPartnerOnline = partner?.isOnline ?? false;
        
        if (currentUser == null) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: AppTheme.roseDeep,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'I Custodi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.goldLight,
                      ),
                ),
                const Spacer(),
                if (partner != null && isPartnerOnline)
                  IconButton(
                    onPressed: _openInstantMessage,
                    icon: const Icon(Icons.message_rounded),
                    tooltip: 'Messaggio Istantaneo',
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.goldPrimary.withValues(alpha: 0.2),
                      foregroundColor: AppTheme.goldLight,
                      padding: const EdgeInsets.all(8),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 2000.ms,
                        color: AppTheme.goldPrimary.withValues(alpha: 0.3),
                      ),
              ],
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: PartnerStatusCard(
                      user: currentUser,
                      isOnline: true,
                      hasAnswered: false,
                      statusText: 'Tu',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: partner != null
                        ? PartnerStatusCard(
                            user: partner,
                            isOnline: partner.isOnline,
                            hasAnswered: false,
                            statusText: partner.isOnline 
                                ? 'Online' 
                                : 'Offline • ${_formatLastSeen(partner.lastSeen)}',
                          )
                        : _buildNoPartnerCard(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoPartnerCard() {
    return GestureDetector(
      onTap: _showSearchPartnerDialog,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.primaryMedium.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              color: AppTheme.goldPrimary.withValues(alpha: 0.5),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Nessun partner',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.goldPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.goldPrimary.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search,
                    color: AppTheme.goldPrimary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Cerca',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.goldPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchPartnerDialog() {
    final partnerEmailController = TextEditingController();
    String? errorMessage;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: AppTheme.goldPrimary.withValues(alpha: 0.3),
              ),
            ),
            title: Column(
              children: [
                const GlowingSigil(size: 60),
                const SizedBox(height: 16),
                Text(
                  'Trova la Tua Anima',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.goldPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Inserisci l\'email del tuo partner per creare il legame',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: partnerEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                  decoration: InputDecoration(
                    labelText: 'Email del Partner',
                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    filled: true,
                    fillColor: AppTheme.surfaceDark.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.goldPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.goldPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.goldPrimary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.favorite_outline,
                      color: AppTheme.goldPrimary,
                    ),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.roseDeep.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.roseDeep.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.roseLight,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'Annulla',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (partnerEmailController.text.isEmpty) {
                          setDialogState(() {
                            errorMessage = 'Inserisci un\'email valida';
                          });
                          return;
                        }

                        setDialogState(() {
                          isLoading = true;
                          errorMessage = null;
                        });

                        final authService = Provider.of<AuthService>(
                          context,
                          listen: false,
                        );
                        final partner =
                            await authService.searchAndConnectPartner(
                          partnerEmailController.text.trim(),
                        );

                        if (!mounted) return;

                        if (partner != null) {
                          Navigator.of(dialogContext).pop();
                          await _showPartnerFoundDialog(partner);
                          await _loadData();
                        } else {
                          setDialogState(() {
                            isLoading = false;
                            errorMessage =
                                'Partner non trovato o già in coppia';
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldPrimary,
                  foregroundColor: AppTheme.primaryDeep,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryDeep,
                          ),
                        ),
                      )
                    : Text(
                        'Cerca',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppTheme.primaryDeep,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showPartnerFoundDialog(User partner) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppTheme.goldPrimary.withValues(alpha: 0.3),
          ),
        ),
        title: Column(
          children: [
            const GlowingSigil(size: 60),
            const SizedBox(height: 16),
            Text(
              'Il Legame è Completo',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.goldPrimary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hai trovato ${partner.displayName}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              partner.roleEmoji,
              style: const TextStyle(fontSize: 32),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Siete ora anime connesse.\nIl vostro rituale quotidiano può iniziare.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldPrimary,
              foregroundColor: AppTheme.primaryDeep,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Inizia il Rituale',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.primaryDeep,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'mai';
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inMinutes < 1) return 'ora';
    if (diff.inHours < 1) return '${diff.inMinutes}min fa';
    if (diff.inDays < 1) return '${diff.inHours}h fa';
    return '${diff.inDays}g fa';
  }

  Widget _buildTodayRitualCard() {
    final isWeekend = _currentRitual?.isWeekendExtended ?? false;
    final canDoRitual = _currentRoom?.canDoRitual ?? true;
    final ritualsToday = _currentRoom?.ritualsCompletedToday ?? 0;
    final maxRituals = (_currentRoom?.figEndMode ?? false) && isWeekend ? 2 : 1;

    return GestureDetector(
      onTap: canDoRitual ? _navigateToRitualFlow : null,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryDeep,
              AppTheme.primaryMedium.withValues(alpha: 0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: AppTheme.goldPrimary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: AppTheme.glowShadow,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isWeekend)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.goldPrimary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.goldPrimary.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: AppTheme.goldPrimary,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Rito Lungo Fig-End',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.goldPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        canDoRitual ? 'Il Rituale di Oggi' : 'Rituale Completato',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppTheme.goldLight,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        canDoRitual 
                            ? 'Il Velo attende di essere sollevato...'
                            : 'Torna domani per un nuovo rituale ($ritualsToday/$maxRituals oggi)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ),
                const GlowingSigil(
                  size: 80,
                  animate: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const MysticalDivider(width: double.infinity),
            const SizedBox(height: 20),
            if (canDoRitual)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldShimmer,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.goldPrimary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'INIZIA IL RITUALE',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppTheme.primaryDark,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.arrow_forward,
                          color: AppTheme.primaryDark,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: AppTheme.textMuted.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.goldPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rituale completato per oggi',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhasesSection() {
    final currentPhase = _currentRitual?.currentPhase ?? RitualPhase.ilVelo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.timeline,
              color: AppTheme.goldPrimary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Le Fasi del Rituale',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.goldLight,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...RitualPhase.values
            .where((p) => p != RitualPhase.completed)
            .map((phase) {
          final isActive = phase == currentPhase;
          final isCompleted = phase.index < currentPhase.index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RitualPhaseCard(
              phase: phase,
              isActive: isActive,
              isCompleted: isCompleted,
              onTap: isActive ? _navigateToRitualFlow : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    if (_statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.insights,
              color: AppTheme.goldPrimary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Il Vostro Viaggio (365 Giorni)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.goldLight,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Barra di progressione
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: AppTheme.primaryMedium.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progressione Viaggio',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.goldLight,
                        ),
                  ),
                  Text(
                    '${_statistics!['totalRituals']}/365 giorni',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_statistics!['totalRituals'] as int) / 365,
                  minHeight: 12,
                  backgroundColor: AppTheme.surfaceDark,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.goldPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mancano ${_statistics!['remainingDays']} giorni al completamento',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMuted,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatisticTile(
                  label: 'Armonia\nMedia',
                  value: '${_statistics!['averageCompatibility']}%',
                  icon: Icons.favorite,
                  color: AppTheme.roseDeep,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatisticTile(
                  label: 'Serie\nAttuale',
                  value: '${_statistics!['streak']}',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatisticTile(
                  label: 'Pagine\nCodex',
                  value: '${_statistics!['totalCodexPages']}',
                  icon: Icons.menu_book,
                  color: AppTheme.teal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryMedium.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Rituale'),
              _buildNavItem(1, Icons.menu_book_outlined, Icons.menu_book, 'Codex'),
              _buildNavItem(
                  2, Icons.settings_outlined, Icons.settings, 'Impostazioni'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.goldPrimary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.goldPrimary : AppTheme.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.goldPrimary : AppTheme.textMuted,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
