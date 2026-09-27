#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
#include "fonction.c"
#define BLOC 256


int main(int argc, char *argv[])
{
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <mot_cle> <fichier_a_decrypter>\n", argv[0]);
        return 1;
    }


    char MEGABUFF[BLOC];
    size_t bytes;
    long filePos;
    int entier = 0;

    FILE *f = fopen(argv[2], "r+b");
    if (!f) {
        perror("Erreur ouverture fichier");
        return 1; fflush(f);  
    }

    char **Tableau = malloc(64 * sizeof(char*));
    retirerEgal(argv[1]);
    for (int i = 0; i < 64; i++) Tableau[i] = malloc(64);

    iniTableau(Tableau);
    char *motsansEg = retirerEgal(argv[1]); // Supprimer les '=' du mot clé

    /* Lecture par blocs du fichier et modification directe */
    while ((bytes = fread(MEGABUFF, 1, BLOC, f)) > 0)
    {
        filePos = ftell(f) - bytes;  /* Position de début du bloc lu */
        
        char *clair = dechiffrer(motsansEg, MEGABUFF, bytes, Tableau, &entier);
        if (!clair) {
            fprintf(stderr, "Erreur d'allocation mémoire\n");
            break;
        }

        /* Revenir à la position du bloc et le réécrire */
        fseek(f, filePos, SEEK_SET);
        fwrite(clair, 1, bytes, f);
        fflush(f);  /* Forcer l'écriture dans le fichier */
        fseek(f, filePos + bytes, SEEK_SET);  /* Positionner pour la prochaine lecture */
        free(clair);
    }

    fclose(f);


    for (int i = 0; i < 64; i++)
        free(Tableau[i]);
    free(Tableau);

    return 0;
}

