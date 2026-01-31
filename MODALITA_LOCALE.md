# Tiger & Quokka - Modalità Locale e Cloud

## 🔒 Modalità Locale (Attuale)

L'app funziona attualmente in **modalità locale** perché Supabase non è stato configurato. Tutti i dati vengono salvati sul dispositivo usando SharedPreferences.

### Come funziona ora:
- ✅ **Login**: Funziona con utenti mock predefiniti
- ✅ **Rituali**: Progressione salvata localmente su ogni dispositivo
- ✅ **Serie Consecutiva**: Calcolata e salvata localmente
- ✅ **Statistiche**: Tutte le statistiche sono memorizzate sul dispositivo
- ❌ **Sincronizzazione**: I due partner NON vedono i dati l'uno dell'altro in tempo reale

### Utenti preconfigurati (modalità locale):
- **Tigre**: nick.busti@gmail.com / password: marynick
- **Quokka**: meperico@gmail.com / password: marynick

Questi account esistono solo localmente e non sono su Supabase.

---

## ☁️ Modalità Cloud (Da Configurare)

Per abilitare la sincronizzazione real-time tra i due partner, devi configurare Supabase.

### Vantaggi della modalità cloud:
- 🔄 **Sincronizzazione Real-Time**: Ogni azione è visibile istantaneamente su entrambi i dispositivi
- 👥 **Stato Partner Live**: Vedi quando il partner è online/offline
- 📊 **Dati Condivisi**: Progressione, armonia, streak sincronizzati automaticamente
- 🔒 **Backup Cloud**: I dati sono salvati sul cloud e non si perdono

### Come configurare Supabase:

1. **Crea un progetto su Supabase** (https://supabase.com)

2. **Ottieni le credenziali**:
   - Vai su Settings → API
   - Copia **Project URL** e **anon public key**

3. **Configura l'app**:
   - Apri `/lib/services/supabase_service.dart`
   - Sostituisci:
     ```dart
     static const String supabaseUrl = 'YOUR_SUPABASE_URL';
     static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
     ```
     Con i tuoi valori reali

4. **Crea il database**:
   - Segui le istruzioni in `/lib/supabase_setup.md`
   - Esegui lo script SQL nella console Supabase

5. **Registra nuovi account**:
   - Nell'app, vai su **Register**
   - Crea account reali per Tigre e Quokka
   - Collega i partner tramite email

---

## 🔄 Sistema Ibrido

L'app usa un sistema ibrido intelligente:
- Se Supabase è configurato → usa il cloud + real-time
- Se Supabase NON è configurato → usa SharedPreferences locali

Questo significa che:
- L'app funziona SEMPRE, con o senza Supabase
- Puoi testare localmente prima di configurare il cloud
- Non ci sono errori se Supabase non è settato

---

## ⚠️ Nota Importante

**NON SONO STATI CANCELLATI DATI DA SUPABASE** perché Supabase non era configurato quando hai fatto login.

Gli account che usavi prima (nick.busti@gmail.com e meperico@gmail.com) esistevano solo come utenti mock locali nell'app. Non c'è mai stata sincronizzazione con Supabase.

Se configuri Supabase ora, dovrai:
1. Registrare NUOVI account nell'app
2. Questi saranno salvati su Supabase
3. La sincronizzazione real-time partirà automaticamente

---

## 📱 Come Verificare la Modalità

Quando avvii l'app, nel console vedrai:
- **Modalità Locale**: "Supabase non configurato. L'app funzionerà in modalità locale."
- **Modalità Cloud**: Nessun messaggio (Supabase inizializzato correttamente)

---

## 🎯 Riepilogo

**Adesso**: L'app funziona perfettamente in modalità locale. Login con nick.busti@gmail.com e meperico@gmail.com funziona.

**Per sincronizzazione real-time**: Configura Supabase seguendo i passaggi sopra. L'app si adatterà automaticamente.
