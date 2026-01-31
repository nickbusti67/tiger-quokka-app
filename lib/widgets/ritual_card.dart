import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/models.dart';
import 'glowing_sigil.dart';

class RitualPhaseCard extends StatelessWidget {
  final RitualPhase phase;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onTap;

  const RitualPhaseCard({
    super.key,
    required this.phase,
    this.isActive = false,
    this.isCompleted = false,
    this.onTap,
  });

  String get _title {
    switch (phase) {
      case RitualPhase.ilVelo:
        return 'Il Velo';
      case RitualPhase.ilPatto:
        return 'Il Patto';
      case RitualPhase.laProva:
        return 'La Prova';
      case RitualPhase.ilSigillo:
        return 'Il Sigillo';
      case RitualPhase.completed:
        return 'Completo';
    }
  }

  String get _subtitle {
    switch (phase) {
      case RitualPhase.ilVelo:
        return 'Risposte segrete';
      case RitualPhase.ilPatto:
        return 'Scelte di allineamento';
      case RitualPhase.laProva:
        return 'Sfida condivisa';
      case RitualPhase.ilSigillo:
        return 'Memoria eterna';
      case RitualPhase.completed:
        return 'Rituale completato';
    }
  }

  IconData get _icon {
    switch (phase) {
      case RitualPhase.ilVelo:
        return Icons.visibility_outlined;
      case RitualPhase.ilPatto:
        return Icons.handshake_outlined;
      case RitualPhase.laProva:
        return Icons.emoji_events_outlined;
      case RitualPhase.ilSigillo:
        return Icons.auto_awesome;
      case RitualPhase.completed:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppTheme.goldPrimary
        : isCompleted
            ? AppTheme.goldLight.withValues(alpha: 0.6)
            : AppTheme.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.surfaceCard
              : AppTheme.surfaceCard.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isActive
                ? AppTheme.goldPrimary.withValues(alpha: 0.5)
                : AppTheme.primaryMedium.withValues(alpha: 0.2),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive ? AppTheme.subtleGlow : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : _icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color.withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ),
            if (isActive)
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.goldPrimary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

class PartnerStatusCard extends StatelessWidget {
  final User user;
  final bool isOnline;
  final bool hasAnswered;
  final String? statusText;

  const PartnerStatusCard({
    super.key,
    required this.user,
    this.isOnline = true,
    this.hasAnswered = false,
    this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.primaryMedium.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: user.role == UserRole.tigre
                        ? [const Color(0xFFFF8C00), const Color(0xFFFF4500)]
                        : [const Color(0xFF8B4513), const Color(0xFF654321)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (user.role == UserRole.tigre
                              ? const Color(0xFFFF8C00)
                              : const Color(0xFF8B4513))
                          .withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user.roleEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline ? Colors.green : Colors.grey,
                    border: Border.all(
                      color: AppTheme.surfaceCard,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.roleName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.goldLight,
                      ),
                ),
                if (statusText != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (hasAnswered)
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.green.shade400,
                        )
                      else
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.goldPrimary.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        statusText!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textMuted,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CodexPageCard extends StatelessWidget {
  final CodexPage page;
  final VoidCallback? onTap;

  const CodexPageCard({
    super.key,
    required this.page,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${page.date.day}/${page.date.month}/${page.date.year}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: page.symbol.color.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: page.symbol.color.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      page.symbol.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.goldLight,
                              ),
                        ),
                        Text(
                          page.symbol.meaning,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: page.symbol.color,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: page.symbol.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: page.symbol.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${page.compatibilityPercentage}%',
                    style: TextStyle(
                      color: page.symbol.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const MysticalDivider(width: double.infinity),
            const SizedBox(height: 16),
            Text(
              page.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class StatisticTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const StatisticTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppTheme.goldPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: tileColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: tileColor,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: tileColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMuted,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
