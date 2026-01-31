import 'package:flutter/material.dart';

enum UserRole { tigre, quokka }

enum RitualPhase { ilVelo, ilPatto, laProva, ilSigillo, completed }

enum CompatibilitySymbol { star, circle, triangle, raven }

enum QuestionCategory { heart, destiny, mind, body }

class User {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? roomId;
  final String? partnerId;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.roomId,
    this.partnerId,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    String? roomId,
    String? partnerId,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      roomId: roomId ?? this.roomId,
      partnerId: partnerId ?? this.partnerId,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get roleEmoji => role == UserRole.tigre ? '🐯' : '🦘';
  String get roleName => role == UserRole.tigre ? 'Tigre' : 'Quokka';
  String get roleDescription => role == UserRole.tigre 
      ? 'Intensità e protezione'
      : 'Luce e tenerezza';
}

class Room {
  final String id;
  final String inviteCode;
  final String? tigreUserId;
  final String? quokkaUserId;
  final bool isLocked;
  final bool intimacyMode;
  final bool figEndMode;
  final String timezone;
  final DateTime createdAt;
  final int completedDays; // 0-365
  final int totalHarmonyScore; // Punteggio armonia totale
  final DateTime? lastRitualDate; // Data ultimo rituale completato
  final int ritualsCompletedToday; // Contatore rituali giorno corrente
  final int currentStreak; // Giorni consecutivi di rituali completati

  const Room({
    required this.id,
    required this.inviteCode,
    this.tigreUserId,
    this.quokkaUserId,
    this.isLocked = false,
    this.intimacyMode = false,
    this.figEndMode = true,
    this.timezone = 'Europe/Rome',
    required this.createdAt,
    this.completedDays = 0,
    this.totalHarmonyScore = 0,
    this.lastRitualDate,
    this.ritualsCompletedToday = 0,
    this.currentStreak = 0,
  });

  bool get isFull => tigreUserId != null && quokkaUserId != null;
  bool get canDoRitual {
    final now = DateTime.now();
    if (lastRitualDate == null) return true;
    
    // Se è un giorno diverso, resetta
    if (lastRitualDate!.day != now.day || 
        lastRitualDate!.month != now.month ||
        lastRitualDate!.year != now.year) {
      return true;
    }
    
    // Se è lo stesso giorno, controlla il limite
    if (figEndMode && (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday)) {
      return ritualsCompletedToday < 2; // Fig-End: 2 rituali nel weekend
    }
    return ritualsCompletedToday < 1; // Normale: 1 rituale al giorno
  }
  
  int get remainingDays => 365 - completedDays;
  double get averageHarmony => completedDays > 0 ? totalHarmonyScore / completedDays : 0.0;
}

class DailyRitual {
  final String id;
  final String roomId;
  final DateTime date;
  final RitualPhase currentPhase;
  final bool isWeekendExtended;
  final VeloPhase? veloPhase;
  final PattoPhase? pattoPhase;
  final ProvaPhase? provaPhase;
  final SigilloPhase? sigilloPhase;
  final int? compatibilityPercentage;
  final CompatibilitySymbol? symbol;

  const DailyRitual({
    required this.id,
    required this.roomId,
    required this.date,
    required this.currentPhase,
    this.isWeekendExtended = false,
    this.veloPhase,
    this.pattoPhase,
    this.provaPhase,
    this.sigilloPhase,
    this.compatibilityPercentage,
    this.symbol,
  });

