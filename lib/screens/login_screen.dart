import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../theme/theme.dart';
import '../widgets/glowing_sigil.dart';
import 'register_screen.dart';
import 'ritual_dashboard_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole? _selectedRole;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_selectedRole == null) {
      setState(() {
        _errorMessage = 'Seleziona il tuo spirito animale';
      });
      return;
    }

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Inserisci email e password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = context.read<AuthService>();
    final success = await authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Verifica che il ruolo corrisponda
      if (authService.currentUser?.role != _selectedRole) {
        setState(() {
          _errorMessage = 'Questo account appartiene a ${authService.currentUser?.role == UserRole.tigre ? "Tigre" : "Quokka"}';
        });
        await authService.logout();
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const RitualDashboardScreen(),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Email o password non corretti';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const SizedBox(height: 40),
                
                // Logo/Titolo
                const GlowingSigil(
                  size: 80,
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Il Rituale delle\nAnime Connesse',
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

                const SizedBox(height: 48),

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
                        subtitle: 'Intensità e Protezione',
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
                        subtitle: 'Luce e Tenerezza',
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

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.raleway(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.goldPrimary),
                  ),
                ),

                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: GoogleFonts.raleway(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                    prefixIcon: Icon(Icons.lock_outline, color: AppTheme.goldPrimary),
                  ),
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

                // Pulsante Login
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
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
                          'Entra nel Rituale',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                // Link password dimenticata
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Password dimenticata?',
                    style: GoogleFonts.raleway(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Link registrazione
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.raleway(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                      children: [
                        const TextSpan(text: 'Prima volta? '),
                        TextSpan(
                          text: 'Crea il tuo legame',
                          style: TextStyle(
                            color: AppTheme.goldPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final String name;
  final String subtitle;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.name,
    required this.subtitle,
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
        padding: const EdgeInsets.all(16),
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.goldPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.raleway(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
