#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>


char *retirerEgal(const char *mot)
{
    size_t len = strlen(mot);
    char *sansEg = malloc(len + 1);
    if (!sansEg) return NULL;

    size_t j = 0;
    for (size_t i = 0; i < len; i++)
    {
        if (mot[i] == '=') break;  // on coupe au premier '='
        sansEg[j++] = mot[i];
    }

    sansEg[j] = '\0';
    return sansEg;   // retourne la nouvelle chaîne
}

void iniTableau(char **Tableau)
{
    const char *alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    for (int i = 0; i < 64; i++)
        for (int j = 0; j < 64; j++)
            Tableau[i][j] = alphabet[(i + j) % 64];
}

int indice(char c)
{
    const char *alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"; 
    for (int i = 0; i < 64; i++)
        if (c == alphabet[i])
            return i;
    return -1;
}

char *chiffrer(char *mot, char *phraseA_Chiffrer, size_t taillePhrase, char **Tableau, int *curseur)
{
    int tailleMot = strlen(mot);
    char *phraseChiffrer = malloc(taillePhrase + 1);
    if (!phraseChiffrer) return NULL;

    for (size_t cpt = 0; cpt < taillePhrase; cpt++)
    {
        if (phraseA_Chiffrer[cpt] == '=') {
            phraseChiffrer[cpt] = '=';
        }
        else {
            int i1 = indice(mot[*curseur % tailleMot]);
            int i2 = indice(phraseA_Chiffrer[cpt]);

            if (i1 < 0 || i2 < 0) {
                phraseChiffrer[cpt] = phraseA_Chiffrer[cpt];
            } else {
                phraseChiffrer[cpt] = Tableau[i1][i2];
            }
        }

        (*curseur)++;  
    }

    phraseChiffrer[taillePhrase] = '\0';
    return phraseChiffrer;
}

char *dechiffrer(char *mot, char *phraseChiffrer, size_t taillePhrase, char **Tableau, int *curseur)
{
    size_t tailleMot = strlen(mot);
    char *resultat = malloc(taillePhrase + 1);
    if (!resultat) return NULL;

    for (size_t i = 0; i < taillePhrase; i++)
    {
        if (phraseChiffrer[i] == '=') {
            resultat[i] = '=';
            (*curseur)++;  // 
            continue;
        }

        int motIndice = indice(mot[*curseur % tailleMot]);

        if (motIndice < 0) {
            resultat[i] = phraseChiffrer[i];
            (*curseur)++;
            continue;
        }

        int colonneTrouvee = -1;
        for (int col = 0; col < 64; col++){
            if (Tableau[motIndice][col] == phraseChiffrer[i]) {
                colonneTrouvee = col;
                break;
            }
        }

        if (colonneTrouvee < 0)
            resultat[i] = phraseChiffrer[i];
        else
            resultat[i] = Tableau[colonneTrouvee][0];

        (*curseur)++;  /* incrémentation correcte */
    }

    resultat[taillePhrase] = '\0';
    return resultat;
}

char *findkey(char *Phrase_CLair, char *Phrase_Code, size_t taillePhrase, char **Tableau)
{
    char *phraseATrouver = malloc(taillePhrase + 1); // +1 pour le caractère de fin '\0'
    if (!phraseATrouver) {
        perror("malloc phraseATrouver");
        return NULL;
    }

    for (size_t i = 0; i < taillePhrase; i++) {
        char lettreChiffrer = Phrase_Code[i];
        int lettreClaire = indice(Phrase_CLair[i]);

        if (lettreClaire == -1) {
            continue;
        }

        int IndiceLettreDechiffre = 0;
        while (IndiceLettreDechiffre < 64 && Tableau[IndiceLettreDechiffre][lettreClaire] != lettreChiffrer)
            IndiceLettreDechiffre++;

        phraseATrouver[i] = Tableau[IndiceLettreDechiffre][0];
    }

    phraseATrouver[taillePhrase] = '\0';  // Ajouter le caractère de fin

    return phraseATrouver;
}

int verifier(char *ChaineAvecDup, char *cleProbable)
{
    int TaillChaineAvecDup = strlen(ChaineAvecDup);
    int taillecleProbable = strlen(cleProbable);
    for (int i = 0; i < TaillChaineAvecDup; i++) {
        if (ChaineAvecDup[i] != cleProbable[i % taillecleProbable])
            return 0;
    }
    return 1;
}

int find_key(char *ChaineAvecDup, char **cleFinal)
{
    int TaillChaineAvecDup = strlen(ChaineAvecDup);

    for (int i = 1; i <= TaillChaineAvecDup / 2; i++) {
        char *temp = realloc(*cleFinal, strlen(*cleFinal) + i + 1);  // +i pour la longueur de la clé
        if (!temp) {
            perror("realloc cleFinal");
            return 0;
        }
        *cleFinal = temp;
        strncpy(*cleFinal, ChaineAvecDup, i);
        (*cleFinal)[i] = '\0';
        if (verifier(ChaineAvecDup, *cleFinal) == 1) {
            return 1;
        }
    }
    strcpy(*cleFinal, ChaineAvecDup);
    return 0;
}