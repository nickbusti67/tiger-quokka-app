import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';
import '../services/ritual_service.dart';
import '../utils/responsive_layout.dart';
import '../widgets/glowing_sigil.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveLayout.getPadding(context),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveLayout.getMaxContentWidth(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 24),
                  _buildIntimacySection()
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms),
                  const SizedBox(height: 20),
                  _buildFigEndSection()
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 600.ms),
                  const SizedBox(height: 20),
                  _buildNotificationsSection()
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms),
                  const SizedBox(height: 32),
                  _buildDangerZone()
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 600.ms),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.goldShimmer,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.glowShadow,
              ),
              child: const Icon(
                Icons.settings,
                color: AppTheme.primaryDark,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Impostazioni',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.goldLight,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personalizza la tua esperienza',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntimacySection() {
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        return SettingsCard(
          icon: Icons.favorite,
          iconColor: AppTheme.roseDeep,
          title: 'Modalità Intimità',
          subtitle: 'Attiva contenuti e domande più profonde e speziate',
          child: Column(
            children: [
              const MysticalDivider(width: double.infinity),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.intimacyMode ? 'Attiva' : 'Disattiva',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: settings.intimacyMode
                                        ? AppTheme.roseDeep
                                        : AppTheme.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          settings.intimacyMode
                              ? 'Le domande includeranno contenuti più intimi e personali'
                              : 'Verranno proposte solo domande standard',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  MysticalSwitch(
                    value: settings.intimacyMode,
                    onChanged: settings.setIntimacyMode,
                    activeColor: AppTheme.roseDeep,
                  ),
                ],
              ),
              if (settings.intimacyMode) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.roseDeep.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: AppTheme.roseDeep.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.roseDeep,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'I contenuti hot sono pensati per coppie che vogliono esplorare un livello più profondo di connessione.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFigEndSection() {
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        return SettingsCard(
          icon: Icons.calendar_today,
          iconColor: AppTheme.teal,
          title: 'Modalità Fig-End',
          subtitle: 'Rituali estesi durante i fine settimana',
          child: Column(
            children: [
              const MysticalDivider(width: double.infinity),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.figEndMode ? 'Attiva' : 'Disattiva',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: settings.figEndMode
                                        ? AppTheme.teal
                                        : AppTheme.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          settings.figEndMode
                              ? 'Nei weekend avrai più tempo per completare i rituali'
                              : 'I rituali seguiranno sempre la stessa tempistica',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  MysticalSwitch(
                    value: settings.figEndMode,
                    onChanged: settings.setFigEndMode,
                    activeColor: AppTheme.teal,
                  ),
                ],
              ),
              if (settings.figEndMode) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: AppTheme.teal.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppTheme.teal,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Durante venerdì, sabato e domenica avrai fino alle 23:59 di domenica per completare il rituale.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationsSection() {
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        return SettingsCard(
          icon: Icons.notifications,
          iconColor: AppTheme.goldPrimary,
          title: 'Notifiche',
          subtitle: 'Gestisci i promemoria e gli avvisi',
          child: Column(
            children: [
              const MysticalDivider(width: double.infinity),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifiche Generali',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          settings.notificationsEnabled
                              ? 'Riceverai notifiche dall\'app'
                              : 'Tutte le notifiche sono disattivate',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  MysticalSwitch(
                    value: settings.notificationsEnabled,
                    onChanged: settings.setNotificationsEnabled,
                    activeColor: AppTheme.goldPrimary,
                  ),
                ],
              ),
              if (settings.notificationsEnabled) ...[
                const SizedBox(height: 20),
                NotificationOption(
                  icon: Icons.auto_awesome,
                  label: 'Rituali Giornalieri',
                  description: 'Promemoria per completare il rituale',
                  value: settings.ritualNotifications,
                  onChanged: settings.setRitualNotifications,
                ),
                const SizedBox(height: 12),
                NotificationOption(
                  icon: Icons.favorite_border,
                  label: 'Attività Partner',
                  description: 'Quando il partner completa una fase',
                  value: settings.partnerNotifications,
                  onChanged: settings.setPartnerNotifications,
                ),
                const SizedBox(height: 12),
                NotificationOption(
                  icon: Icons.menu_book,
                  label: 'Nuove Pagine Codex',
                  description: 'Quando viene sbloccata una nuova memoria',
                  value: settings.codexNotifications,
                  onChanged: settings.setCodexNotifications,
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () => _selectReminderTime(context, settings),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDeep.withOpacity(0.3),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: AppTheme.goldPrimary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.goldPrimary.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: const Icon(
                            Icons.schedule,
                            color: AppTheme.goldPrimary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Orario Promemoria',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ti ricorderemo di fare il rituale',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textMuted,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSmall),
                            border: Border.all(
                              color: AppTheme.goldPrimary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _formatTime(settings.dailyReminderTime),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppTheme.goldLight,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.edit,
                                color: AppTheme.goldPrimary.withOpacity(0.7),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sezione Reset Viaggio
        Row(
          children: [
            const Icon(
              Icons.restart_alt,
              color: AppTheme.teal,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Gestione Viaggio',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.teal,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: AppTheme.teal.withOpacity(0.3),
            ),
          ),
          child: InkWell(
            onTap: () => _showResetJourneyDialog(context),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryDeep.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.teal.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.refresh,
                    color: AppTheme.teal,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Azzera e Ricomincia',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Cancella tutta la progressione e ricomincia da zero',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.textMuted.withOpacity(0.5),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Zona Pericolosa
        Row(
          children: [
            const Icon(
              Icons.warning_amber,
              color: AppTheme.roseDeep,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Zona Pericolosa',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.roseDeep,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: AppTheme.roseDeep.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _showLogoutConfirmation(context),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDeep.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: AppTheme.textMuted.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Esci dall\'account',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Potrai rientrare in qualsiasi momento',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.textMuted.withOpacity(0.5),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _showEndRelationshipConfirmation(context),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.roseDeep.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: AppTheme.roseDeep.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.heart_broken,
                        color: AppTheme.roseDeep,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Termina la relazione',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: AppTheme.roseDeep,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Questa azione è irreversibile',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.roseDeep.withOpacity(0.5),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _selectReminderTime(
      BuildContext context, SettingsService settings) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: settings.dailyReminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.goldPrimary,
              onPrimary: AppTheme.primaryDark,
              surface: AppTheme.surfaceCard,
              onSurface: AppTheme.textPrimary,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.surfaceCard,
              hourMinuteTextColor: AppTheme.textPrimary,
              dayPeriodTextColor: AppTheme.textPrimary,
              dialHandColor: AppTheme.goldPrimary,
              dialBackgroundColor: AppTheme.primaryDeep,
              hourMinuteColor: AppTheme.primaryDeep,
              dayPeriodColor: AppTheme.primaryDeep,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await settings.setDailyReminderTime(picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showResetJourneyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MysticalDialog(
        icon: Icons.restart_alt,
        iconColor: AppTheme.teal,
        title: 'Azzera Viaggio',
        description:
            'Sei sicuro di voler cancellare TUTTA la progressione? Questa azione è IRREVERSIBILE e cancellerà:\n\n• Tutti i rituali completati\n• Il punteggio di armonia totale\n• Le pagine del Codex\n• Tutte le statistiche\n\nIl vostro viaggio ricomincerà dal Giorno 1.',
        primaryButtonText: 'Conferma Reset',
        secondaryButtonText: 'Annulla',
        isPrimaryDangerous: true,
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          _showFinalResetConfirmation(context);
        },
        onSecondaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showFinalResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MysticalDialog(
        icon: Icons.delete_forever,
        iconColor: AppTheme.roseDeep,
        title: 'ULTIMA CONFERMA',
        description:
            'Questa è l\'ultima opportunità per annullare.\n\nVuoi DAVVERO cancellare tutto il vostro viaggio insieme? Non potrai recuperare nulla.',
        primaryButtonText: 'SÌ, CANCELLA TUTTO',
        secondaryButtonText: 'No, Mantieni',
        isPrimaryDangerous: true,
        onPrimaryPressed: () async {
          final authService = context.read<AuthService>();
          final ritualService = context.read<RitualService>();
          
          final currentUser = authService.currentUser;
          if (currentUser != null) {
            final room = await ritualService.getCurrentRoom(userId: currentUser.id);
            await ritualService.resetJourney(roomId: room.id);
          }

          if (!context.mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✨ Viaggio resettato. Ricominciate dal Giorno 1!'),
              backgroundColor: AppTheme.goldPrimary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onSecondaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MysticalDialog(
        icon: Icons.logout,
        iconColor: AppTheme.textSecondary,
        title: 'Conferma uscita',
        description:
            'Sei sicuro di voler uscire dal tuo account? Potrai rientrare in qualsiasi momento con le tue credenziali.',
        primaryButtonText: 'Esci',
        secondaryButtonText: 'Annulla',
        onPrimaryPressed: () async {
          final authService = context.read<AuthService>();
          await authService.logout();
          if (!context.mounted) return;
          Navigator.of(context).pop();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
        onSecondaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showEndRelationshipConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MysticalDialog(
        icon: Icons.heart_broken,
        iconColor: AppTheme.roseDeep,
        title: 'Termina la relazione',
        description:
            'Questa azione eliminerà permanentemente tutti i rituali, le memorie del Codex e il collegamento con il tuo partner. Questa operazione NON può essere annullata.',
        primaryButtonText: 'Termina',
        secondaryButtonText: 'Annulla',
        isPrimaryDangerous: true,
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          _showFinalWarning(context);
        },
        onSecondaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showFinalWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MysticalDialog(
        icon: Icons.warning_amber,
        iconColor: AppTheme.roseDeep,
        title: 'Ultima conferma',
        description:
            'Stai per eliminare TUTTI i dati condivisi con il tuo partner. Vuoi davvero procedere?',
        primaryButtonText: 'Sì, elimina tutto',
        secondaryButtonText: 'No, torna indietro',
        isPrimaryDangerous: true,
        onPrimaryPressed: () async {
          final authService = context.read<AuthService>();
          await authService.logout();
          if (!context.mounted) return;
          Navigator.of(context).pop();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La relazione è stata terminata'),
              backgroundColor: AppTheme.roseDeep,
            ),
          );
        },
        onSecondaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget child;

  const SettingsCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.primaryMedium.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: iconColor.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class NotificationOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool value;
  final Function(bool) onChanged;

  const NotificationOption({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryDeep.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: value
              ? AppTheme.goldPrimary.withOpacity(0.3)
              : AppTheme.primaryMedium.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? AppTheme.goldPrimary : AppTheme.textMuted,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          MysticalSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.goldPrimary,
          ),
        ],
      ),
    );
  }
}

class MysticalSwitch extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;
  final Color activeColor;

  const MysticalSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = AppTheme.goldPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          color: value
              ? activeColor.withOpacity(0.3)
              : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: value ? activeColor : AppTheme.primaryMedium.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? activeColor : AppTheme.textMuted,
              shape: BoxShape.circle,
              boxShadow: [
                if (value)
                  BoxShadow(
                    color: activeColor.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MysticalDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;
  final bool isPrimaryDangerous;

  const MysticalDialog({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
    this.isPrimaryDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: iconColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withOpacity(0.3),
                ),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.goldLight,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSecondaryPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: BorderSide(
                        color: AppTheme.primaryMedium.withOpacity(0.3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    child: Text(secondaryButtonText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPrimaryPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPrimaryDangerous
                          ? AppTheme.roseDeep
                          : AppTheme.goldPrimary,
                      foregroundColor: isPrimaryDangerous
                          ? Colors.white
                          : AppTheme.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    child: Text(
                      primaryButtonText,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
