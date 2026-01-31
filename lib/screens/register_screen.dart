import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../theme/theme.dart';
import '../widgets/glowing_sigil.dart';
import 'ritual_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _partnerEmailController = TextEditingController();
  
  UserRole? _selectedRole;
  bool _isLoading = false;
  bool _isRegistered = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _partnerEmailController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_selectedRole == null) {
      setState(() {
        _errorMessage = 'Seleziona il tuo spirito animale';
      });
      return;
    }

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Compila tutti i campi';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = context.read<AuthService>();
    final success = await authService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole!,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      setState(() {
        _isRegistered = true;
      });
    } else {
      setState(() {
        _errorMessage = 'Email già registrata o dati non validi';
      });
    }
  }

  Future<void> _searchPartner() async {
    if (_partnerEmailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Inserisci l\'email del tuo partner';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = context.read<AuthService>();
    User? partner;
    String? errorDetail;
    
    try {
      partner = await authService.searchAndConnectPartner(
        _partnerEmailController.text.trim(),
      );
    } catch (e) {
      errorDetail = e.toString();
      if (errorDetail.startsWith('Exception: ')) {
        errorDetail = errorDetail.substring(11); // Rimuovi "Exception: "
      }
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (partner != null) {
      // Mostra dialogo di conferma
      await _showPartnerFoundDialog(partner);
    } else {
      setState(() {
        _errorMessage = errorDetail ?? 'Partner non trovato o già in coppia con qualcun altro';
      });
    }
  }

  Future<void> _showPartnerFoundDialog(User partner) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.goldPrimary.withOpacity(0.3)),
        ),
        title: Column(
          children: [
            const GlowingSigil(
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Il Legame è Completo',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.goldPrimary,
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
              style: GoogleFonts.raleway(
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              partner.role == UserRole.tigre ? '🐯 Tigre' : '🦘 Quokka',
              style: const TextStyle(fontSize: 32),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Siete ora anime connesse.\nIl vostro rituale quotidiano può iniziare.',
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const RitualDashboardScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldPrimary,
              foregroundColor: AppTheme.primaryDeep,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Inizia il Rituale',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.goldPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryDeep,
              AppTheme.primaryDark,
              AppTheme.surfaceDark,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Titolo
                Text(
                  _isRegistered ? 'Trova la Tua Anima' : 'Crea il Tuo Legame',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldPrimary,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms).slideY(
                  begin: -0.2,
                  end: 0,
                  duration: 600.ms,
                ),

                const SizedBox(height: 32),

                if (!_isRegistered) ..._buildRegistrationForm() else ..._buildPartnerSearchForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRegistrationForm() {
    return [
      // Selezione Ruolo
      Text(
        'Scegli il tuo spirito',
        style: GoogleFonts.raleway(
          fontSize: 14,
          color: AppTheme.textSecondary,
          letterSpacing: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),

      Row(
        children: [
          Expanded(
            child: _RoleCard(
              role: UserRole.tigre,
              name: 'Tigre',
              emoji: '🐯',
              isSelected: _selectedRole == UserRole.tigre,
              onTap: () {
                setState(() {
                  _selectedRole = UserRole.tigre;
                  _errorMessage = null;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _RoleCard(
              role: UserRole.quokka,
              name: 'Quokka',
              emoji: '🦘',
              isSelected: _selectedRole == UserRole.quokka,
              onTap: () {
                setState(() {
                  _selectedRole = UserRole.quokka;
                  _errorMessage = null;
                });
              },
            ),
          ),
        ],
      ),

      const SizedBox(height: 32),

      // Nome
      TextField(
        controller: _nameController,
        style: GoogleFonts.raleway(color: AppTheme.textPrimary),
        decoration: _inputDecoration('Nome', Icons.person_outline),
      ),

      const SizedBox(height: 16),

      // Email
      TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: GoogleFonts.raleway(color: AppTheme.textPrimary),
        decoration: _inputDecoration('Email', Icons.email_outlined),
      ),

      const SizedBox(height: 16),

      // Password
      TextField(
        controller: _passwordController,
        obscureText: true,
        style: GoogleFonts.raleway(color: AppTheme.textPrimary),
        decoration: _inputDecoration('Password', Icons.lock_outline),
      ),

      if (_errorMessage != null) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.roseDeep.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.roseDeep.withOpacity(0.5)),
          ),
          child: Text(
            _errorMessage!,
            style: GoogleFonts.raleway(
              color: AppTheme.roseLight,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],

      const SizedBox(height: 32),

      // Pulsante Registrazione
      ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldPrimary,
          foregroundColor: AppTheme.primaryDeep,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryDeep),
                ),
              )
            : Text(
                'Crea Account',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    ];
  }

  List<Widget> _buildPartnerSearchForm() {
    return [
      // Icona
      const Center(
        child: GlowingSigil(
          size: 80,
        ),
      ),
      const SizedBox(height: 24),

      Text(
        'Per completare il rituale, cerca la tua anima gemella tramite email.',
        style: GoogleFonts.raleway(
          fontSize: 14,
          color: AppTheme.textSecondary,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),

      const SizedBox(height: 32),

      // Email Partner
      TextField(
        controller: _partnerEmailController,
        keyboardType: TextInputType.emailAddress,
        style: GoogleFonts.raleway(color: AppTheme.textPrimary),
        decoration: _inputDecoration('Email del Partner', Icons.favorite_outline),
      ),

      if (_errorMessage != null) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.roseDeep.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.roseDeep.withOpacity(0.5)),
          ),
          child: Text(
            _errorMessage!,
            style: GoogleFonts.raleway(
              color: AppTheme.roseLight,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],

      const SizedBox(height: 32),

      // Pulsante Cerca
      ElevatedButton(
        onPressed: _isLoading ? null : _searchPartner,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldPrimary,
          foregroundColor: AppTheme.primaryDeep,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryDeep),
                ),
              )
            : Text(
                'Cerca Partner',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),

      const SizedBox(height: 24),

      // Saltare per ora
      TextButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const RitualDashboardScreen(),
            ),
          );
        },
        child: Text(
          'Continua senza partner (per ora)',
          style: GoogleFonts.raleway(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    ];
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.raleway(color: AppTheme.textSecondary),
      filled: true,
      fillColor: AppTheme.surfaceCard.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.goldPrimary.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.goldPrimary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.goldPrimary, width: 2),
      ),
      prefixIcon: Icon(icon, color: AppTheme.goldPrimary),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final String name;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.name,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppTheme.goldPrimary.withOpacity(0.3),
                    AppTheme.goldPrimary.withOpacity(0.1),
                  ]
                : [
                    AppTheme.surfaceCard.withOpacity(0.5),
                    AppTheme.surfaceCard.withOpacity(0.3),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.goldPrimary
                : AppTheme.goldPrimary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.goldPrimary.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.goldPrimary : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
