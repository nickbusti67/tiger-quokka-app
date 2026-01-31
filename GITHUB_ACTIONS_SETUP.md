# 🚀 Guida GitHub Actions - Build APK Automatico

## ✅ COSA HO PREPARATO

Ho creato un workflow GitHub Actions che:
- ✅ Compila automaticamente l'APK ad ogni push
- ✅ Usa Android SDK 34 (disponibile su GitHub Actions)
- ✅ Salva l'APK come artifact scaricabile
- ✅ Crea release automatiche (opzionale)

---

## 📋 PASSAGGI PER ATTIVARE

### 1️⃣ CARICARE IL PROGETTO SU GITHUB

Se non hai ancora il progetto su GitHub:

1. Vai su **https://github.com/new**
2. Crea un nuovo repository (es: `tiger-quokka-app`)
3. **NON** inizializzare con README (il progetto lo ha già)
4. Copia i comandi mostrati e eseguili nella cartella del progetto:

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/TUO_USERNAME/tiger-quokka-app.git
git push -u origin main
```

---

### 2️⃣ ACCEDERE A GITHUB ACTIONS

Dopo il push, vai su:

```
https://github.com/TUO_USERNAME/tiger-quokka-app/actions
```

Vedrai il workflow **"Build Flutter APK"** in esecuzione! ⏳

---

### 3️⃣ SCARICARE L'APK

Una volta completato il build (circa 5-10 minuti):

1. Clicca sul workflow completato (✅ verde)
2. Scorri in basso fino a **"Artifacts"**
3. Clicca su **"Tiger-Quokka-APK-xxx"** per scaricare l'APK
4. Installa l'APK sul tuo telefono!

---

## 🎯 ESECUZIONE MANUALE

Puoi compilare l'APK anche manualmente:

1. Vai su **https://github.com/TUO_USERNAME/tiger-quokka-app/actions**
2. Clicca su **"Build Flutter APK"** (a sinistra)
3. Clicca su **"Run workflow"** (pulsante verde)
4. Seleziona il branch (main) e clicca **"Run workflow"**

---

## 📦 COME FUNZIONA

Il workflow:
1. ✅ Installa Java 17
2. ✅ Installa Flutter 3.24.5
3. ✅ Scarica le dipendenze (`flutter pub get`)
4. ✅ Compila l'APK (`flutter build apk --release`)
5. ✅ Salva l'APK come artifact scaricabile
6. ✅ (Opzionale) Crea una release con l'APK allegato

---

## 🔧 PERSONALIZZAZIONE

Puoi modificare il file `.github/workflows/build-apk.yml`:

- **Flutter version:** Cambia `flutter-version: '3.24.5'`
- **Build number:** Usa `${{ github.run_number }}` per auto-incremento
- **Branch:** Modifica `branches: [main, master]` per altri branch

---

## 🆘 RISOLUZIONE PROBLEMI

### ❌ Build fallito

Controlla i log del workflow su GitHub Actions per vedere l'errore specifico.

### ❌ Non trovo l'artifact

L'artifact appare solo se il build è completato con successo (✅ verde).

### ❌ APK non si installa

Abilita "Installa app sconosciute" nelle impostazioni Android.

---

## 🎉 VANTAGGI

✅ **Niente da installare** sul tuo PC  
✅ **Build automatici** ad ogni push  
✅ **Android SDK aggiornato** (34+)  
✅ **Completamente gratuito**  
✅ **Storico delle build** consultabile  

---

## 📱 PROSSIMI PASSI

1. Carica il progetto su GitHub
2. Vai su GitHub Actions
3. Aspetta il completamento del build
4. Scarica l'APK
5. Installa e testa! 🚀

---

**Link utili:**
- 📖 Documentazione GitHub Actions: https://docs.github.com/actions
- 🎯 Dashboard Actions: https://github.com/TUO_USERNAME/tiger-quokka-app/actions
- 📦 Releases: https://github.com/TUO_USERNAME/tiger-quokka-app/releases
