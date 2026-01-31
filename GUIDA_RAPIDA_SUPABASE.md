# 🚀 Guida Rapida: Setup Database Supabase

## ✅ Credenziali già configurate

Le credenziali Supabase sono già state inserite nell'app:
- **URL**: `https://mibediorqrcdtzvtmbvk.supabase.co`
- **API Key**: Configurata ✓

## 📋 Passi successivi per attivare la sincronizzazione

### 1. Accedi a Supabase
Vai su [https://supabase.com/dashboard](https://supabase.com/dashboard) e accedi al tuo progetto.

### 2. Crea le tabelle del database
Nel pannello **SQL Editor** di Supabase, esegui questi 5 script (nell'ordine):

#### Script 1: Tabella Profiles
```sql
-- Tabella profili utenti
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('tigre', 'quokka')),
  is_online BOOLEAN DEFAULT false,
  last_seen TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles are viewable by everyone" 
ON public.profiles FOR SELECT 
USING (true);

CREATE POLICY "Users can update their own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

-- Trigger per creare automaticamente il profilo alla registrazione
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', 'User'),
    COALESCE(NEW.raw_user_meta_data->>'role', 'tigre')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

#### Script 2: Tabella Rooms
```sql
-- Tabella delle stanze (coppie)
CREATE TABLE public.rooms (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user1_id UUID REFERENCES public.profiles(id) NOT NULL,
  user2_id UUID REFERENCES public.profiles(id) NOT NULL,
  invite_code TEXT,
  completed_days INTEGER DEFAULT 0,
  total_harmony_score INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  rituals_completed_today INTEGER DEFAULT 0,
  last_ritual_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user1_id, user2_id)
);

ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own rooms" 
ON public.rooms FOR SELECT 
USING (auth.uid() = user1_id OR auth.uid() = user2_id);

CREATE POLICY "Users can create rooms" 
ON public.rooms FOR INSERT 
WITH CHECK (auth.uid() = user1_id OR auth.uid() = user2_id);

CREATE POLICY "Partners can update their room" 
ON public.rooms FOR UPDATE 
USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Trigger per aggiornare updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rooms_updated_at
  BEFORE UPDATE ON public.rooms
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
```

#### Script 3: Tabella Rituals
```sql
-- Tabella dei rituali completati
CREATE TABLE public.rituals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id UUID REFERENCES public.rooms(id) ON DELETE CASCADE NOT NULL,
  category TEXT NOT NULL,
  harmony_score INTEGER NOT NULL,
  answers JSONB DEFAULT '{}',
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.rituals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view rituals from their room" 
ON public.rituals FOR SELECT 
USING (
  room_id IN (
    SELECT id FROM public.rooms 
    WHERE user1_id = auth.uid() OR user2_id = auth.uid()
  )
);

CREATE POLICY "Users can insert rituals in their room" 
ON public.rituals FOR INSERT 
WITH CHECK (
  room_id IN (
    SELECT id FROM public.rooms 
    WHERE user1_id = auth.uid() OR user2_id = auth.uid()
  )
);

CREATE POLICY "Users can delete rituals from their room" 
ON public.rituals FOR DELETE 
USING (
  room_id IN (
    SELECT id FROM public.rooms 
    WHERE user1_id = auth.uid() OR user2_id = auth.uid()
  )
);

CREATE INDEX rituals_room_id_idx ON public.rituals(room_id);
CREATE INDEX rituals_completed_at_idx ON public.rituals(completed_at DESC);
```

#### Script 4: Tabella Codex Pages
```sql
-- Tabella delle pagine del Codex
CREATE TABLE public.codex_pages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id UUID REFERENCES public.rooms(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  compatibility_percentage INTEGER NOT NULL,
  symbol TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.codex_pages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view codex from their room" 
ON public.codex_pages FOR SELECT 
USING (
  room_id IN (
    SELECT id FROM public.rooms 
    WHERE user1_id = auth.uid() OR user2_id = auth.uid()
  )
);

CREATE POLICY "Users can insert codex in their room" 
ON public.codex_pages FOR INSERT 
WITH CHECK (
  room_id IN (
    SELECT id FROM public.rooms 
    WHERE user1_id = auth.uid() OR user2_id = auth.uid()
  )
);

CREATE POLICY "Users can delete codex from their room" 
ON public.codex_pages FOR DELETE 
USING (
  room_id IN (
    SELECT id FROM public.rooms 
    WHERE user1_id = auth.uid() OR user2_id = auth.uid()
  )
);

CREATE INDEX codex_pages_room_id_idx ON public.codex_pages(room_id);
CREATE INDEX codex_pages_date_idx ON public.codex_pages(date DESC);
```

#### Script 5: Tabella Instant Messages (Messaggi Effimeri)
```sql
-- Tabella per messaggi istantanei (effimeri, vengono cancellati alla chiusura)
CREATE TABLE public.instant_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id UUID REFERENCES public.rooms(id) ON DELETE CASCADE NOT NULL,
  sender_id UUID REFERENCES public.profiles(id) NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.instant_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view messages from their room" 
ON public.instant_messages FOR SELECT 
USING (
  room_id IN (
    SELECT id FROM public.rooms 
    WHERE user1_id = auth.uid() OR user2_id = auth.uid()
  )
);

CREATE POLICY "Users can insert messages in their room" 
ON public.instant_messages FOR INSERT 
WITH CHECK (
  room_id IN (
    SELECT id FROM public.rooms 
    WHERE user1_id = auth.uid() OR user2_id = auth.uid()
  )
);

CREATE POLICY "Users can delete messages from their room" 
ON public.instant_messages FOR DELETE 
USING (
  room_id IN (
    SELECT id FROM public.rooms 
    WHERE user1_id = auth.uid() OR user2_id = auth.uid()
  )
);

CREATE INDEX instant_messages_room_id_idx ON public.instant_messages(room_id);
CREATE INDEX instant_messages_created_at_idx ON public.instant_messages(created_at DESC);
```

### 3. Script di Verifica Database (ESEGUI PER PRIMO SE HAI PROBLEMI)
Se ricevi l'errore "Partner non trovato", esegui PRIMA questo script per verificare i dati:

```sql
-- 🔍 VERIFICA 1: Controlla se gli utenti hanno l'email salvata
SELECT id, email, display_name, role, is_online, created_at
FROM public.profiles
ORDER BY created_at DESC;

-- 🔍 VERIFICA 2: Controlla se ci sono room duplicate o problemi
SELECT user1_id, user2_id, created_at, COUNT(*) as count
FROM public.rooms
GROUP BY user1_id, user2_id, created_at
HAVING COUNT(*) > 1;

-- 🔍 VERIFICA 3: Mostra tutte le email normalizzate (per debug)
SELECT 
  id, 
  email,
  LOWER(TRIM(email)) as email_normalizzata,
  display_name,
  role,
  is_online
FROM public.profiles
ORDER BY created_at DESC;

-- 🔍 VERIFICA 4: Controlla se l'email esiste in auth.users ma non in profiles
SELECT u.id, u.email, p.email as profile_email
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
WHERE p.email IS NULL OR p.email = '';
```

**Cosa controllare:**
- ✅ Se "VERIFICA 1" mostra email NULL o vuote → Esegui lo Script di Fix qui sotto
- ✅ Se "VERIFICA 3" mostra email con maiuscole/minuscole diverse → Normale, il codice normalizza automaticamente
- ✅ Se "VERIFICA 4" mostra risultati → Esegui lo Script di Fix per sincronizzare i dati

### 4. Script di Fix (ESEGUI SOLO SE LA VERIFICA MOSTRA PROBLEMI)
Se le verifiche sopra mostrano email NULL o mancanti, esegui questo script:

```sql
-- Aggiungi la colonna email se non esiste
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS email TEXT;

-- Popola la colonna email dai dati di auth.users
UPDATE public.profiles p
SET email = u.email
FROM auth.users u
WHERE p.id = u.id AND p.email IS NULL;

-- Rendi la colonna UNIQUE e NOT NULL
ALTER TABLE public.profiles 
ALTER COLUMN email SET NOT NULL;

ALTER TABLE public.profiles 
ADD CONSTRAINT profiles_email_unique UNIQUE (email);
```

### 5. Abilita Realtime (sincronizzazione istantanea)
1. Vai su **Database** → **Publications** (non Replication!)
2. Clicca su **supabase_realtime**
3. Abilita queste 5 tabelle:
   - ✅ `profiles`
   - ✅ `rooms`
   - ✅ `rituals`
   - ✅ `codex_pages`
   - ✅ `instant_messages` (per messaggistica in tempo reale)

### 6. Test finale
1. **Registra due account dall'app** (uno Tiger 🐯, uno Quokka 🦘)
2. **Connettili come partner** usando l'email del partner
3. **Completa un rituale** dal primo smartphone
4. **Verifica** che i dati si aggiornano istantaneamente sul secondo smartphone ✨

## 🎉 Fatto!

Ora entrambi gli smartphone:
- ✅ Sincronizzano i dati in tempo reale
- ✅ Vedono lo stato online/offline del partner
- ✅ Vedono lo streak aggiornato istantaneamente
- ✅ Condividono lo stesso viaggio di 365 giorni
- ✅ Possono inviarsi messaggi istantanei quando entrambi online
- ✅ Il reset del viaggio cancella anche tutti i codex salvati

## 🔧 Note importanti

### Dati locali esistenti
Gli account `nick.busti@gmail.com` e `meperico@gmail.com` che hai usato finora sono **solo locali**. Quando abiliti Supabase:
- Dovrai **registrarti di nuovo** dall'app
- Gli account Supabase saranno nuovi e indipendenti
- I dati locali rimarranno sul dispositivo ma non saranno sincronizzati

### Modalità ibrida
L'app funziona sempre, anche senza connessione:
- Con Supabase configurato: sincronizzazione cloud + fallback locale
- Senza Supabase: solo dati locali (come ora)

### Sicurezza
- Le password sono gestite da Supabase (encryption automatico)
- Ogni coppia vede solo i propri dati
- Le Row Level Security policies proteggono la privacy

## 📱 Per installare su entrambi gli smartphone

1. **Compila l'app** con le credenziali Supabase già configurate
2. **Installa su entrambi i dispositivi**
3. **Registra** un account su ciascun dispositivo (Tiger su uno, Quokka sull'altro)
4. **Connetti** i due account usando l'email del partner
5. **Inizia** il vostro viaggio condiviso! 🚀

## ❓ Problemi?

Se qualcosa non funziona:
1. Verifica che tutti e 5 gli script SQL (+ Script di Fix) siano stati eseguiti correttamente
2. Controlla che il Realtime sia abilitato in **Publications** → **supabase_realtime** per le 5 tabelle
3. Se la ricerca partner non funziona, esegui lo **Script di Fix** (punto 3)
4. Verifica la connessione internet su entrambi gli smartphone
5. Riavvia l'app dopo la registrazione

---

**Per dettagli tecnici completi**, vedi `/lib/supabase_setup.md`
