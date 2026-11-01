# ENJEO — TAXIBE (version de test)

Jeu de course de taxi-brousse malagasy (Flutter). Cette archive contient le code ;
GitHub construit l'APK Android pour toi.

## Obtenir l'APK (depuis le navigateur)

1. Sur GitHub, crée un dépôt vide nommé `enjeo` (Public ou Privé).
2. Décompresse le zip sur ton ordinateur.
3. Dans le dépôt : **Add file → Upload files**, puis glisse **tout le contenu** du dossier
   `enjeo` (dossiers `lib`, `test`, `.github`, et les fichiers `pubspec.yaml`, etc.).
   Valide avec **Commit changes**.
4. Si le dossier `.github` n'a pas été envoyé (dossier caché sur ton ordinateur) :
   **Add file → Create new file**, tape `.github/workflows/build-apk.yml` comme nom,
   colle le contenu du fichier `build-apk.yml` fourni à part, puis valide.
5. Ouvre l'onglet **Actions** : la ligne « Build APK de test ENJEO » se lance
   (10 à 15 minutes). Si elle ne démarre pas : clique dessus → **Run workflow**.
6. Quand elle est verte ✅, ouvre-la et télécharge **enjeo-apk-test** (en bas, section
   *Artifacts*). Décompresse le zip : tu obtiens `app-release.apk`.

## Installer sur Android

Copie `app-release.apk` sur le téléphone, ouvre-le et autorise l'installation depuis
cette source si Android le demande.

## Si la ligne devient rouge ❌

Ouvre-la, copie le message d'erreur de l'étape en rouge (ou fais une capture d'écran)
et envoie-le moi : je corrige.

## Captures d'écran (en plus de l'APK)

Le même lancement GitHub (onglet **Actions**) produit un second fichier, **enjeo-captures-ecran**,
qui contient de vraies images PNG de l'application : le menu, une partie, et les 6 paysages
(un par étape de A à G). Télécharge-le au même endroit que l'APK.
Ce second job est indépendant : s'il échoue, l'APK est quand même construit.
Dans ces images, les emojis apparaissent comme des carrés vides : c'est une limite des captures
automatiques, pas de l'application.

## Publier sur Google Play (fichier .aab)

Le workflow « Build AAB production ENJEO (Google Play) » construit le fichier .aab exigé par Google Play,
signé avec ta clé d'envoi. Il se lance à la main : onglet **Actions** > ce workflow > **Run workflow**.

1. Crée les 2 secrets GitHub décrits dans `ENJEO-secrets-github.txt` (fichier remis à part, jamais dans ce zip).
2. Lance le workflow. Le fichier **enjeo-aab-play-store** (app-release.aab) apparaît en bas de la page.
3. Dans la Play Console : Tests internes > Créer une release > Importer > choisis app-release.aab.
4. À chaque nouvel envoi, relance le workflow : le numéro de build augmente tout seul.
