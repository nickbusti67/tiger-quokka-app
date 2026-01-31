import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'supabase_service.dart';

/// Servizio di autenticazione per gestire login, registrazione e ricerca partner
/// Ora integrato con Supabase per sincronizzazione real-time
class AuthService extends ChangeNotifier {
  final SupabaseService _supabaseService;
  
  User? _currentUser;
  User? _partner;
  final Map<String, User> _users = {};
  Timer? _onlineStatusTimer;
  StreamSubscription? _authSubscription;

  User? get currentUser => _currentUser;
  User? get partner => _partner;
  bool get isAuthenticated => _currentUser != null;
  bool get hasPartner => _partner != null;

  AuthService(this._supabaseService) {
    _initMockUsers();
    _initSupabase();
  }
  
  /// Inizializza Supabase solo se è configurato
  Future<void> _initSupabase() async {
    await _supabaseService.initialize();
    
    // Usa Supabase solo se è configurato e inizializzato
    if (_supabaseService.isConfigured && _supabaseService.isInitialized) {
      // Ascolta i cambiamenti di autenticazione
      _authSubscription = _supabaseService.authStateChanges.listen((authState) {
        _handleAuthStateChange(authState);
      });
      
      // Controlla se c'è già un utente loggato
      final supaUser = _supabaseService.currentUser;
      if (supaUser != null) {
        _syncUserFromSupabase(supaUser);
        return;
      }
    }
    
    // Modalità locale: avvia il timer per lo stato online mock
    _startOnlineStatusCheck();
  }

  // Mock password storage
  final Map<String, String> _passwords = {
    'nick.busti@gmail.com': 'marynick',
    'meperico@gmail.com': 'marynick',
  };