  String get phaseTitle {
    switch (currentPhase) {
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

  String get phaseSubtitle {
    switch (currentPhase) {
      case RitualPhase.ilVelo:
        return 'Risposte segrete e rivelazione simultanea';
      case RitualPhase.ilPatto:
        return 'Scelte di allineamento';
      case RitualPhase.laProva:
        return 'Una piccola sfida condivisa';
      case RitualPhase.ilSigillo:
        return 'Ricompensa narrativa e memoria';
      case RitualPhase.completed:
        return 'Il Codex ha registrato questo frammento';
    }
  }

  IconData get phaseIcon {
    switch (currentPhase) {
      case RitualPhase.ilVelo:
        return Icons.visibility_outlined;
      case RitualPhase.ilPatto:
        return Icons.handshake_outlined;
      case RitualPhase.laProva:
        return Icons.emoji_events_outlined;
      case RitualPhase.ilSigillo:
        return Icons.auto_awesome;
      case RitualPhase.completed:
        return Icons.check_circle_outline;
    }
  }
}

class VeloPhase {
  final String questionId;
  final String question;
  final QuestionCategory category;
  final String? tigreAnswer;
  final String? quokkaAnswer;
  final bool isRevealed;
  final DateTime? revealedAt;

  const VeloPhase({
    required this.questionId,
    required this.question,
    required this.category,
    this.tigreAnswer,
    this.quokkaAnswer,
    this.isRevealed = false,
    this.revealedAt,
  });

  bool get bothAnswered => tigreAnswer != null && quokkaAnswer != null;
}

class PattoPhase {
  final List<PactChoice> choices;
  final String? tigreSealWord;
  final String? quokkaSealWord;
  final bool isCompleted;

  const PattoPhase({
    required this.choices,
    this.tigreSealWord,
    this.quokkaSealWord,
    this.isCompleted = false,
  });
}

class PactChoice {
  final String id;
  final String optionA;
  final String optionB;
  final String? tigreChoice;
  final String? quokkaChoice;

  const PactChoice({
    required this.id,
    required this.optionA,
    required this.optionB,
    this.tigreChoice,
    this.quokkaChoice,
  });

  bool get isAligned => tigreChoice != null && 
      quokkaChoice != null && 
      tigreChoice == quokkaChoice;
}

class ProvaPhase {
  final String challengeId;
  final String challenge;
  final String? tigreSubmission;
  final String? quokkaSubmission;
  final bool isCompleted;

  const ProvaPhase({
    required this.challengeId,
    required this.challenge,
    this.tigreSubmission,
    this.quokkaSubmission,
    this.isCompleted = false,
  });
}

class SigilloPhase {
  final String codexEntry;
  final int compatibilityPercentage;
  final CompatibilitySymbol symbol;
  final DateTime createdAt;

  const SigilloPhase({
    required this.codexEntry,
    required this.compatibilityPercentage,
    required this.symbol,
    required this.createdAt,
  });
}

class RitualQuestion {
  final String id;
  final String text;
  final QuestionCategory category;
  final bool isSpicy;

  const RitualQuestion({
    required this.id,
    required this.text,
    required this.category,
    this.isSpicy = false,
  });
}

class RitualChallenge {
  final String id;
  final String text;
  final String type;
  final int intensity;

  const RitualChallenge({
    required this.id,
    required this.text,
    required this.type,
    this.intensity = 1,
  });
}

class CodexPage {
  final String id;
  final DateTime date;
  final String content;
  final int compatibilityPercentage;
  final CompatibilitySymbol symbol;
  final bool isUnlocked;

  const CodexPage({
    required this.id,
    required this.date,
    required this.content,
    required this.compatibilityPercentage,
    required this.symbol,
    this.isUnlocked = true,
  });
}

extension CompatibilitySymbolExtension on CompatibilitySymbol {
  String get emoji {
    switch (this) {
      case CompatibilitySymbol.star:
        return '⭐';
      case CompatibilitySymbol.circle:
        return '○';
      case CompatibilitySymbol.triangle:
        return '△';
      case CompatibilitySymbol.raven:
        return '🪶';
    }
  }

  String get name {
    switch (this) {
      case CompatibilitySymbol.star:
        return 'Stella';
      case CompatibilitySymbol.circle:
        return 'Cerchio';
      case CompatibilitySymbol.triangle:
        return 'Triangolo';
      case CompatibilitySymbol.raven:
        return 'Corvo';
    }
  }

  String get meaning {
    switch (this) {
      case CompatibilitySymbol.star:
        return 'Armonia perfetta';
      case CompatibilitySymbol.circle:
        return 'Connessione profonda';
      case CompatibilitySymbol.triangle:
        return 'Equilibrio dinamico';
      case CompatibilitySymbol.raven:
        return 'Tensione romantica';
    }
  }

  Color get color {
    switch (this) {
      case CompatibilitySymbol.star:
        return const Color(0xFFFFD700);
      case CompatibilitySymbol.circle:
        return const Color(0xFF4A90D9);
      case CompatibilitySymbol.triangle:
        return const Color(0xFF4AD991);
      case CompatibilitySymbol.raven:
        return const Color(0xFF9B59B6);
    }
  }
}
