import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/models.dart';

/// Servizio per gestire la sincronizzazione real-time con Supabase
/// Tutti i dati di gioco sono condivisi tra i due partner
class SupabaseService extends ChangeNotifier {
  static const String supabaseUrl = 'https://bnbobdgauggywwviqzqu.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJuYm9iZGdhdWdneXd3dmlxenF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk1MDY5MjEsImV4cCI6MjA4NTA4MjkyMX0.cgrg6TgPh3eJVUbWYnzhYqFhtP2peMFzG91V333aRIg';
  
  SupabaseClient? _client;
  RealtimeChannel? _roomChannel;
  RealtimeChannel? _ritualChannel;
  
  Map<String, dynamic>? _cachedRoomData;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  /// Verifica se Supabase è configurato con credenziali reali
  bool get isConfigured {
    return supabaseUrl != 'YOUR_SUPABASE_URL' && 
           supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
           supabaseUrl.isNotEmpty && 
           supabaseAnonKey.isNotEmpty;
  }
  
  /// Inizializza Supabase solo se è configurato
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (!isConfigured) {
      if (kDebugMode) {
        debugPrint('Supabase non configurato. L\'app funzionerà in modalità locale.');
      }
      return;
    }
    
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Errore inizializzazione Supabase: $e');
      }
    }
  }
  
  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase non inizializzato. Chiama initialize() prima.');
    }
    return _client!;
  }
  
  /// Ottiene l'utente corrente autenticato
  supabase.User? get currentUser => _client?.auth.currentUser;
  
  /// Stream per ascoltare cambiamenti di autenticazione
  Stream<AuthState> get authStateChanges {
    return client.auth.onAuthStateChange;
  }
  
  /// Login con email e password
  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// Registrazione nuovo utente
  Future<AuthResponse> signUp(String email, String password, {
    required String displayName,
    required UserRole role,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'display_name': displayName,
        'role': role.name,
      },
    );
    return response;
  }
  
  /// Logout
  Future<void> signOut() async {
    await _unsubscribeFromChannels();
    await client.auth.signOut();
    _cachedRoomData = null;
    notifyListeners();
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }
  
  /// Crea o aggiorna la stanza condivisa con il partner
  Future<Map<String, dynamic>?> upsertRoom({
    required String userId,
    required String partnerEmail,
  }) async {
    try {
      // Cerca se esiste già una stanza con questo partner
      final response = await client
          .from('rooms')
          .select()
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .maybeSingle();
      
      if (response != null) {
        // Stanza già esistente
        return response;
      }
      
      // Cerca il partner tramite email (normalizzata)
      final normalizedEmail = partnerEmail.trim().toLowerCase();
      final partnerResponse = await client
          .from('profiles')
          .select()
          .eq('email', normalizedEmail)
          .maybeSingle();
      
      if (partnerResponse == null) {
        throw Exception('Partner non trovato. Email cercata: $normalizedEmail. Verifica che l\'email sia corretta e che l\'utente sia registrato.');
      }
      
      final partnerId = partnerResponse['id'] as String;
      
      // Verifica che l'utente non stia cercando di accoppiarsi con se stesso
      if (partnerId == userId) {
        throw Exception('Non puoi accoppiarti con te stesso!');
      }
      
      // Ottieni i ruoli di entrambi gli utenti
      final currentRole = await _getUserRole(userId);
      final partnerRole = await _getUserRole(partnerId);
      
      // Verifica che i ruoli siano diversi (Tiger-Quokka)
      if (currentRole == partnerRole) {
        throw Exception('I partner devono avere ruoli diversi! Un Tiger può accoppiarsi solo con un Quokka.');
      }
      
      // Verifica che l'utente corrente non sia già in una coppia
      final currentUserRoom = await client
          .from('rooms')
          .select()
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .maybeSingle();
      
      if (currentUserRoom != null) {
        throw Exception('Sei già collegato con un partner');
      }
      
      // Verifica che il partner non sia già in un'altra coppia
      final partnerRoom = await client
          .from('rooms')
          .select()
          .or('user1_id.eq.$partnerId,user2_id.eq.$partnerId')
          .maybeSingle();
      
      if (partnerRoom != null) {
        throw Exception('Il partner è già collegato con un altro utente');
      }
      
      // Crea nuova stanza con Tiger come user1 e Quokka come user2
      final newRoom = await client.from('rooms').insert({
        'user1_id': currentRole == UserRole.tigre ? userId : partnerId,
        'user2_id': currentRole == UserRole.tigre ? partnerId : userId,
        'completed_days': 0,
        'total_harmony_score': 0,
        'current_streak': 0,
        'rituals_completed_today': 0,
      }).select().single();
      
      return newRoom;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Errore creazione stanza: $e');
      }
      rethrow;
    }
  }
  
  /// Ottiene il ruolo dell'utente
  Future<UserRole> _getUserRole(String userId) async {
    final profile = await client
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();
    
    final roleString = (profile['role'] as String).toLowerCase();
    return roleString == 'tiger' || roleString == 'tigre' ? UserRole.tigre : UserRole.quokka;
  }
  
  /// Ottiene i dati della stanza corrente
  Future<Map<String, dynamic>?> getCurrentRoom(String userId) async {
    try {
      // Prima otteniamo i dati della room
      final roomResponse = await client
          .from('rooms')
          .select('*')
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .maybeSingle();
      
      if (roomResponse == null) {
        return null;
      }
      
      // Poi otteniamo i profili degli utenti separatamente
      final user1Id = roomResponse['user1_id'] as String?;
      final user2Id = roomResponse['user2_id'] as String?;
      
      Map<String, dynamic>? user1Data;
      Map<String, dynamic>? user2Data;
      
      if (user1Id != null) {
        try {
          user1Data = await client
              .from('profiles')
              .select('id, display_name, email, role, is_online, last_seen')
              .eq('id', user1Id)
              .maybeSingle();
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Errore recupero user1: $e');
          }
        }
      }
      
      if (user2Id != null) {
        try {
          user2Data = await client
              .from('profiles')
              .select('id, display_name, email, role, is_online, last_seen')
              .eq('id', user2Id)
              .maybeSingle();
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Errore recupero user2: $e');
          }
        }
      }
      
      // Combiniamo i dati
      final response = {
        ...roomResponse,
        'user1': user1Data,
        'user2': user2Data,
      };
      
      _cachedRoomData = response;
      notifyListeners();
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Errore recupero stanza: $e');
      }
      return null;
    }
  }
  
  /// Aggiorna lo stato online dell'utente
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await client.from('profiles').update({
        'is_online': isOnline,
        'last_seen': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Errore aggiornamento stato online: $e');
      }
    }
  }
  
  /// Iscriviti agli aggiornamenti real-time della stanza
  Future<void> subscribeToRoom(String roomId, Function(Map<String, dynamic>) onUpdate) async {
    await _unsubscribeFromChannels();
    
    _roomChannel = client
        .channel('room:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'rooms',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: roomId,
          ),
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              _cachedRoomData = payload.newRecord;
              onUpdate(_cachedRoomData!);
              notifyListeners();
            }
          },
        )
        .subscribe();
  }
  
  /// Iscriviti agli aggiornamenti real-time dei profili partner
  Future<void> subscribeToPartner(String partnerId, Function(Map<String, dynamic>) onUpdate) async {
    client
        .channel('profile:$partnerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: partnerId,
          ),
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              onUpdate(payload.newRecord);
            }
          },
        )
        .subscribe();
  }
  
  /// Completa un rituale giornaliero
  Future<void> completeRitual({
    required String roomId,
    required int harmonyScore,
    required String category,
    required Map<String, dynamic> answers,
  }) async {
    try {
      // Ottiene i dati correnti
      final room = await client
          .from('rooms')
          .select()
          .eq('id', roomId)
          .single();
      
      final completedDays = (room['completed_days'] ?? 0) as int;
      final totalHarmony = (room['total_harmony_score'] ?? 0) as int;
      final ritualsToday = (room['rituals_completed_today'] ?? 0) as int;
      final lastRitualDate = room['last_ritual_date'] as String?;
      final currentStreak = (room['current_streak'] ?? 0) as int;
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      DateTime? lastDate;
      if (lastRitualDate != null) {
        lastDate = DateTime.parse(lastRitualDate);
        lastDate = DateTime(lastDate.year, lastDate.month, lastDate.day);
      }
      
      // Calcola nuovo streak
      int newStreak = currentStreak;
      if (lastDate == null) {
        newStreak = 1;
      } else {
        final difference = today.difference(lastDate).inDays;
        if (difference == 1) {
          newStreak = currentStreak + 1;
        } else if (difference > 1) {
          newStreak = 1;
        }
        // Se difference == 0, mantiene lo streak corrente
      }
      
      // Aggiorna la stanza
      final updates = {
        'completed_days': completedDays + 1,
        'total_harmony_score': totalHarmony + harmonyScore,
        'rituals_completed_today': lastDate == today ? ritualsToday + 1 : 1,
        'last_ritual_date': now.toIso8601String(),
        'current_streak': newStreak,
        'updated_at': now.toIso8601String(),
      };
      
      await client
          .from('rooms')
          .update(updates)
          .eq('id', roomId);
      
      // Salva il rituale completato
      await client.from('rituals').insert({
        'room_id': roomId,
        'category': category,
        'harmony_score': harmonyScore,
        'answers': answers,
        'completed_at': now.toIso8601String(),
      });
      
      _cachedRoomData = {...?_cachedRoomData, ...updates};
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Errore completamento rituale: $e');
      }
      rethrow;
    }
  }
  
  /// Reset del viaggio
  Future<void> resetJourney(String roomId) async {
    try {
      await client.from('rooms').update({
        'completed_days': 0,
        'total_harmony_score': 0,
        'current_streak': 0,
        'rituals_completed_today': 0,
        'last_ritual_date': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', roomId);
      
      // Elimina tutti i rituali completati (Codex)
      await client
          .from('rituals')
          .delete()
          .eq('room_id', roomId);
      
      // Elimina tutti i codex salvati
      await client
          .from('codex_pages')
          .delete()
          .eq('room_id', roomId);
      
      // Pulisce cache locale
      if (_cachedRoomData != null) {
        _cachedRoomData = {
          ..._cachedRoomData!,
          'completed_days': 0,
          'total_harmony_score': 0,
          'current_streak': 0,
          'rituals_completed_today': 0,
          'last_ritual_date': null,
        };
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Errore reset viaggio: $e');
      }
      rethrow;
    }
  }
  
  /// Invia un messaggio istantaneo effimero
  Future<void> sendInstantMessage({
    required String roomId,
    required String senderId,
    required String message,
  }) async {
    try {
      await client.from('instant_messages').insert({
        'room_id': roomId,
        'sender_id': senderId,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Errore invio messaggio: $e');
      }
      rethrow;
    }
  }
  
  /// Iscriviti ai messaggi istantanei
  Future<void> subscribeToInstantMessages(
    String roomId, 
    Function(Map<String, dynamic>) onMessage,
  ) async {
    client
        .channel('instant_messages:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'instant_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              onMessage(payload.newRecord);
            }
          },
        )
        .subscribe();
  }
  
  /// Cancella tutti i messaggi istantanei della room
  Future<void> clearInstantMessages(String roomId) async {
    try {
      await client
          .from('instant_messages')
          .delete()
          .eq('room_id', roomId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Errore cancellazione messaggi: $e');
      }
    }
  }
  
  /// Ottiene le statistiche della stanza
  Future<Map<String, dynamic>> getStatistics(String roomId) async {
    final room = await client
        .from('rooms')
        .select()
        .eq('id', roomId)
        .single();
    
    final completedDays = (room['completed_days'] ?? 0) as int;
    final totalHarmony = (room['total_harmony_score'] ?? 0) as int;
    final currentStreak = (room['current_streak'] ?? 0) as int;
    
    // Conta le pagine del Codex
    final ritualCount = await client
        .from('rituals')
        .select('id')
        .eq('room_id', roomId)
        .count(CountOption.exact);
    
    final codexPages = ritualCount.count;
    final averageHarmony = completedDays > 0 
        ? (totalHarmony / completedDays).round() 
        : 0;
    
    return {
      'completedDays': completedDays,
      'totalDays': 365,
      'averageHarmony': averageHarmony,
      'codexPages': codexPages,
      'streak': currentStreak,
    };
  }
  
  /// Unsubscribe da tutti i canali
  Future<void> _unsubscribeFromChannels() async {
    if (_roomChannel != null) {
      await client.removeChannel(_roomChannel!);
      _roomChannel = null;
    }
    if (_ritualChannel != null) {
      await client.removeChannel(_ritualChannel!);
      _ritualChannel = null;
    }
  }
  
  @override
  void dispose() {
    _unsubscribeFromChannels();
    super.dispose();
  }
}