  /// Inizializza utenti mock per testing
  void _initMockUsers() {
    final tigre = User(
      id: '1',
      displayName: 'Nick',
      email: 'nick.busti@gmail.com',
      role: UserRole.tigre,
      isOnline: false,
      partnerId: '2',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    final quokka = User(
      id: '2',
      displayName: 'Mary',
      email: 'meperico@gmail.com',
      role: UserRole.quokka,
      isOnline: false,
      partnerId: '1',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    _users[tigre.email] = tigre;
    _users[quokka.email] = quokka;
  }

  /// Avvia il controllo periodico dello stato online
  void _startOnlineStatusCheck() {
    _onlineStatusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentUser != null && _partner != null) {
        // Simula aggiornamento stato partner
        _updatePartnerOnlineStatus();
        notifyListeners();
      }
    });
  }

  /// Aggiorna lo stato online del partner (mock)
  void _updatePartnerOnlineStatus() {
    if (_partner != null && _partner!.partnerId == _currentUser?.id) {
      // Simula partner online con probabilità del 70%
      final wasOnline = _partner!.isOnline;
      final isNowOnline = DateTime.now().second % 10 < 7;
      
      if (wasOnline != isNowOnline) {
        _partner = _partner!.copyWith(
          isOnline: isNowOnline,
          lastSeen: isNowOnline ? DateTime.now() : _partner!.lastSeen,
        );
      }
    }
  }

  /// Gestisce i cambiamenti dello stato di autenticazione
  void _handleAuthStateChange(authState) {
    if (authState.event == 'SIGNED_IN' && authState.session != null) {
      _syncUserFromSupabase(authState.session!.user);
    } else if (authState.event == 'SIGNED_OUT') {
      _currentUser = null;
      _partner = null;
      notifyListeners();
    }
  }
  
  /// Sincronizza l'utente da Supabase
  Future<void> _syncUserFromSupabase(supaUser) async {
    try {
      final userData = supaUser.userMetadata;
      final roleStr = userData?['role'] as String?;
      final role = roleStr == 'tigre' 
          ? UserRole.tigre 
          : UserRole.quokka;
      
      _currentUser = User(
        id: supaUser.id,
        displayName: userData?['display_name'] ?? 'Utente',
        email: supaUser.email ?? '',
        role: role,
        isOnline: true,
        lastSeen: DateTime.now(),
        createdAt: DateTime.parse(supaUser.createdAt),
      );
      
      // Aggiorna stato online su Supabase
      await _supabaseService.updateOnlineStatus(supaUser.id, true);
      
      // Carica partner e room
      await _loadPartnerFromSupabase();
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Errore sincronizzazione utente: $e');
      }
    }
  }
  
  /// Carica il partner da Supabase
  Future<void> _loadPartnerFromSupabase() async {
    if (_currentUser == null) return;
    
    try {
      final roomData = await _supabaseService.getCurrentRoom(_currentUser!.id);
      if (roomData != null) {
        // Determina quale è il partner
        final user1Data = roomData['user1'];
        final user2Data = roomData['user2'];
        
        // Il partner è user1 se io sono user2, e viceversa
        final partnerData = user1Data['id'] == _currentUser!.id 
            ? user2Data 
            : user1Data;
        
        if (partnerData != null) {
          _partner = User(
            id: partnerData['id'],
            displayName: partnerData['display_name'] ?? 'Partner',
            email: partnerData['email'] ?? '',
            role: partnerData['role'] == 'tigre' ? UserRole.tigre : UserRole.quokka,
            isOnline: partnerData['is_online'] ?? false,
            lastSeen: partnerData['last_seen'] != null 
                ? DateTime.parse(partnerData['last_seen'])
                : null,
            partnerId: _currentUser!.id,
            createdAt: DateTime.now(),
          );
          
          // Iscriviti agli aggiornamenti del partner
          await _supabaseService.subscribeToPartner(
            _partner!.id,
            _onPartnerUpdate,
          );
          
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Errore caricamento partner: $e');
      }
    }
  }
  
  /// Callback per aggiornamenti del partner
  void _onPartnerUpdate(Map<String, dynamic> partnerData) {
    if (_partner == null) return;
    
    _partner = _partner!.copyWith(
      isOnline: partnerData['is_online'] ?? false,
      lastSeen: partnerData['last_seen'] != null 
          ? DateTime.parse(partnerData['last_seen'])
          : null,
    );
    notifyListeners();
  }

  /// Login con email e password (usa Supabase se configurato, altrimenti mock locale)
  Future<bool> login(String email, String password) async {
    // Usa Supabase solo se è configurato e inizializzato
    if (_supabaseService.isConfigured && _supabaseService.isInitialized) {
      try {
        final response = await _supabaseService.signIn(email, password);
        if (response.session != null) {
          await _syncUserFromSupabase(response.user);
          return true;
        }
        return false;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Errore login Supabase: $e');
        }
        return false;
      }
    }
    
    // Modalità locale con utenti mock
    await Future.delayed(const Duration(seconds: 1));

    if (email.isEmpty || password.isEmpty) {
      return false;
    }

    final emailLower = email.toLowerCase();
    final user = _users[emailLower];
    if (user == null) {
      return false;
    }

    if (_passwords[emailLower] != password) {
      return false;
    }

    _currentUser = user.copyWith(
      isOnline: true,
      lastSeen: DateTime.now(),
    );
    _users[emailLower] = _currentUser!;

    await _loadPartner();
    _startOnlineStatusCheck();

    notifyListeners();
    return true;
  }

  /// Registra nuovo utente (usa Supabase se configurato, altrimenti mock locale)
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // Usa Supabase solo se è configurato e inizializzato
    if (_supabaseService.isConfigured && _supabaseService.isInitialized) {
      try {
        final response = await _supabaseService.signUp(
          email,
          password,
          displayName: name,
          role: role,
        );
        
        if (response.session != null) {
          await _syncUserFromSupabase(response.user);
          return true;
        }
        return false;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Errore registrazione Supabase: $e');
        }
        return false;
      }
    }
    
    // Modalità locale con utenti mock
    await Future.delayed(const Duration(seconds: 1));

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return false;
    }

    if (_users.containsKey(email.toLowerCase())) {
      return false;
    }

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      displayName: name,
      email: email.toLowerCase(),
      role: role,
      isOnline: true,
      lastSeen: DateTime.now(),
      createdAt: DateTime.now(),
    );

    _users[email.toLowerCase()] = newUser;
    _currentUser = newUser;
    _passwords[email.toLowerCase()] = password;

    notifyListeners();
    return true;
  }

  /// Cerca partner tramite email e crea collegamento
  Future<User?> searchAndConnectPartner(String partnerEmail) async {
    if (_currentUser == null) return null;
    
    // Usa Supabase solo se è configurato e inizializzato
    if (_supabaseService.isConfigured && _supabaseService.isInitialized) {
      try {
        final roomData = await _supabaseService.upsertRoom(
          userId: _currentUser!.id,
          partnerEmail: partnerEmail,
        );
        
        if (roomData != null) {
          await _loadPartnerFromSupabase();
          return _partner;
        }
        return null;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Errore connessione partner: $e');
        }
        // Propaga l'eccezione alla UI per mostrare il messaggio dettagliato
        rethrow;
      }
    }
    
    // Modalità locale: cerca partner nei dati mock
    await Future.delayed(const Duration(seconds: 1));

    final foundPartner = _users[partnerEmail.toLowerCase()];
    if (foundPartner == null) {
      return null;
    }

    if (foundPartner.role == _currentUser!.role) {
      return null;
    }

    if (foundPartner.partnerId != null && foundPartner.partnerId != _currentUser!.id) {
      return null;
    }

    _currentUser = _currentUser!.copyWith(partnerId: foundPartner.id);
    _users[_currentUser!.email] = _currentUser!;

    final updatedPartner = foundPartner.copyWith(partnerId: _currentUser!.id);
    _users[foundPartner.email] = updatedPartner;

    _partner = updatedPartner;
    notifyListeners();

    return updatedPartner;
  }

  /// Carica informazioni partner
  Future<void> _loadPartner() async {
    if (_currentUser?.partnerId == null) return;

    // Cerca partner nei dati mock
    final partnerId = _currentUser!.partnerId;
    _partner = _users.values.firstWhere(
      (user) => user.id == partnerId,
      orElse: () => User(
        id: partnerId!,
        displayName: 'Partner',
        email: 'unknown@partner.com',
        role: _currentUser!.role == UserRole.tigre 
            ? UserRole.quokka 
            : UserRole.tigre,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Logout
  Future<void> logout() async {
    // Usa Supabase solo se è configurato e inizializzato
    if (_supabaseService.isConfigured && _supabaseService.isInitialized && _currentUser != null) {
      try {
        await _supabaseService.updateOnlineStatus(_currentUser!.id, false);
        await _supabaseService.signOut();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Errore logout Supabase: $e');
        }
      }
    }
    
    // Cleanup locale
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        isOnline: false,
        lastSeen: DateTime.now(),
      );
      _users[_currentUser!.email] = _currentUser!;
    }

    _currentUser = null;
    _partner = null;
    notifyListeners();
  }

  /// Invia email di recupero password
  Future<bool> sendPasswordResetEmail(String email) async {
    // Usa Supabase solo se è configurato e inizializzato
    if (_supabaseService.isConfigured && _supabaseService.isInitialized) {
      try {
        await _supabaseService.resetPassword(email);
        return true;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Errore reset password Supabase: $e');
        }
        return false;
      }
    }
    
    // Modalità locale: reset password mock
    await Future.delayed(const Duration(seconds: 1));

    final emailLower = email.toLowerCase();

    if (!_users.containsKey(emailLower)) {
      return false;
    }

    _passwords[emailLower] = 'marynick';

    return true;
  }

  /// Reset password (usato dopo verifica email)
  Future<bool> resetPassword(String email, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));

    final emailLower = email.toLowerCase();

    if (!_users.containsKey(emailLower)) {
      return false;
    }

    _passwords[emailLower] = newPassword;
    return true;
  }

  @override
  void dispose() {
    _onlineStatusTimer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
