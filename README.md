# Projet SAE C — Outils de déchiffrement Vigenère

Ensemble d'outils en C et de scripts Bash permettant de chiffrer, déchiffrer et **casser** des fichiers chiffrés avec le chiffrement de Vigenère, développé en binôme dans le cadre d'un projet universitaire (SAE).

## Description générale

Cette partie en C permet de comprendre le fonctionnement des outils utilisés par les scripts Bash (`.sh`) pour restaurer des fichiers chiffrés :

- **`findkey`** — retrouve la clé utilisée pour le chiffrement.
- **`decipher`** — déchiffre un fichier à partir de cette clé.
- **`cipher`** — chiffre un fichier avec une clé donnée.

## Fonctionnement du déchiffrement

Le déchiffrement d'un fichier suit trois étapes :

1. **Encodage Base64** du fichier chiffré.
2. **Déchiffrement Vigenère** avec une clé elle-même encodée en Base64 (les caractères de bourrage Base64 ne sont pas modifiés ni pris en compte).
3. **Décodage Base64** pour obtenir un fichier lisible.

## Stockage de la clé

Le script `restore-archives.sh` stocke la clé trouvée par `findkey` dans le fichier `temp/KEY`, afin de pouvoir vérifier par la suite si celle-ci est imprimable ou non.

Compilation manuelle de `findkey` :

```bash
gcc -o temp/KEY src/findkey.c src/fonction.c
```

En pratique, c'est `restore-archives.sh` qui s'en charge automatiquement.

## Prérequis

- Un compilateur C (ex. `gcc`)
- `make` (optionnel, pour compiler via le `Makefile`)

## Compilation via Makefile

```bash
cd src
make
```

Génère les exécutables `cipher`, `decipher` et `findkey`.

## Utilisation

```bash
./cipher fichier_clair.txt cle > fichier_chiffre.txt
./decipher fichier_chiffre.txt cle > fichier_dechiffre.txt
./findkey fichier_clair.txt fichier_chiffre.txt
```

## Structure du projet

```
src/
├── cipher.c      # Chiffrement
├── decipher.c    # Déchiffrement
├── findkey.c      # Recherche de clé (cryptanalyse)
├── fonction.c     # Fonctions utilitaires
└── Makefile       # Automatisation de la compilation
*.sh               # Scripts Bash (import, restauration, gestion d'archives)
```

## Ce que ce projet démontre

- Manipulation bas niveau de fichiers et de chaînes de caractères en C.
- Compréhension du fonctionnement du chiffrement de Vigenère combiné à l'encodage Base64, et de ses faiblesses (récupération de clé).
- Organisation d'un projet C avec Makefile et bibliothèque statique.
- Scripting Bash pour l'automatisation de tâches (archivage, restauration).
- Travail en binôme sur un projet universitaire.

## Auteurs

Michael Djeatsa Keleko & Mohamed Elbrrah — SAE, partie langage C, étudiants en L3 MIAGE Informatique.
