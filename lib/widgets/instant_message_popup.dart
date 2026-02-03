import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';

class InstantMessagePopup extends StatefulWidget {
  final String roomId;
  final VoidCallback onClose;

  const InstantMessagePopup({
    super.key,
    required this.roomId,
    required this.onClose,
  });

  @override
  State<InstantMessagePopup> createState() => _InstantMessagePopupState();
}

class _InstantMessagePopupState extends State<InstantMessagePopup> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subscribeToMessages();
  }

  void _subscribeToMessages() {
    final supabaseService = Provider.of<SupabaseService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUser?.id;

    if (supabaseService.isConfigured && supabaseService.isInitialized) {
      supabaseService.subscribeToInstantMessages(
        widget.roomId,
        (message) {
          // Mostra solo messaggi dall'altro partner
          if (message['sender_id'] != currentUserId) {
            setState(() {
              _messages.add(message);
            });
          }
        },
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUserId = authService.currentUser?.id;

      if (currentUserId == null) return;

      await supabaseService.sendInstantMessage(
        roomId: widget.roomId,
        senderId: currentUserId,
        message: _messageController.text.trim(),
      );

      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore invio messaggio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _closeAndClear() async {
    final supabaseService = Provider.of<SupabaseService>(context, listen: false);
    
    if (supabaseService.isConfigured && supabaseService.isInitialized) {
      await supabaseService.clearInstantMessages(widget.roomId);
    }
    
    widget.onClose();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.goldPrimary.withOpacity( 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.goldPrimary.withOpacity( 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.goldPrimary.withOpacity( 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.goldPrimary.withOpacity( 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.message_rounded,
                      color: AppTheme.goldPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Messaggio Istantaneo',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.goldLight,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'I messaggi scompaiono alla chiusura',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Messages area
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: AppTheme.textMuted.withOpacity( 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nessun messaggio ancora',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textMuted,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageBubble(message)
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: -0.2, end: 0);
                      },
                    ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.primaryMedium.withOpacity( 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLength: 100,
                      decoration: InputDecoration(
                        hintText: 'Scrivi un messaggio breve...',
                        hintStyle: TextStyle(
                          color: AppTheme.textMuted.withOpacity( 0.5),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppTheme.surfaceDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppTheme.primaryMedium.withOpacity( 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppTheme.primaryMedium.withOpacity( 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppTheme.goldPrimary,
                          ),
                        ),
                        counterStyle: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppTheme.goldPrimary),
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.goldPrimary,
                      foregroundColor: AppTheme.surfaceDark,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _closeAndClear,
                  icon: const Icon(Icons.close),
                  label: const Text('CHIUDI'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: BorderSide(
                      color: AppTheme.primaryMedium.withOpacity( 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .scale(duration: 300.ms, curve: Curves.easeOutBack)
          .fadeIn(),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isPartner = message['sender_id'] != authService.currentUser?.id;
    final partnerName = authService.partner?.displayName ?? 'Partner';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isPartner ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isPartner
                ? AppTheme.primaryMedium.withOpacity( 0.2)
                : AppTheme.goldPrimary.withOpacity( 0.2),
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomLeft: isPartner ? const Radius.circular(4) : null,
              bottomRight: !isPartner ? const Radius.circular(4) : null,
            ),
            border: Border.all(
              color: isPartner
                  ? AppTheme.primaryMedium.withOpacity( 0.3)
                  : AppTheme.goldPrimary.withOpacity( 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPartner)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    partnerName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.goldLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                  ),
                ),
              Text(
                message['message'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
