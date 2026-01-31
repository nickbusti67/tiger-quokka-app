import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../models/models.dart';
import '../services/ritual_service.dart';
import '../widgets/glowing_sigil.dart';
import '../widgets/ritual_card.dart';
import '../utils/responsive_layout.dart';

class CodexScreen extends StatefulWidget {
  const CodexScreen({super.key});

  @override
  State<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends State<CodexScreen> {
  late List<CodexPage> _pages;

  @override
  void initState() {
    super.initState();
    final ritualService = Provider.of<RitualService>(context, listen: false);
    _pages = ritualService.getCodexPages();
  }

  void _showPageDetail(CodexPage page) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildPageDetailSheet(page),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              _buildHeader()
                  .animate()
                  .fadeIn(duration: 600.ms),
              
              const SizedBox(height: 24),
              
              _buildSymbolLegend()
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms),
              
              const SizedBox(height: 24),
              
              _buildPagesList(),
              
              const SizedBox(height: 80),
            ],
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
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.goldPrimary.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.menu_book,
                color: AppTheme.goldPrimary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Il Codex',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppTheme.goldLight,
                      ),
                ),
                Text(
                  'La memoria del vostro amore',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: AppTheme.primaryMedium.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.auto_stories,
                color: AppTheme.goldLight,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ogni pagina racconta un frammento della vostra storia.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSymbolLegend() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            'I Simboli Sacri',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.goldLight,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: CompatibilitySymbol.values.map((symbol) {
              return _buildSymbolItem(symbol);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolItem(CompatibilitySymbol symbol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: symbol.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: symbol.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(symbol.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            symbol.meaning,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: symbol.color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.history,
              color: AppTheme.goldPrimary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Pagine Recenti',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.goldLight,
                  ),
            ),
            const Spacer(),
            Text(
              '${_pages.length} pagine',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(_pages.length, (index) {
          final page = _pages[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CodexPageCard(
              page: page,
              onTap: () => _showPageDetail(page),
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 300 + (index * 100)),
                  duration: 600.ms,
                )
                .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
          );
        }),
      ],
    );
  }

  Widget _buildPageDetailSheet(CodexPage page) {
    final dateStr = '${page.date.day}/${page.date.month}/${page.date.year}';
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: page.symbol.color.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlowingSigil(
                      symbol: page.symbol,
                      size: 80,
                      showPercentage: true,
                      percentage: page.compatibilityPercentage,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.goldLight,
                      ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  page.symbol.meaning,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: page.symbol.color,
                      ),
                ),
                
                const SizedBox(height: 24),
                
                const MysticalDivider(width: 200),
                
                const SizedBox(height: 24),
                
                // Content
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: AppTheme.primaryMedium.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    page.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontStyle: FontStyle.italic,
                          height: 1.8,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CHIUDI'),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
