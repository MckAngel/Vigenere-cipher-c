#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define BLOC 256

char *retirerEgal(const char *mot)
{
    size_t taille = strlen(mot);
    char *sansEg = malloc(taille + 1);
    if (!sansEg) return NULL;

    size_t j = 0;
    for (size_t i = 0; i < taille; i++)
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
            Tableau[i][j] = alphabet[(i + j) % 64]; // Remplissage du tableau, mod 64 car 64 caracteres
}

int indice(char c)
{
     const char *alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    for (int i = 0; i < 64; i++)
        if (c == alphabet[i])
            return i;    // retourne l'indice si trouve
    return -1;
}

char *chiffrer(char *mot, char *phrase, size_t taillePhrase, char **Tableau, int *curseur)
{
    int tailleMot = strlen(mot);
    char *phraseCorder = malloc(taillePhrase + 1); 
    if (!phraseCorder) return NULL;

    for (size_t cpt = 0; cpt < taillePhrase; cpt++)
    {
        if (phrase[cpt] == '=') {
            phraseCorder[cpt] = '=';
        }
        else {
            int IndiceDeLettre_mot = indice(mot[*curseur % tailleMot]); // Utilisation du modulo pour boucler sur le mot clé
            int IndiceDeLettre_phraseACoder = indice(phrase[cpt]);

            if (IndiceDeLettre_mot < 0 || IndiceDeLettre_phraseACoder < 0) { // Caractère non dans l'alphabet
                phraseCorder[cpt] = phrase[cpt];
                printf("Caractère non present dans l'alphabet: %c\n", phrase[cpt]);
            } else {
                phraseCorder[cpt] = Tableau[IndiceDeLettre_mot][IndiceDeLettre_phraseACoder];
            }
        }

        (*curseur)++;  
    }

    phraseCorder[taillePhrase] = '\0';
    return phraseCorder;
}


int main(int argc, char *argv[])
{
    if (argc < 3)
    {
        fprintf(stderr, "Usage: %s <mot_cle> <fichier_a_crypter>\n", argv[0]);
        return 1;
    }

    char MEGABUFF[BLOC];
    size_t bytes;
    long filePos;
    int entier=0;
    FILE *f = fopen(argv[2], "r+");
    if (!f)
    {
        perror("Erreur ouverture fichier");
        return 1;
    }

    // Supprimer les '=' du mot clé
    char *motsansEg = retirerEgal(argv[1]);
    if (!motsansEg) {
        fprintf(stderr, "Erreur allocation motsansEg\n");
        return 1;
    }

    // Initialisation tableau
    char **Tableau = malloc(64 * sizeof(char*));
    for (int i = 0; i < 64; i++)
        Tableau[i] = malloc(64);

    iniTableau(Tableau);

    // Lecture par blocs du fichier et modification
    while ((bytes = fread(MEGABUFF, 1, BLOC, f)) > 0)
    {
        filePos = ftell(f) - bytes;

        char *chiffree = chiffrer(motsansEg, MEGABUFF, bytes, Tableau, &entier);
        if (!chiffree) {
            fprintf(stderr, "Erreur allocation chiffree\n");
            break;
        }
        /* Revenir à la position du bloc et le réécrire */
        fseek(f, filePos, SEEK_SET);
        fwrite(chiffree, 1, bytes, f);
        fflush(f);/* Forcer l'écriture dans le fichier */
        fseek(f, filePos + bytes, SEEK_SET);/* Positionner pour la prochaine lecture */
        free(chiffree);
    }

    fclose(f);

    printf("------ Le fichier %s a été crypté avec succès ------\n", argv[2]);

    free(motsansEg);

    for (int i = 0; i < 64; i++)
        free(Tableau[i]);
    free(Tableau);

    return 0;
}

