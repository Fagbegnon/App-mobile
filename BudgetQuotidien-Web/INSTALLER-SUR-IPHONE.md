# 📲 Installer Budget Quotidien sur ton iPhone

Ton app fonctionne sans Mac, sans compte Apple et sans argent : c'est une
**PWA** (application web installable). Voici les 2 méthodes.

---

## ✅ Méthode 1 — Test rapide via le Wi-Fi (2 minutes)

> Ton iPhone et ton PC Windows doivent être sur le **même Wi-Fi**.

### Sur le PC
1. Ouvre un terminal dans le dossier `BudgetQuotidien-Web`.
2. Lance :
   ```
   node serve.js
   ```
3. Note l'adresse **« Réseau »** affichée, par exemple :
   `http://192.168.1.15:8080`

### Sur l'iPhone
4. Ouvre **Safari** (obligatoire, pas Chrome).
5. Tape l'adresse Réseau (ex. `http://192.168.1.15:8080`).
6. L'app s'ouvre 🎉. Pour l'installer sur l'écran d'accueil :
   - Touche le bouton **Partager** (le carré avec la flèche ↑, en bas).
   - Choisis **« Sur l'écran d'accueil »**.
   - Nomme-la **Budget** → **Ajouter**.
7. Une icône **Budget** apparaît sur ton écran d'accueil. Ouvre-la : elle
   s'affiche en plein écran, comme une vraie app.

> ⚠️ En Wi-Fi local, le mode **hors-ligne** n'est pas actif (Safari exige du
> HTTPS pour ça). L'app marche tant que le serveur `node serve.js` tourne.
> Pour un vrai fonctionnement hors-ligne **partout**, utilise la méthode 2.

---

## 🌍 Méthode 2 — Mise en ligne gratuite (hors-ligne + accessible partout)

Héberge le dossier sur un service gratuit → tu obtiens une adresse **https://…**
que tu ouvres sur l'iPhone (même procédure « Sur l'écran d'accueil »). Là,
l'app fonctionne **hors-ligne** et **sans PC allumé**.

Choisis-en **un** (tous gratuits) :

### Option A — Netlify Drop (le plus simple, glisser-déposer)
1. Va sur **https://app.netlify.com/drop**
2. Glisse le dossier `BudgetQuotidien-Web` dans la page.
3. Tu obtiens une URL `https://xxxx.netlify.app` → ouvre-la sur l'iPhone.

### Option B — Vercel
1. Installe : `npm i -g vercel`
2. Dans le dossier : `vercel` (suis les questions, connexion par e-mail).
3. Une URL `https://xxxx.vercel.app` est générée.

### Option C — GitHub Pages
1. Crée un dépôt GitHub, dépose les fichiers du dossier.
2. Réglages → Pages → branche `main` → dossier `/root`.
3. URL `https://ton-pseudo.github.io/depot/`.

---

## Astuce
Une fois installée, l'app garde tes données **sur le téléphone** (budget,
dépenses). Tu peux tout réinitialiser depuis **Profil → Réinitialiser**.

## Différence avec la version App Store (Swift)
Cette PWA reprend **le même design et la même logique** (recalcul du budget
quotidien). La version native Swift (dossier `BudgetQuotidien/`) ajoute en plus :
notifications système programmées, Face ID, widgets — et nécessite un Mac +
Xcode pour être publiée sur l'App Store.
