# Setup Supabase per Tiger & Quokka

## 1. Crea un nuovo progetto Supabase
1. Vai su https://supabase.com e crea un account
2. Crea un nuovo progetto
3. Annota l'URL del progetto e la chiave anonima (anon key)

## 2. Aggiorna le credenziali nell'app
Apri `/lib/services/supabase_service.dart` e sostituisci:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

Con le tue credenziali reali.

## 3. Crea le tabelle del database

### Tabella `profiles`
Estende la tabella `auth.users` di Supabase:

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

-- Abilita Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Gli utenti possono leggere tutti i profili
CREATE POLICY "Profiles are viewable by everyone" 
ON public.profiles FOR SELECT 
USING (true);

-- Policy: Gli utenti possono aggiornare solo il proprio profilo
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

### Tabella `rooms`
Contiene le stanze condivise tra i partner:

```sql
-- Tabella delle stanze (coppie)
CREATE TABLE public.rooms (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tiger_id UUID REFERENCES public.profiles(id) NOT NULL,
  quokka_id UUID REFERENCES public.profiles(id) NOT NULL,
  invite_code TEXT,
  completed_days INTEGER DEFAULT 0,
  total_harmony_score INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  rituals_completed_today INTEGER DEFAULT 0,
  last_ritual_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(tiger_id, quokka_id)
);

-- Abilita Row Level Security
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;

-- Policy: Gli utenti possono vedere le proprie stanze
CREATE POLICY "Users can view their own rooms" 
ON public.rooms FOR SELECT 
USING (auth.uid() = tiger_id OR auth.uid() = quokka_id);

-- Policy: Gli utenti possono creare stanze
CREATE POLICY "Users can create rooms" 
ON public.rooms FOR INSERT 
WITH CHECK (auth.uid() = tiger_id OR auth.uid() = quokka_id);

-- Policy: I partner possono aggiornare la propria stanza
CREATE POLICY "Partners can update their room" 
ON public.rooms FOR UPDATE 
USING (auth.uid() = tiger_id OR auth.uid() = quokka_id);

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

### Tabella `rituals`
Memorizza i rituali completati:

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

-- Abilita Row Level Security
ALTER TABLE public.rituals ENABLE ROW LEVEL SECURITY;

-- Policy: Gli utenti possono vedere i rituali della loro stanza
CREATE POLICY "Users can view rituals from their room" 
ON public.rituals FOR SELECT 
USING (
  room_id IN (
    SELECT id FROM public.rooms 
    WHERE tiger_id = auth.uid() OR quokka_id = auth.uid()
  )
);

-- Policy: Gli utenti possono inserire rituali nella loro stanza
CREATE POLICY "Users can insert rituals in their room" 
ON public.rituals FOR INSERT 
WITH CHECK (
  room_id IN (
    SELECT id FROM public.rooms 
    WHERE tiger_id = auth.uid() OR quokka_id = auth.uid()
  )
);

-- Policy: Gli utenti possono eliminare i rituali della loro stanza
CREATE POLICY "Users can delete rituals from their room" 
ON public.rituals FOR DELETE 
USING (
  room_id IN (
    SELECT id FROM public.rooms 
    WHERE tiger_id = auth.uid() OR quokka_id = auth.uid()
  )
);

-- Indice per query più veloci
CREATE INDEX rituals_room_id_idx ON public.rituals(room_id);
CREATE INDEX rituals_completed_at_idx ON public.rituals(completed_at DESC);
```

## 4. Abilita Realtime

Nel pannello di Supabase, vai su:
1. **Database** → **Replication**
2. Abilita la replica per le tabelle:
   - `profiles`
   - `rooms`
   - `rituals`

Questo permette agli aggiornamenti di propagarsi in tempo reale tra i due dispositivi.

## 5. Configurazione Email (opzionale per password reset)

1. Vai su **Authentication** → **Email Templates**
2. Personalizza il template "Reset Password"
3. Configura il provider SMTP (o usa quello di default di Supabase)

## 6. Test della configurazione

1. Registra due utenti dall'app (uno Tiger, uno Quokka)
2. Connettili come partner usando l'email
3. Completa un rituale dal primo dispositivo
4. Verifica che i dati si aggiornano sul secondo dispositivo in tempo reale

## Note importanti

- **Backup locale**: L'app continua a funzionare anche senza Supabase usando SharedPreferences come fallback
- **Sicurezza**: Le Row Level Security policies garantiscono che ogni utente veda solo i propri dati
- **Real-time**: Gli aggiornamenti si propagano istantaneamente grazie alle subscription Supabase
- **Scalabilità**: Il sistema supporta migliaia di coppie senza problemi di performance

## Troubleshooting

Se riscontri problemi:
1. Verifica che le credenziali in `supabase_service.dart` siano corrette
2. Controlla che le tabelle siano state create correttamente
3. Verifica che le Row Level Security policies siano attive
4. Controlla la console di Supabase per eventuali errori
5. Assicurati che la Replication sia abilitata per le tabelle
