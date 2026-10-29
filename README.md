# Projet SAE — Outils de chiffrement et de cryptanalyse Vigenère (C · Bash)

Ensemble d'outils en C et de scripts Bash permettant de chiffrer, déchiffrer et **casser** des fichiers chiffrés avec une variante du chiffrement de Vigenère, développé en binôme dans le cadre d'un projet universitaire (SAE).

## Contexte

Le scénario du projet : des archives d'un système compromis contiennent des fichiers chiffrés par un attaquant. Les scripts Bash :

1. repèrent dans `var/log/auth.log` la dernière connexion réussie de l'utilisateur `admin` ;
2. classent les fichiers en « modifiés » (après cette date, donc chiffrés) et « sains » ;
3. retrouvent la clé en comparant un fichier chiffré avec sa version saine (même nom, même taille) ;
4. déchiffrent tous les fichiers modifiés et les restaurent.

## Principe cryptographique

- Le Vigenère est appliqué sur l'**alphabet Base64** (64 caractères : `A-Z`, `a-z`, `0-9`, `+`, `/`) et non sur les 26 lettres : chaque fichier est d'abord encodé en Base64, ce qui permet de chiffrer n'importe quel fichier, y compris binaire.
- Les caractères de bourrage `=` ne sont ni chiffrés ni pris en compte.
- La récupération de clé (`findkey`) est une **attaque à clair connu** : à partir d'un couple clair / chiffré, on calcule la suite des décalages, puis on détecte le motif qui se répète pour isoler la clé.

## Les outils C

| Programme | Rôle | Utilisation |
|-----------|------|-------------|
| `cipher` | Chiffre un fichier (modifié sur place) | `./cipher <cle> <fichier>` |
| `decipher` | Déchiffre un fichier (modifié sur place) | `./decipher <cle> <fichier>` |
| `findkey` | Retrouve la clé à partir d'un clair et de son chiffré (encodés en Base64) | `./findkey <clair> <chiffre> [-o fichier_sortie]` |

Sans `-o`, `findkey` affiche la clé sur la sortie standard.

## Compilation

```bash
cd src
make        # génère cipher, decipher, findkey et la bibliothèque statique libstat.a
make clean  # supprime les fichiers générés
```

Prérequis : `gcc` et `make`.

## Les scripts Bash

| Script | Rôle |
|--------|------|
| `import-archives.sh` | Importe des archives `.tar.gz` dans le répertoire de travail `.sh-toolbox` et les enregistre dans `archives.txt` (option `-f` pour forcer l'écrasement) |
| `ls-toolbox.sh` | Liste les archives (date d'import, clé trouvée) et signale les incohérences avec `archives.txt` |
| `check-toolbox.sh` | Analyse une archive : date de dernière connexion admin, fichiers modifiés / sains |
| `restore-archives.sh` | Retrouve la clé avec `findkey`, puis déchiffre et restaure les fichiers |
| `restore-toolbox.sh` | Répare les incohérences entre `archives.txt` et le contenu de `.sh-toolbox` |

## Structure du projet

```
src/
├── cipher.c      # Chiffrement
├── decipher.c    # Déchiffrement
├── findkey.c     # Recherche de clé (attaque à clair connu)
├── fonction.c    # Fonctions communes (table de Vigenère, déchiffrement, détection du motif de la clé)
└── Makefile
*.sh              # Scripts Bash (import, analyse, restauration)
```

## Ce que ce projet démontre

- Manipulation bas niveau de fichiers en C (lecture/écriture par blocs, réécriture sur place) et gestion de la mémoire.
- Compréhension du chiffrement de Vigenère, de ses faiblesses et d'une attaque à clair connu.
- Analyse de logs (`auth.log`) et horodatage des fichiers pour identifier des fichiers compromis, dans une logique proche de la réponse à incident.
- Organisation d'un projet C avec Makefile et bibliothèque statique, automatisation en Bash.
- Travail en binôme.

## Auteurs

Michael Djeatsa Keleko & Mohamed El brrah — projet universitaire (SAE) réalisé en binôme, MIAGE Informatique, Université de Picardie Jules Verne.
